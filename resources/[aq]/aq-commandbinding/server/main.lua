AQCore.Commands.Add("binds", "Open commandbinding menu", {}, false, function(source, args)
    local Player = AQCore.Functions.GetPlayer(source)
	TriggerClientEvent("aq-commandbinding:client:openUI", source)
end)

RegisterServerEvent('aq-commandbinding:server:setKeyMeta')
AddEventHandler('aq-commandbinding:server:setKeyMeta', function(keyMeta)
    local src = source
    local ply = AQCore.Functions.GetPlayer(src)

    ply.Functions.SetMetaData("commandbinds", keyMeta)
end)