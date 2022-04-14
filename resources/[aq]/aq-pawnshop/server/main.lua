local ItemList = {
    ["goldchain"] = math.random(60, 110),
    ["diamond_ring"] = math.random(85, 135),
    ["rolex"] = math.random(50, 100),
    ["10kgoldchain"] = math.random(40, 80),
}

local ItemListHardware = {
    ["tablet"] = math.random(50, 100),
    ["iphone"] = math.random(50, 200),
    ["samsungphone"] = math.random(75, 150),
    ["laptop"] = math.random(50, 200),
}

local MeltItems = {
    ["rolex"] = 24,
    ["goldchain"] = 32,
}

local GoldBarsAmount = 0

RegisterServerEvent("aq-pawnshop:server:sellPawnItems")
AddEventHandler("aq-pawnshop:server:sellPawnItems", function()
    local src = source
    local price = 0
    local Player = AQCore.Functions.GetPlayer(src)
    if Player.PlayerData.items ~= nil and next(Player.PlayerData.items) ~= nil then 
        for k, v in pairs(Player.PlayerData.items) do 
            if Player.PlayerData.items[k] ~= nil then 
                if ItemList[Player.PlayerData.items[k].name] ~= nil then 
                    price = price + (ItemList[Player.PlayerData.items[k].name] * Player.PlayerData.items[k].amount)
                    Player.Functions.RemoveItem(Player.PlayerData.items[k].name, Player.PlayerData.items[k].amount, k)
                    TriggerClientEvent('inventory:client:ItemBox', source, AQCore.Shared.Items[Player.PlayerData.items[k].name], "remove")
                end
            end
        end
        Player.Functions.AddMoney("cash", price, "verkochte verpandbare items")
        TriggerClientEvent('AQCore:Notify', src, "Je hebt je artikelen verkocht")
    end
end)

RegisterServerEvent("aq-pawnshop:server:sellHardwarePawnItems")
AddEventHandler("aq-pawnshop:server:sellHardwarePawnItems", function()
    local src = source
    local price = 0
    local Player = AQCore.Functions.GetPlayer(src)
    if Player.PlayerData.items ~= nil and next(Player.PlayerData.items) ~= nil then 
        for k, v in pairs(Player.PlayerData.items) do
            if Player.PlayerData.items[k] ~= nil then 
                if ItemListHardware[Player.PlayerData.items[k].name] ~= nil then 
                    price = price + (ItemListHardware[Player.PlayerData.items[k].name] * Player.PlayerData.items[k].amount)
                    Player.Functions.RemoveItem(Player.PlayerData.items[k].name, Player.PlayerData.items[k].amount, k)
                    TriggerClientEvent('inventory:client:ItemBox', src, AQCore.Shared.Items[Player.PlayerData.items[k].name], "remove")
                end
            end
        end
        Player.Functions.AddMoney("cash", price, "verkochte verpandbare items")
        TriggerClientEvent('AQCore:Notify', src, "Je hebt je artikelen verkocht")
    end

end)

RegisterServerEvent("aq-pawnshop:server:getGoldBars")
AddEventHandler("aq-pawnshop:server:getGoldBars", function()
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    if GoldBarsAmount > 0 then
        if Player.Functions.AddItem("goldbar", GoldBarsAmount) then
            GoldBarsAmount = 0
            TriggerClientEvent('inventory:client:ItemBox', src, AQCore.Shared.Items["goldbar"], "add")
            Config.IsMelting = false
            Config.CanTake = false
            Config.MeltTime = 300
            TriggerClientEvent("aq-pawnshop:client:SetTakeState", -1, false)
        else
            TriggerClientEvent('AQCore:Notify', src, "Je hebt geen ruimte in je inventaris", "error")
        end
    end
end)

