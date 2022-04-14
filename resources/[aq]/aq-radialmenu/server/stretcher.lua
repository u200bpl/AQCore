RegisterServerEvent('aq-radialmenu:server:RemoveStretcher')
AddEventHandler('aq-radialmenu:server:RemoveStretcher', function(PlayerPos, StretcherObject)
    TriggerClientEvent('aq-radialmenu:client:RemoveStretcherFromArea', -1, PlayerPos, StretcherObject)
end)

RegisterServerEvent('aq-radialmenu:Stretcher:BusyCheck')
AddEventHandler('aq-radialmenu:Stretcher:BusyCheck', function(id, type)
    local MyId = source
    TriggerClientEvent('aq-radialmenu:Stretcher:client:BusyCheck', id, MyId, type)
end)

RegisterServerEvent('aq-radialmenu:server:BusyResult')
AddEventHandler('aq-radialmenu:server:BusyResult', function(IsBusy, OtherId, type)
    TriggerClientEvent('aq-radialmenu:client:Result', OtherId, IsBusy, type)
end)
