isLoggedIn = false
PlayerJob = {}

RegisterNetEvent("AQCore:Client:OnPlayerLoaded")
AddEventHandler("AQCore:Client:OnPlayerLoaded", function()
    AQCore.Functions.TriggerCallback('aq-diving:server:GetBusyDocks', function(Docks)
        AQBoatshop.Locations["berths"] = Docks
    end)

    AQCore.Functions.TriggerCallback('aq-diving:server:GetDivingConfig', function(Config, Area)
        AQDiving.Locations = Config
        TriggerEvent('aq-diving:client:SetDivingLocation', Area)
    end)

    PlayerJob = AQCore.Functions.GetPlayerData().job

    isLoggedIn = true

    if PlayerJob.name == "police" then
        if PoliceBlip ~= nil then
            RemoveBlip(PoliceBlip)
        end
        PoliceBlip = AddBlipForCoord(AQBoatshop.PoliceBoat.x, AQBoatshop.PoliceBoat.y, AQBoatshop.PoliceBoat.z)
        SetBlipSprite(PoliceBlip, 410)
        SetBlipDisplay(PoliceBlip, 4)
        SetBlipScale(PoliceBlip, 0.8)
        SetBlipAsShortRange(PoliceBlip, true)
        SetBlipColour(PoliceBlip, 29)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("Police boat")
        EndTextCommandSetBlipName(PoliceBlip)
        PoliceBlip = AddBlipForCoord(AQBoatshop.PoliceBoat2.x, AQBoatshop.PoliceBoat2.y, AQBoatshop.PoliceBoat2.z)
        SetBlipSprite(PoliceBlip, 410)
        SetBlipDisplay(PoliceBlip, 4)
        SetBlipScale(PoliceBlip, 0.8)
        SetBlipAsShortRange(PoliceBlip, true)
        SetBlipColour(PoliceBlip, 29)
    
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("Police boat")
        EndTextCommandSetBlipName(PoliceBlip)
    end
end)

DrawText3D = function(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

RegisterNetEvent('aq-diving:client:UseJerrycan')
AddEventHandler('aq-diving:client:UseJerrycan', function()
    local ped = PlayerPedId()
    local boat = IsPedInAnyBoat(ped)
    if boat then
        local curVeh = GetVehiclePedIsIn(ped, false)
        AQCore.Functions.Progressbar("reful_boat", "Boot tanken..", 20000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function() -- Done
            exports['LegacyFuel']:SetFuel(curVeh, 100)
            AQCore.Functions.Notify('De boot is getankt', 'success')
            TriggerServerEvent('aq-diving:server:RemoveItem', 'jerry_can', 1)
            TriggerEvent('inventory:client:ItemBox', AQCore.Shared.Items['jerry_can'], "remove")
        end, function() -- Cancel
            AQCore.Functions.Notify('Tanken is geannuleerd', 'error')
        end)
    else
        AQCore.Functions.Notify('Je zit niet in een boot', 'error')
    end
end)
