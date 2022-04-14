AQCore.Functions = {}

-- Getters
-- Get your player first and then trigger a function on them
-- ex: local player = AQCore.Functions.GetPlayer(source)
-- ex: local example = player.Functions.functionname(parameter)

function AQCore.Functions.GetCoords(entity)
    local coords = GetEntityCoords(entity, false)
    local heading = GetEntityHeading(entity)
	return vector4(coords.x, coords.y, coords.z, heading)
end

function AQCore.Functions.GetIdentifier(source, idtype)
	local src = source
	local idtype = idtype or AQConfig.IdentifierType
	for _, identifier in pairs(GetPlayerIdentifiers(src)) do
		if string.find(identifier, idtype) then
			return identifier
		end
	end
	return nil
end

function AQCore.Functions.GetSource(identifier)
	for src, player in pairs(AQCore.Players) do
		local idens = GetPlayerIdentifiers(src)
		for _, id in pairs(idens) do
			if identifier == id then
				return src
			end
		end
	end
	return 0
end

function AQCore.Functions.GetPlayer(source)
    local src = source
	if type(src) == 'number' then
		return AQCore.Players[src]
	else
		return AQCore.Players[AQCore.Functions.GetSource(src)]
	end
end

function AQCore.Functions.GetPlayerByCitizenId(citizenid)
	for src, player in pairs(AQCore.Players) do
		local cid = citizenid
		if AQCore.Players[src].PlayerData.citizenid == cid then
			return AQCore.Players[src]
		end
	end
	return nil
end

function AQCore.Functions.GetPlayerByPhone(number)
	for src, player in pairs(AQCore.Players) do
		local cid = citizenid
		if AQCore.Players[src].PlayerData.charinfo.phone == number then
			return AQCore.Players[src]
		end
	end
	return nil
end

function AQCore.Functions.GetPlayers()
	local sources = {}
	for k, v in pairs(AQCore.Players) do
		table.insert(sources, k)
	end
	return sources
end

-- Will return an array of AQ Player class instances
-- unlike the GetPlayers() wrapper which only returns IDs
function AQCore.Functions.GetAQPlayers()
	return AQCore.Players
