RegisterServerEvent('aq-carwash:server:washCar')
AddEventHandler('aq-carwash:server:washCar', function()
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)

    if Player.Functions.RemoveMoney('cash', Config.DefaultPrice, "car-washed") then
        TriggerClientEvent('aq-carwash:client:washCar', src)
    elseif Player.Functions.RemoveMoney('bank', Config.DefaultPrice, "car-washed") then
        TriggerClientEvent('aq-carwash:client:washCar', src)
    else
        TriggerClientEvent('AQCore:Notify', src, 'Niet genoeg geld..', 'error')
    end
end)