RegisterServerEvent("aq-pawnshop:server:sellGold")
AddEventHandler("aq-pawnshop:server:sellGold", function()
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    local price = 0
    if Player.PlayerData.items ~= nil and next(Player.PlayerData.items) ~= nil then 
        for k, v in pairs(Player.PlayerData.items) do 
            if Player.PlayerData.items[k] ~= nil then 
                if Player.PlayerData.items[k].name == "goldbar" then 
                    price = price + (math.random(3000, 4200) * Player.PlayerData.items[k].amount)
                    Player.Functions.RemoveItem(Player.PlayerData.items[k].name, Player.PlayerData.items[k].amount, k)
                    TriggerClientEvent('inventory:client:ItemBox', src, AQCore.Shared.Items[Player.PlayerData.items[k].name], "remove")
                end
            end
        end
        Player.Functions.AddMoney("cash", price, "sold-gold")
        TriggerClientEvent('AQCore:Notify', src, "Je hebt je artikelen verkocht")
    end
end)

RegisterServerEvent("aq-pawnshop:server:meltItems")
AddEventHandler("aq-pawnshop:server:meltItems", function()
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    local goldbars = 0
    if Player.PlayerData.items ~= nil and next(Player.PlayerData.items) ~= nil then 
        for k, v in pairs(Player.PlayerData.items) do 
            if Player.PlayerData.items[k] ~= nil then 
                if MeltItems[Player.PlayerData.items[k].name] ~= nil then 
                    local amount = (Player.PlayerData.items[k].amount / MeltItems[Player.PlayerData.items[k].name])
                    if amount < 1 then
                        TriggerClientEvent('AQCore:Notify', src, "Je hebt niet genoeg " .. Player.PlayerData.items[k].label, "error")
                    else
                        amount = math.ceil(Player.PlayerData.items[k].amount / MeltItems[Player.PlayerData.items[k].name])
                        if amount > 0 then
                            if Player.Functions.RemoveItem(Player.PlayerData.items[k].name, Player.PlayerData.items[k].amount, k) then
                                goldbars = goldbars + amount
                            end
                        end
                    end
                end
            end
        end
        if goldbars > 0 then
            GoldBarsAmount = goldbars
            TriggerClientEvent('aq-pawnshop:client:startMelting', -1)
            Config.IsMelting = true
            Config.MeltTime = 300
            Citizen.CreateThread(function()
                while Config.IsMelting do
                    Config.MeltTime = Config.MeltTime - 1
                    if Config.MeltTime <= 0 then
                        Config.IsMelting = false
                        Config.CanTake = true
                        Config.MeltTime = 300
                        TriggerClientEvent('aq-pawnshop:client:SetTakeState', -1, true)
                    end
                    Citizen.Wait(1000)
                end
            end)
        end
    end
end)

AQCore.Functions.CreateCallback('aq-pawnshop:server:getSellPrice', function(source, cb)
    local retval = 0
    local Player = AQCore.Functions.GetPlayer(source)
    if Player.PlayerData.items ~= nil and next(Player.PlayerData.items) ~= nil then 
        for k, v in pairs(Player.PlayerData.items) do 
            if Player.PlayerData.items[k] ~= nil then 
                if ItemList[Player.PlayerData.items[k].name] ~= nil then 
                    retval = retval + (ItemList[Player.PlayerData.items[k].name] * Player.PlayerData.items[k].amount)
                end
            end
        end
    end
    cb(retval)
end)

AQCore.Functions.CreateCallback('aq-pawnshop:melting:server:GetConfig', function(source, cb)
    cb(Config.IsMelting, Config.MeltTime, Config.CanTake)
end)

AQCore.Functions.CreateCallback('aq-pawnshop:server:getSellHardwarePrice', function(source, cb)
    local retval = 0
    local Player = AQCore.Functions.GetPlayer(source)
    if Player.PlayerData.items ~= nil and next(Player.PlayerData.items) ~= nil then 
        for k, v in pairs(Player.PlayerData.items) do 
            if Player.PlayerData.items[k] ~= nil then 
                if ItemListHardware[Player.PlayerData.items[k].name] ~= nil then 
                    retval = retval + (ItemListHardware[Player.PlayerData.items[k].name] * Player.PlayerData.items[k].amount)
                end
            end
        end
    end
    cb(retval)
end)

AQCore.Functions.CreateCallback('aq-pawnshop:server:hasGold', function(source, cb)
	local retval = false
    local Player = AQCore.Functions.GetPlayer(source)
    local gold = Player.Functions.GetItemByName('goldbar')
    if gold ~= nil then
        retval = true
    end
    cb(retval)
end)