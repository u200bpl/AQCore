local ItemList = {
    ["casinochips"] = 1,
}

RegisterServerEvent("aq-casino:server:sell")
AddEventHandler("aq-casino:server:sell", function()
    local src = source
    local price = 0
    local Player = AQCore.Functions.GetPlayer(src)
    local xItem = Player.Functions.GetItemByName("casinochips")
    if xItem ~= nil then
        for k, v in pairs(Player.PlayerData.items) do 
            if Player.PlayerData.items[k] ~= nil then 
                if ItemList[Player.PlayerData.items[k].name] ~= nil then 
                    price = price + (ItemList[Player.PlayerData.items[k].name] * Player.PlayerData.items[k].amount)
                    Player.Functions.RemoveItem(Player.PlayerData.items[k].name, Player.PlayerData.items[k].amount, k)
                        
        Player.Functions.AddMoney("cash", price, "sold-casino-chips")
            TriggerClientEvent('AQCore:Notify', src, "Je verkochte je fiches voor €"..price)
            TriggerEvent("aq-log:server:CreateLog", "casino", "Chips", "blue", "**"..GetPlayerName(src) .. "** got €"..price.." for selling the Chips")
                end
            end
        end
    else
        TriggerClientEvent('AQCore:Notify', src, "Je hebt geen fiches..")
    end
end)

function SetExports()
exports["aq-blackjack"]:SetGetChipsCallback(function(source)
    local Player = AQCore.Functions.GetPlayer(source)
    local Chips = Player.Functions.GetItemByName("casinochips")

    if Chips ~= nil then 
        Chips = Chips
    end

    return TriggerClientEvent('AQCore:Notify', src, "Je hebt geen fiches..")
end)

    exports["aq-blackjack"]:SetTakeChipsCallback(function(source, amount)
        local Player = AQCore.Functions.GetPlayer(source)

        if Player ~= nil then
            Player.Functions.RemoveItem("casinochips", amount)
            TriggerClientEvent('inventory:client:ItemBox', source, AQCore.Shared.Items['casinochips'], "remove")
            TriggerEvent("aq-log:server:CreateLog", "casino", "Chips", "yellow", "**"..GetPlayerName(source) .. "** put $"..amount.." in table")
        end
    end)

    exports["aq-blackjack"]:SetGiveChipsCallback(function(source, amount)
        local Player = AQCore.Functions.GetPlayer(source)

        if Player ~= nil then
            Player.Functions.AddItem("casinochips", amount)
            TriggerClientEvent('inventory:client:ItemBox', source, AQCore.Shared.Items['casinochips'], "add")
            TriggerEvent("aq-log:server:CreateLog", "casino", "Chips", "red", "**"..GetPlayerName(source) .. "** got $"..amount.." from table table and he won the double")
        end
    end)
end

AddEventHandler("onResourceStart", function(resourceName)
	if ("aq-blackjack" == resourceName) then
        Citizen.Wait(1000)
        SetExports()
    end
end)

SetExports()
