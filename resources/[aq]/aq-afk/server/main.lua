local AQCore = exports['aq-core']:GetCoreObject()

RegisterServerEvent('KickForAFK', function()
    local src = source
	DropPlayer(src, 'Je bent gekicked voor te lang AFK te zijn')
end)

AQCore.Functions.CreateCallback('aq-afkkick:server:GetPermissions', function(source, cb)
    local src = source
    local group = AQCore.Functions.GetPermission(src)
    cb(group)
end)