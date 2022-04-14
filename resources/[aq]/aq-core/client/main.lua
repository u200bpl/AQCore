AQCore = {}
AQCore.PlayerData = {}
AQCore.Config = AQConfig
AQCore.Shared = AQShared
AQCore.ServerCallbacks = {}

exports('GetCoreObject', function()
	return AQCore
end)

-- To use this export in a script instead of manifest method
-- Just put this line of code below at the very top of the script
-- local AQCore = exports['aq-core']:GetCoreObject()