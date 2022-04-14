AQCore = {}
AQCore.Config = AQConfig
AQCore.Shared = AQShared
AQCore.ServerCallbacks = {}
AQCore.UseableItems = {}

exports('GetCoreObject', function()
	return AQCore
end)

-- To use this export in a script instead of manifest method
-- Just put this line of code below at the very top of the script
-- local AQCore = exports['aq-core']:GetCoreObject()

-- Get permissions on server start

CreateThread(function()
	local result = exports.oxmysql:fetchSync('SELECT * FROM permissions', {})
	if result[1] then
		for k, v in pairs(result) do
			AQCore.Config.Server.PermissionList[v.license] = {
				license = v.license,
				permission = v.permission,
				optin = true,
			}
		end
	end
end)