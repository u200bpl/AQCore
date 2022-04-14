local VehicleNitrous = {}

RegisterServerEvent('tackle:server:TacklePlayer')
AddEventHandler('tackle:server:TacklePlayer', function(playerId)
    TriggerClientEvent("tackle:client:GetTackled", playerId)
end)

AQCore.Functions.CreateCallback('nos:GetNosLoadedVehs', function(source, cb)
    cb(VehicleNitrous)
end)

AQCore.Commands.Add("id", "Check Your ID #", {}, false, function(source, args)
    TriggerClientEvent('AQCore:Notify', source,  "ID: "..source)
end)

AQCore.Functions.CreateUseableItem("harness", function(source, item)
    local Player = AQCore.Functions.GetPlayer(source)
    TriggerClientEvent('seatbelt:client:UseHarness', source, item)
end)

RegisterServerEvent('equip:harness')
AddEventHandler('equip:harness', function(item)
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    if Player.PlayerData.items[item.slot].info.uses - 1 == 0 then
        TriggerClientEvent("inventory:client:ItemBox", source, AQCore.Shared.Items['harness'], "remove")
        Player.Functions.RemoveItem('harness', 1)
    else
        Player.PlayerData.items[item.slot].info.uses = Player.PlayerData.items[item.slot].info.uses - 1
        Player.Functions.SetInventory(Player.PlayerData.items)
    end
end)

RegisterServerEvent('seatbelt:DoHarnessDamage')
AddEventHandler('seatbelt:DoHarnessDamage', function(hp, data)
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)

    if hp == 0 then
        Player.Functions.RemoveItem('harness', 1, data.slot)
    else
        Player.PlayerData.items[data.slot].info.uses = Player.PlayerData.items[data.slot].info.uses - 1
        Player.Functions.SetInventory(Player.PlayerData.items)
    end
end)

AQCore.Functions.CreateCallback('smallresources:server:GetCurrentPlayers', function(source, cb)
    local TotalPlayers = 0
    for k, v in pairs(AQCore.Functions.GetPlayers()) do
        TotalPlayers = TotalPlayers + 1
    end
    cb(TotalPlayers)
end)
