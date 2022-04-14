local CoralTypes = {
    ["dendrogyra_coral"] = math.random(70, 100),
    ["antipatharia_coral"] = math.random(50, 70)
}

-- Code

RegisterServerEvent('aq-diving:server:SetBerthVehicle')
AddEventHandler('aq-diving:server:SetBerthVehicle', function(BerthId, vehicleModel)
    TriggerClientEvent('aq-diving:client:SetBerthVehicle', -1, BerthId, vehicleModel)

    AQBoatshop.Locations["berths"][BerthId]["boatModel"] = boatModel
end)

RegisterServerEvent('aq-diving:server:SetDockInUse')
AddEventHandler('aq-diving:server:SetDockInUse', function(BerthId, InUse)
    AQBoatshop.Locations["berths"][BerthId]["inUse"] = InUse
    TriggerClientEvent('aq-diving:client:SetDockInUse', -1, BerthId, InUse)
end)

AQCore.Functions.CreateCallback('aq-diving:server:GetBusyDocks', function(source, cb)
    cb(AQBoatshop.Locations["berths"])
end)

RegisterServerEvent('aq-diving:server:BuyBoat')
AddEventHandler('aq-diving:server:BuyBoat', function(boatModel, BerthId)
    local BoatPrice = AQBoatshop.ShopBoats[boatModel]["price"]
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    local PlayerMoney = {
        cash = Player.PlayerData.money.cash,
        bank = Player.PlayerData.money.bank
    }
    local missingMoney = 0
    local plate = "AQ" .. math.random(1000, 9999)

    if PlayerMoney.cash >= BoatPrice then
        Player.Functions.RemoveMoney('cash', BoatPrice, "bought-boat")
        TriggerClientEvent('aq-diving:client:BuyBoat', src, boatModel, plate)
        InsertBoat(boatModel, Player, plate)
    elseif PlayerMoney.bank >= BoatPrice then
        Player.Functions.RemoveMoney('bank', BoatPrice, "bought-boat")
        TriggerClientEvent('aq-diving:client:BuyBoat', src, boatModel, plate)
        InsertBoat(boatModel, Player, plate)
    else
        if PlayerMoney.bank > PlayerMoney.cash then
            missingMoney = (BoatPrice - PlayerMoney.bank)
        else
            missingMoney = (BoatPrice - PlayerMoney.cash)
        end
        TriggerClientEvent('AQCore:Notify', src, 'Niet genoeg geld. Je mist nog €' .. missingMoney .. '', 'error')
    end
end)

function InsertBoat(boatModel, Player, plate)
    exports.oxmysql:insert('INSERT INTO player_boats (citizenid, model, plate) VALUES (?, ?, ?)',
        {Player.PlayerData.citizenid, boatModel, plate})
end

AQCore.Functions.CreateUseableItem("jerry_can", function(source, item)
    local Player = AQCore.Functions.GetPlayer(source)

    TriggerClientEvent("aq-diving:client:UseJerrycan", source)
end)

AQCore.Functions.CreateUseableItem("diving_gear", function(source, item)
    local Player = AQCore.Functions.GetPlayer(source)

    TriggerClientEvent("aq-diving:client:UseGear", source, true)
end)

RegisterServerEvent('aq-diving:server:RemoveItem')
AddEventHandler('aq-diving:server:RemoveItem', function(item, amount)
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)

    Player.Functions.RemoveItem(item, amount)
end)

AQCore.Functions.CreateCallback('aq-diving:server:GetMyBoats', function(source, cb, dock)
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    local result = exports.oxmysql:fetchSync('SELECT * FROM player_boats WHERE citizenid = ? AND boathouse = ?',
        {Player.PlayerData.citizenid, dock})
    if result[1] ~= nil then
        cb(result)
    else
        cb(nil)
    end
end)

AQCore.Functions.CreateCallback('aq-diving:server:GetDepotBoats', function(source, cb, dock)
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    local result = exports.oxmysql:fetchSync('SELECT * FROM player_boats WHERE citizenid = ? AND state = ?',
        {Player.PlayerData.citizenid, 0})
    if result[1] ~= nil then
        cb(result)
    else
        cb(nil)
    end
end)

RegisterServerEvent('aq-diving:server:SetBoatState')
AddEventHandler('aq-diving:server:SetBoatState', function(plate, state, boathouse, fuel)
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    local result = exports.oxmysql:scalarSync('SELECT 1 FROM player_boats WHERE plate = ?', {plate})
    if result ~= nil then
        exports.oxmysql:execute(
            'UPDATE player_boats SET state = ?, boathouse = ?, fuel = ? WHERE plate = ? AND citizenid = ?',
            {state, boathouse, fuel, plate, Player.PlayerData.citizenid})
    end
end)

RegisterServerEvent('aq-diving:server:CallCops')
AddEventHandler('aq-diving:server:CallCops', function(Coords)
    local src = source
    for k, v in pairs(AQCore.Functions.GetPlayers()) do
        local Player = AQCore.Functions.GetPlayer(v)
        if Player ~= nil then
            if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
                local msg = "Dit koraal is mogelijk gestolen"
                TriggerClientEvent('aq-diving:client:CallCops', Player.PlayerData.source, Coords, msg)
                local alertData = {
                    title = "Illegal diving",
                    coords = {
                        x = Coords.x,
                        y = Coords.y,
                        z = Coords.z
                    },
                    description = msg
                }
                TriggerClientEvent("aq-phone:client:addPoliceAlert", -1, alertData)
            end
        end
    end
end)

local AvailableCoral = {}

AQCore.Commands.Add("divingsuit", "Doe je duikpak uit", {}, false, function(source, args)
    local Player = AQCore.Functions.GetPlayer(source)
    TriggerClientEvent("aq-diving:client:UseGear", source, false)
end)

RegisterServerEvent('aq-diving:server:SellCoral')
AddEventHandler('aq-diving:server:SellCoral', function()
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)

    if HasCoral(src) then
        for k, v in pairs(AvailableCoral) do
            local Item = Player.Functions.GetItemByName(v.item)
            local price = (Item.amount * v.price)
            local Reward = math.ceil(GetItemPrice(Item, price))

            if Item.amount > 1 then
                for i = 1, Item.amount, 1 do
                    Player.Functions.RemoveItem(Item.name, 1)
                    TriggerClientEvent('inventory:client:ItemBox', src, AQCore.Shared.Items[Item.name], "remove")
                    Player.Functions.AddMoney('cash', math.ceil((Reward / Item.amount)), "sold-coral")
                    Citizen.Wait(250)
                end
            else
                Player.Functions.RemoveItem(Item.name, 1)
                Player.Functions.AddMoney('cash', Reward, "sold-coral")
                TriggerClientEvent('inventory:client:ItemBox', src, AQCore.Shared.Items[Item.name], "remove")
            end
        end
    else
        TriggerClientEvent('AQCore:Notify', src, 'Je hebt geen koraal om te verkopen..', 'error')
    end
end)

function GetItemPrice(Item, price)
    if Item.amount > 5 then
        price = price / 100 * 80
    elseif Item.amount > 10 then
        price = price / 100 * 70
    elseif Item.amount > 15 then
        price = price / 100 * 50
    end
    return price
end

function HasCoral(src)
    local Player = AQCore.Functions.GetPlayer(src)
    local retval = false
    AvailableCoral = {}

    for k, v in pairs(AQDiving.CoralTypes) do
        local Item = Player.Functions.GetItemByName(v.item)
        if Item ~= nil then
            table.insert(AvailableCoral, v)
            retval = true
        end
    end
    return retval
end