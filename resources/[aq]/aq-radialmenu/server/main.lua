RegisterServerEvent('json:dataStructure')
AddEventHandler('json:dataStructure', function(data)
    -- ??
end)

RegisterServerEvent('aq-radialmenu:trunk:server:Door')
AddEventHandler('aq-radialmenu:trunk:server:Door', function(open, plate, door)
    TriggerClientEvent('aq-radialmenu:trunk:client:Door', -1, plate, door, open)
end)