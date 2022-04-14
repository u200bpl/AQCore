local CurrentDivingArea = math.random(1, #AQDiving.Locations)

AQCore.Functions.CreateCallback('aq-diving:server:GetDivingConfig', function(source, cb)
    cb(AQDiving.Locations, CurrentDivingArea)
end)

RegisterServerEvent('aq-diving:server:TakeCoral')
AddEventHandler('aq-diving:server:TakeCoral', function(Area, Coral, Bool)
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    local CoralType = math.random(1, #AQDiving.CoralTypes)
    local Amount = math.random(1, AQDiving.CoralTypes[CoralType].maxAmount)
    local ItemData = AQCore.Shared.Items[AQDiving.CoralTypes[CoralType].item]

    if Amount > 1 then
        for i = 1, Amount, 1 do
            Player.Functions.AddItem(ItemData["name"], 1)
            TriggerClientEvent('inventory:client:ItemBox', src, ItemData, "add")
            Citizen.Wait(250)
        end
    else
        Player.Functions.AddItem(ItemData["name"], Amount)
        TriggerClientEvent('inventory:client:ItemBox', src, ItemData, "add")
    end

    if (AQDiving.Locations[Area].TotalCoral - 1) == 0 then
        for k, v in pairs(AQDiving.Locations[CurrentDivingArea].coords.Coral) do
            v.PickedUp = false
        end
        AQDiving.Locations[CurrentDivingArea].TotalCoral = AQDiving.Locations[CurrentDivingArea].DefaultCoral

        local newLocation = math.random(1, #AQDiving.Locations)
        while (newLocation == CurrentDivingArea) do
            Citizen.Wait(3)
            newLocation = math.random(1, #AQDiving.Locations)
        end
        CurrentDivingArea = newLocation
        
        TriggerClientEvent('aq-diving:client:NewLocations', -1)
    else
        AQDiving.Locations[Area].coords.Coral[Coral].PickedUp = Bool
        AQDiving.Locations[Area].TotalCoral = AQDiving.Locations[Area].TotalCoral - 1
    end

    TriggerClientEvent('aq-diving:server:UpdateCoral', -1, Area, Coral, Bool)
end)

RegisterServerEvent('aq-diving:server:RemoveGear')
AddEventHandler('aq-diving:server:RemoveGear', function()
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)

    Player.Functions.RemoveItem("diving_gear", 1)
    TriggerClientEvent('inventory:client:ItemBox', src, AQCore.Shared.Items["diving_gear"], "remove")
end)

RegisterServerEvent('aq-diving:server:GiveBackGear')
AddEventHandler('aq-diving:server:GiveBackGear', function()
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    
    Player.Functions.AddItem("diving_gear", 1)
    TriggerClientEvent('inventory:client:ItemBox', src, AQCore.Shared.Items["diving_gear"], "add")
end)