end
-- Paychecks (standalone - don't touch)

function PaycheckLoop()
    local Players = AQCore.Functions.GetPlayers()
    for i=1, #Players, 1 do
        local Player = AQCore.Functions.GetPlayer(Players[i])
        if Player.PlayerData.job and Player.PlayerData.job.payment > 0 then
            Player.Functions.AddMoney('bank', Player.PlayerData.job.payment)
            TriggerClientEvent('AQCore:Notify', Players[i], 'Je ontving je salaris of €'..Player.PlayerData.job.payment)
        end
    end
    SetTimeout(AQCore.Config.Money.PayCheckTimeOut * (60 * 1000), PaycheckLoop)
end

-- Callbacks

function AQCore.Functions.CreateCallback(name, cb)
	AQCore.ServerCallbacks[name] = cb
end

function AQCore.Functions.TriggerCallback(name, source, cb, ...)
	local src = source
	if AQCore.ServerCallbacks[name] then
		AQCore.ServerCallbacks[name](src, cb, ...)
	end
end

-- Items

function AQCore.Functions.CreateUseableItem(item, cb)
	AQCore.UseableItems[item] = cb
end

function AQCore.Functions.CanUseItem(item)
	return AQCore.UseableItems[item]
end

function AQCore.Functions.UseItem(source, item)
	local src = source
	AQCore.UseableItems[item.name](src, item)
end

-- Kick Player

function AQCore.Functions.Kick(source, reason, setKickReason, deferrals)
	local src = source
	reason = '\n'..reason..'\n🔸 Bekijk onze discord voor verdere informatie: '..AQCore.Config.Server.discord
	if setKickReason then
		setKickReason(reason)
	end
	CreateThread(function()
		if deferrals then
			deferrals.update(reason)
			Wait(2500)
		end
		if src then
			DropPlayer(src, reason)
		end
		local i = 0
		while (i <= 4) do
			i = i + 1
			while true do
				if src then
					if(GetPlayerPing(src) >= 0) then
						break
					end
					Wait(100)
					CreateThread(function() 
						DropPlayer(src, reason)
					end)
				end
			end
			Wait(5000)
		end
	end)
end

-- Check if player is whitelisted (not used anywhere)

function AQCore.Functions.IsWhitelisted(source)
	local src = source
	local plicense = AQCore.Functions.GetIdentifier(src, 'license')
	local identifiers = GetPlayerIdentifiers(src)
	if AQCore.Config.Server.whitelist then
		local result = exports.oxmysql:fetchSync('SELECT * FROM whitelist WHERE license = ?', {plicense})
		if result[1] then
			for _, id in pairs(identifiers) do
				if result[1].license == id then
					return true
				end
			end
		end
	else
		return true
	end
	return false
end

-- Setting & Removing Permissions

function AQCore.Functions.AddPermission(source, permission)
	local src = source
	local Player = AQCore.Functions.GetPlayer(src)
	local plicense = Player.PlayerData.license
	if Player then
		AQCore.Config.Server.PermissionList[plicense] = {
			license = plicense,
			permission = permission:lower(),
		}
		exports.oxmysql:execute('DELETE FROM permissions WHERE license = ?', {plicense})

		exports.oxmysql:insert('INSERT INTO permissions (name, license, permission) VALUES (?, ?, ?)', {
			GetPlayerName(src),
			plicense,
			permission:lower()
		})

		Player.Functions.UpdatePlayerData()
		TriggerClientEvent('AQCore:Client:OnPermissionUpdate', src, permission)
	end
end

function AQCore.Functions.RemovePermission(source)
	local src = source
	local Player = AQCore.Functions.GetPlayer(src)
	local license = Player.PlayerData.license
	if Player then
		AQCore.Config.Server.PermissionList[license] = nil
		exports.oxmysql:execute('DELETE FROM permissions WHERE license = ?', {license})
		Player.Functions.UpdatePlayerData()
	end
end

-- Checking for Permission Level

function AQCore.Functions.HasPermission(source, permission)
	local src = source
	local license = AQCore.Functions.GetIdentifier(src, 'license')
	local permission = tostring(permission:lower())
	if permission == 'user' then
		return true
	else
		if AQCore.Config.Server.PermissionList[license] then
			if AQCore.Config.Server.PermissionList[license].license == license then
				if AQCore.Config.Server.PermissionList[license].permission == permission or AQCore.Config.Server.PermissionList[license].permission == 'god' then
					return true
				end
			end
		end
	end
	return false
end

function AQCore.Functions.GetPermission(source)
	local src = source
	local license = AQCore.Functions.GetIdentifier(src, 'license')
	if license then
		if AQCore.Config.Server.PermissionList[license] then
			if AQCore.Config.Server.PermissionList[license].license == license then
				return AQCore.Config.Server.PermissionList[license].permission
			end
		end
	end
	return 'user'
end

-- Opt in or out of admin reports

function AQCore.Functions.IsOptin(source)
	local src = source
	local license = AQCore.Functions.GetIdentifier(src, 'license')
	if AQCore.Functions.HasPermission(src, 'admin') then
		retval = AQCore.Config.Server.PermissionList[license].optin
		return true
	end
	return false
end

function AQCore.Functions.ToggleOptin(source)
	local src = source
	local license = AQCore.Functions.GetIdentifier(src, 'license')
	if AQCore.Functions.HasPermission(src, 'admin') then
		AQCore.Config.Server.PermissionList[license].optin = not AQCore.Config.Server.PermissionList[license].optin
	end
end

-- Check if player is banned

function AQCore.Functions.IsPlayerBanned(source)
	local src = source
	local retval = false
	local message = ''
	local plicense = AQCore.Functions.GetIdentifier(src, 'license')
    local result = exports.oxmysql:fetchSync('SELECT * FROM bans WHERE license = ?', {plicense})
    if result[1] then
        if os.time() < result[1].expire then
            retval = true
            local timeTable = os.date('*t', tonumber(result.expire))
            message = 'Je bent verbannen van deze server:\n'..result[1].reason..'\nban vervalt over '..timeTable.day.. '/' .. timeTable.month .. '/' .. timeTable.year .. ' ' .. timeTable.hour.. ':' .. timeTable.min .. '\n'
        else
            exports.oxmysql:execute('DELETE FROM bans WHERE id = ?', {result[1].id})
        end
    end
	return retval, message
end

-- Check for duplicate license

function AQCore.Functions.IsLicenseInUse(license)
    local players = GetPlayers()
    for _, player in pairs(players) do
        local identifiers = GetPlayerIdentifiers(player)
        for _, id in pairs(identifiers) do
            if string.find(id, 'license') then
                local playerLicense = id
                if playerLicense == license then
                    return true
                end
            end
        end
    end
    return false
end
