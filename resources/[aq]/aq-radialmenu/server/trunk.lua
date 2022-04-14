local trunkBusy = {}

RegisterServerEvent('aq-trunk:server:setTrunkBusy')
AddEventHandler('aq-trunk:server:setTrunkBusy', function(plate, busy)
    trunkBusy[plate] = busy
end)

AQCore.Functions.CreateCallback('aq-trunk:server:getTrunkBusy', function(source, cb, plate)
    if trunkBusy[plate] then
        cb(true)
    end
    cb(false)
end)

RegisterServerEvent('aq-trunk:server:KidnapTrunk')
AddEventHandler('aq-trunk:server:KidnapTrunk', function(targetId, closestVehicle)
    TriggerClientEvent('aq-trunk:client:KidnapGetIn', targetId, closestVehicle)
end)

AQCore.Commands.Add("getintrunk", "Get In Trunk", {}, false, function(source, args)
    TriggerClientEvent('aq-trunk:client:GetIn', source)
end)

AQCore.Commands.Add("putintrunk", "Put Player In Trunk", {}, false, function(source, args)
    TriggerClientEvent('aq-trunk:server:KidnapTrunk', source)
end)