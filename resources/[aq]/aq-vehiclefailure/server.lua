AQCore.Commands.Add("fix", "Repair your vehicle (Admin Only)", {}, false, function(source, args)
    TriggerClientEvent('iens:repaira', source)
    TriggerClientEvent('vehiclemod:client:fixEverything', source)
end, "admin")

AQCore.Functions.CreateUseableItem("repairkit", function(source, item)
    local Player = AQCore.Functions.GetPlayer(source)
	if Player.Functions.GetItemBySlot(item.slot) ~= nil then
        TriggerClientEvent("aq-vehiclefailure:client:RepairVehicle", source)
    end
end)

AQCore.Functions.CreateUseableItem("cleaningkit", function(source, item)
    local Player = AQCore.Functions.GetPlayer(source)
	if Player.Functions.GetItemBySlot(item.slot) ~= nil then
        TriggerClientEvent("aq-vehiclefailure:client:CleanVehicle", source)
    end
end)

AQCore.Functions.CreateUseableItem("advancedrepairkit", function(source, item)
    local Player = AQCore.Functions.GetPlayer(source)
	if Player.Functions.GetItemBySlot(item.slot) ~= nil then
        TriggerClientEvent("aq-vehiclefailure:client:RepairVehicleFull", source)
    end
end)

RegisterServerEvent('aq-vehiclefailure:removeItem')
AddEventHandler('aq-vehiclefailure:removeItem', function(item)
    local src = source
    local ply = AQCore.Functions.GetPlayer(src)
    ply.Functions.RemoveItem(item, 1)
end)

RegisterServerEvent('aq-vehiclefailure:server:removewashingkit')
AddEventHandler('aq-vehiclefailure:server:removewashingkit', function(veh)
    local src = source
    local ply = AQCore.Functions.GetPlayer(src)
    ply.Functions.RemoveItem("cleaningkit", 1)
    TriggerClientEvent('aq-vehiclefailure:client:SyncWash', -1, veh)
end)

