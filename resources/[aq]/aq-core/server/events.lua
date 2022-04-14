-- Event Handler

AddEventHandler('playerDropped', function()
	local src = source
	if AQCore.Players[src] then
		local Player = AQCore.Players[src]
		TriggerEvent('aq-log:server:CreateLog', 'joinleave', 'Dropped', 'red', '**'.. GetPlayerName(src) .. '** ('..Player.PlayerData.license..') left..')
		Player.Functions.Save()
		AQCore.Players[src] = nil
	end
end)

AddEventHandler('chatMessage', function(source, n, message)
	local src = source
	if string.sub(message, 1, 1) == '/' then
		local args = AQCore.Shared.SplitStr(message, ' ')
		local command = string.gsub(args[1]:lower(), '/', '')
		CancelEvent()
		if AQCore.Commands.List[command] then
			local Player = AQCore.Functions.GetPlayer(src)
			if Player then
				local isGod = AQCore.Functions.HasPermission(src, 'god')
				local hasPerm = AQCore.Functions.HasPermission(src, AQCore.Commands.List[command].permission)
				local isPrincipal = IsPlayerAceAllowed(src, 'command')
				table.remove(args, 1)
				if isGod or hasPerm or isPrincipal then
					if (AQCore.Commands.List[command].argsrequired and #AQCore.Commands.List[command].arguments ~= 0 and args[#AQCore.Commands.List[command].arguments] == nil) then
					    TriggerClientEvent('AQCore:Notify', src, 'All argumenten moeten ingevuld zijn!', 'error')
					else
						AQCore.Commands.List[command].callback(src, args)
					end
				else
					TriggerClientEvent('AQCore:Notify', src, 'geen toegang tot deze command', 'error')
				end
			end
		end
	end
end)

-- Player Connecting

local function OnPlayerConnecting(name, setKickReason, deferrals)
    local player = source
    local license
    local identifiers = GetPlayerIdentifiers(player)
    deferrals.defer()

    -- mandatory wait!
    Wait(0)

    deferrals.update(string.format('Hey %s. Rockstar-licentie licentie controleren', name))

    for _, v in pairs(identifiers) do
        if string.find(v, 'license') then
            license = v
            break
        end
    end

    -- mandatory wait!
    Wait(2500)

    deferrals.update(string.format('Hey %s. We kijken of je niet geband ben.', name))

    local isBanned, Reason = AQCore.Functions.IsPlayerBanned(player)
    local isLicenseAlreadyInUse = AQCore.Functions.IsLicenseInUse(license)

    Wait(2500)

    deferrals.update(string.format('Welkom %s op AquaRP.', name))

    if not license then
        deferrals.done('Geen geldige Rockstar License gevonden')
    elseif isBanned then
	    deferrals.done(Reason)
    elseif isLicenseAlreadyInUse then
        deferrals.done('Dubbele Rockstar License gevonden')
    else
        deferrals.done()
        Wait(1000)
        TriggerEvent('aq-queue:playerConnect', name, setKickReason, deferrals)
    end
    --Add any additional defferals you may need!
end

AddEventHandler('playerConnecting', OnPlayerConnecting)

-- Open & Close Server (prevents players from joining)

RegisterNetEvent('AQCore:server:CloseServer', function(reason)
	local src = source
    if AQCore.Functions.HasPermission(src, 'admin') or AQCore.Functions.HasPermission(src, 'god') then
        local reason = reason or 'Geen reden opgegeven'
        AQCore.Config.Server.closed = true
        AQCore.Config.Server.closedReason = reason
        TriggerClientEvent('aqadmin:client:SetServerStatus', -1, true)
	else
		AQCore.Functions.Kick(src, 'U heeft hier geen rechten voor..', nil, nil)
    end
end)

RegisterNetEvent('AQCore:server:OpenServer', function()
	local src = source
    if AQCore.Functions.HasPermission(src, 'admin') or AQCore.Functions.HasPermission(src, 'god') then
        AQCore.Config.Server.closed = false
        TriggerClientEvent('aqadmin:client:SetServerStatus', -1, false)
    else
        AQCore.Functions.Kick(src, 'U heeft hier geen rechten voor..', nil, nil)
    end
end)

-- Callbacks

RegisterNetEvent('AQCore:Server:TriggerCallback', function(name, ...)
	local src = source
	AQCore.Functions.TriggerCallback(name, src, function(...)
		TriggerClientEvent('AQCore:Client:TriggerCallback', src, name, ...)
	end, ...)
end)

-- Player

RegisterNetEvent('AQCore:UpdatePlayer', function()
	local src = source
	local Player = AQCore.Functions.GetPlayer(src)
	if Player then
		local newHunger = Player.PlayerData.metadata['hunger'] - AQCore.Config.Player.HungerRate
		local newThirst = Player.PlayerData.metadata['thirst'] - AQCore.Config.Player.ThirstRate
		if newHunger <= 0 then newHunger = 0 end
		if newThirst <= 0 then newThirst = 0 end
		Player.Functions.SetMetaData('thirst', newThirst)
		Player.Functions.SetMetaData('hunger', newHunger)
		TriggerClientEvent('hud:client:UpdateNeeds', src, newHunger, newThirst)
		Player.Functions.Save()
	end
end)

RegisterNetEvent('AQCore:Server:SetMetaData', function(meta, data)
    local src = source
	local Player = AQCore.Functions.GetPlayer(src)
	if meta == 'hunger' or meta == 'thirst' then
		if data > 100 then
			data = 100
		end
	end
	if Player then
		Player.Functions.SetMetaData(meta, data)
	end
	TriggerClientEvent('hud:client:UpdateNeeds', src, Player.PlayerData.metadata['hunger'], Player.PlayerData.metadata['thirst'])
end)

RegisterNetEvent('AQCore:ToggleDuty', function()
	local src = source
	local Player = AQCore.Functions.GetPlayer(src)
	if Player.PlayerData.job.onduty then
		Player.Functions.SetJobDuty(false)
		TriggerClientEvent('AQCore:Notify', src, 'Je bent uit dienst!')
	else
		Player.Functions.SetJobDuty(true)
		TriggerClientEvent('AQCore:Notify', src, 'Je bent indienst!')
	end
	TriggerClientEvent('AQCore:Client:SetDuty', src, Player.PlayerData.job.onduty)
end)

-- Items

RegisterNetEvent('AQCore:Server:UseItem', function(item)
	local src = source
	if item and item.amount > 0 then
		if AQCore.Functions.CanUseItem(item.name) then
			AQCore.Functions.UseItem(src, item)
		end
	end
end)

RegisterNetEvent('AQCore:Server:RemoveItem', function(itemName, amount, slot)
	local src = source
	local Player = AQCore.Functions.GetPlayer(src)
	Player.Functions.RemoveItem(itemName, amount, slot)
end)

RegisterNetEvent('AQCore:Server:AddItem', function(itemName, amount, slot, info)
	local src = source
	local Player = AQCore.Functions.GetPlayer(src)
	Player.Functions.AddItem(itemName, amount, slot, info)
end)

-- Non-Chat Command Calling (ex: aq-adminmenu)

RegisterNetEvent('AQCore:CallCommand', function(command, args)
	local src = source
	if AQCore.Commands.List[command] then
		local Player = AQCore.Functions.GetPlayer(src)
		if Player then
			local isGod = AQCore.Functions.HasPermission(src, 'god')
            local hasPerm = AQCore.Functions.HasPermission(src, AQCore.Commands.List[command].permission)
            local isPrincipal = IsPlayerAceAllowed(src, 'command')
			if (AQCore.Commands.List[command].permission == Player.PlayerData.job.name) or isGod or hasPerm or isPrincipal then
				if (AQCore.Commands.List[command].argsrequired and #AQCore.Commands.List[command].arguments ~= 0 and args[#AQCore.Commands.List[command].arguments] == nil) then
					TriggerClientEvent('AQCore:Notify', src, 'All arguments must be filled out!', 'error')
				else
					AQCore.Commands.List[command].callback(src, args)
				end
			else
				TriggerClientEvent('AQCore:Notify', src, 'Geen toegang tot deze command', 'error')
			end
		end
	end
end)

-- Has Item Callback (can also use client function - AQCore.Functions.HasItem(item))

AQCore.Functions.CreateCallback('AQCore:HasItem', function(source, cb, items, amount)
	local src = source
	local retval = false
	local Player = AQCore.Functions.GetPlayer(src)
	if Player then
		if type(items) == 'table' then
			local count = 0
            local finalcount = 0
			for k, v in pairs(items) do
				if type(k) == 'string'  then
					finalcount = 0
					for i, _ in pairs(items) do
						if i then finalcount = finalcount + 1 end
					end
					local item = Player.Functions.GetItemByName(k)
					if item then
						if item.amount >= v then
							count = count + 1
							if count == finalcount then
								retval = true
							end
						end
					end
				else
                    finalcount = #items
					local item = Player.Functions.GetItemByName(v)
					if item then
						if amount then
							if item.amount >= amount then
								count = count + 1
								if count == finalcount then
									retval = true
								end
							end
						else
							count = count + 1
							if count == finalcount then
								retval = true
							end
						end
					end
				end
			end
		else
			local item = Player.Functions.GetItemByName(items)
			if item then
				if amount then
					if item.amount >= amount then
						retval = true
					end
				else
					retval = true
				end
			end
		end
	end
	cb(retval)
end)