local PlayerInjuries = {}
local PlayerWeaponWounds = {}
local AQCore = exports['aq-core']:GetCoreObject()
-- Events

RegisterNetEvent('hospital:server:SendToBed', function(bedId, isRevive)
	local src = source
	local Player = AQCore.Functions.GetPlayer(src)
	TriggerClientEvent('hospital:client:SendToBed', src, bedId, Config.Locations["beds"][bedId], isRevive)
	TriggerClientEvent('hospital:client:SetBed', -1, bedId, true)
	Player.Functions.RemoveMoney("bank", Config.BillCost , "respawned-at-hospital")
	TriggerEvent('aq-bossmenu:server:addAccountMoney', "ambulance", Config.BillCost)
	TriggerClientEvent('hospital:client:SendBillEmail', src, Config.BillCost)
end)

RegisterNetEvent('hospital:server:RespawnAtHospital', function()
	local src = source
	local Player = AQCore.Functions.GetPlayer(src)
	for k, v in pairs(Config.Locations["beds"]) do
		TriggerClientEvent('hospital:client:SendToBed', src, k, v, true)
		TriggerClientEvent('hospital:client:SetBed', -1, k, true)
		if Config.WipeInventoryOnRespawn then
			Player.Functions.ClearInventory()
			exports.oxmysql:execute('UPDATE players SET inventory = ? WHERE citizenid = ?', { json.encode({}), Player.PlayerData.citizenid })
			TriggerClientEvent('AQCore:Notify', src, 'Alles is afgepakt..', 'error')
		end
		Player.Functions.RemoveMoney("bank", Config.BillCost, "respawned-at-hospital")
		TriggerEvent('aq-bossmenu:server:addAccountMoney', "ambulance", Config.BillCost)
		TriggerClientEvent('hospital:client:SendBillEmail', src, Config.BillCost)
		return
	end
end)

RegisterNetEvent('hospital:server:LeaveBed', function(id)
    TriggerClientEvent('hospital:client:SetBed', -1, id, false)
end)

RegisterNetEvent('hospital:server:SyncInjuries', function(data)
    local src = source
    PlayerInjuries[src] = data
end)


RegisterNetEvent('hospital:server:SetWeaponDamage', function(data)
	local src = source
	local Player = AQCore.Functions.GetPlayer(src)
	if Player then
		PlayerWeaponWounds[Player.PlayerData.source] = data
	end
end)

RegisterNetEvent('hospital:server:RestoreWeaponDamage', function()
	local src = source
	local Player = AQCore.Functions.GetPlayer(src)
	PlayerWeaponWounds[Player.PlayerData.source] = nil
end)

RegisterNetEvent('hospital:server:SetDeathStatus', function(isDead)
	local src = source
	local Player = AQCore.Functions.GetPlayer(src)
	if Player then
		Player.Functions.SetMetaData("isdead", isDead)
	end
end)

RegisterNetEvent('hospital:server:SetLaststandStatus', function(bool)
	local src = source
	local Player = AQCore.Functions.GetPlayer(src)
	if Player then
		Player.Functions.SetMetaData("inlaststand", bool)
	end
end)

RegisterNetEvent('hospital:server:SetArmor', function(amount)
	local src = source
	local Player = AQCore.Functions.GetPlayer(src)
	if Player then
		Player.Functions.SetMetaData("armor", amount)
	end
end)

RegisterNetEvent('hospital:server:TreatWounds', function(playerId)
	local src = source
	local Player = AQCore.Functions.GetPlayer(src)
	local Patient = AQCore.Functions.GetPlayer(playerId)
	if Patient then
		if Player.PlayerData.job.name =="ambulance" then
			Player.Functions.RemoveItem('bandage', 1)
			TriggerClientEvent('inventory:client:ItemBox', src, AQCore.Shared.Items['bandage'], "remove")
			TriggerClientEvent("hospital:client:HealInjuries", Patient.PlayerData.source, "full")
		end
	end
end)

RegisterNetEvent('hospital:server:SetDoctor', function()
	local amount = 0
	for k, v in pairs(AQCore.Functions.GetPlayers()) do
        local Player = AQCore.Functions.GetPlayer(v)
        if Player then
            if (Player.PlayerData.job.name =="ambulance" and Player.PlayerData.job.onduty) then
                amount = amount + 1
            end
        end
	end
	TriggerClientEvent("hospital:client:SetDoctorCount", -1, amount)
end)

RegisterNetEvent('hospital:server:RevivePlayer', function(playerId, isOldMan)
	local src = source
	local Player = AQCore.Functions.GetPlayer(src)
	local Patient = AQCore.Functions.GetPlayer(playerId)
	local oldMan = isOldMan or false
	if Patient then
		if oldMan then
			if Player.Functions.RemoveMoney("cash", 5000, "revived-player") then
				Player.Functions.RemoveItem('firstaid', 1)
				TriggerClientEvent('inventory:client:ItemBox', src, AQCore.Shared.Items['firstaid'], "remove")
				TriggerClientEvent('hospital:client:Revive', Patient.PlayerData.source)
			else
				TriggerClientEvent('AQCore:Notify', src, "Je hebt niet genoeg geld..", "error")
			end
		else
			Player.Functions.RemoveItem('firstaid', 1)
			TriggerClientEvent('inventory:client:ItemBox', src, AQCore.Shared.Items['firstaid'], "remove")
			TriggerClientEvent('hospital:client:Revive', Patient.PlayerData.source)
		end
	end
end)

RegisterNetEvent('hospital:server:SendDoctorAlert', function()
	local src = source
	for k, v in pairs(AQCore.Functions.GetPlayers()) do
		local Player = AQCore.Functions.GetPlayer(v)
		if Player then
			if (Player.PlayerData.job.name =="ambulance" and Player.PlayerData.job.onduty) then
				TriggerClientEvent("hospital:client:SendAlert", v, "Er is een dokter nodig op het ziekenhuis!")
			end
		end
	end
end)

RegisterNetEvent('hospital:server:MakeDeadCall', function(blipSettings, gender, street1, street2)
	local src = source
	local genderstr = "Man"

	if gender == 1 then genderstr = "Woman" end

	if street2 then
		TriggerClientEvent("112:client:SendAlert", -1, "Een ".. genderstr .." is gewond op " ..street1 .. " "..street2, blipSettings)
		TriggerClientEvent('aq-policealerts:client:AddPoliceAlert', -1, {
            timeOut = 5000,
            alertTitle = "Injured person",
            details = {
                [1] = {
                    icon = '<i class="fas fa-venus-mars"></i>',
                    detail = genderstr,
                },
                [2] = {
                    icon = '<i class="fas fa-globe-europe"></i>',
                    detail = street1.. ' '..street2,
                },
            },
            callSign = nil,
        }, true)
	else
		TriggerClientEvent("112:client:SendAlert", -1, "A ".. genderstr .." is injured at "..street1, blipSettings)
		TriggerClientEvent('aq-policealerts:client:AddPoliceAlert', -1, {
            timeOut = 5000,
            alertTitle = "Gewonde persoon",
            details = {
                [1] = {
                    icon = '<i class="fas fa-venus-mars"></i>',
                    detail = genderstr,
                },
                [2] = {
                    icon = '<i class="fas fa-globe-europe"></i>',
                    detail = street1,
                },
            },
            callSign = nil,
        }, true)
	end
end)

RegisterNetEvent('hospital:server:UseFirstAid', function(targetId)
	local src = source
	local Target = AQCore.Functions.GetPlayer(targetId)
	if Target then
		TriggerClientEvent('hospital:client:CanHelp', targetId, src)
	end
end)

RegisterNetEvent('hospital:server:CanHelp', function(helperId, canHelp)
	local src = source
	if canHelp then
		TriggerClientEvent('hospital:client:HelpPerson', helperId, src)
	else
		TriggerClientEvent('AQCore:Notify', helperId, "Je kan deze persoon niet helpen..", "error")
	end
end)

-- Callbacks

AQCore.Functions.CreateCallback('hospital:GetDoctors', function(source, cb)
	local amount = 0
	for k, v in pairs(AQCore.Functions.GetPlayers()) do
		local Player = AQCore.Functions.GetPlayer(v)
		if Player then
			if (Player.PlayerData.job.name =="ambulance" and Player.PlayerData.job.onduty) then
				amount = amount + 1
			end
		end
	end
	cb(amount)
end)

AQCore.Functions.CreateCallback('hospital:GetPlayerStatus', function(source, cb, playerId)
	local Player = AQCore.Functions.GetPlayer(playerId)
	local injuries = {}
	injuries["WEAPONWOUNDS"] = {}
	if Player then
		if PlayerInjuries[Player.PlayerData.source] then
			if (PlayerInjuries[Player.PlayerData.source].isBleeding > 0) then
				injuries["BLEED"] = PlayerInjuries[Player.PlayerData.source].isBleeding
			end
			for k, v in pairs(PlayerInjuries[Player.PlayerData.source].limbs) do
				if PlayerInjuries[Player.PlayerData.source].limbs[k].isDamaged then
					injuries[k] = PlayerInjuries[Player.PlayerData.source].limbs[k]
				end
			end
		end
		if PlayerWeaponWounds[Player.PlayerData.source] then
			for k, v in pairs(PlayerWeaponWounds[Player.PlayerData.source]) do
				injuries["WEAPONWOUNDS"][k] = v
			end
		end
	end
    cb(injuries)
end)

AQCore.Functions.CreateCallback('hospital:GetPlayerBleeding', function(source, cb)
	local src = source
	if PlayerInjuries[src] and PlayerInjuries[src].isBleeding then
		cb(PlayerInjuries[src].isBleeding)
	else
		cb(nil)
	end
end)

AQCore.Functions.CreateCallback('hospital:server:HasBandage', function(source, cb)
	local src = source
    local player = AQCore.Functions.GetPlayer(src)
    local bandage = player.Functions.GetItemByName("bandage")
    if bandage ~= nil then cb(true) else cb(false) end
end)

AQCore.Functions.CreateCallback('hospital:server:HasFirstAid', function(source, cb)
	local src = source
    local player = AQCore.Functions.GetPlayer(src)
    local firstaid = player.Functions.GetItemByName("firstaid")
    if firstaid ~= nil then cb(true) else cb(false) end
end)

-- Commands

AQCore.Commands.Add("status", "Bekijk iemands health", {}, false, function(source, args)
	local src = source
	local Player = AQCore.Functions.GetPlayer(src)
	if Player.PlayerData.job.name == "ambulance" then
		TriggerClientEvent("hospital:client:CheckStatus", src)
	else
		TriggerClientEvent('AQCore:Notify', src, "Je bent geen ambulance", "error")
	end
end)

AQCore.Commands.Add("heal", "Heal A Player", {}, false, function(source, args)
	local src = source
	local Player = AQCore.Functions.GetPlayer(src)
	if Player.PlayerData.job.name == "ambulance" then
		TriggerClientEvent("hospital:client:TreatWounds", src)
	else
		TriggerClientEvent('AQCore:Notify', src, "Je bent geen ambulance", "error")
	end
end)

AQCore.Commands.Add("revivep", "Revive A Player", {}, false, function(source, args)
	local src = source
	local Player = AQCore.Functions.GetPlayer(src)
	if Player.PlayerData.job.name == "ambulance" then
		TriggerClientEvent("hospital:client:RevivePlayer", src)
	else
		TriggerClientEvent('AQCore:Notify', src, "Je bent geen ambulance", "error")
	end
end)

AQCore.Commands.Add("revive", "Revive jezelf of iemand anders (Admin Only)", {{name="id", help="Player ID (optioneel)"}}, false, function(source, args)
	local src = source
	if args[1] then
		local Player = AQCore.Functions.GetPlayer(tonumber(args[1]))
		if Player then
			TriggerClientEvent('hospital:client:Revive', Player.PlayerData.source)
		else
			TriggerClientEvent('AQCore:Notify', src, "Speler is niet online", "error")
		end
	else
		TriggerClientEvent('hospital:client:Revive', src)
	end
end, "admin")

AQCore.Commands.Add("setpain", "Zet de pijn level van jezelf of iemand anders (Admin Only)", {{name="id", help="Player ID (optioneel)"}}, false, function(source, args)
	local src = source
	if args[1] then
		local Player = AQCore.Functions.GetPlayer(tonumber(args[1]))
		if Player then
			TriggerClientEvent('hospital:client:SetPain', Player.PlayerData.source)
		else
			TriggerClientEvent('AQCore:Notify', src, "Speler niet online", "error")
		end
	else
		TriggerClientEvent('hospital:client:SetPain', src)
	end
end, "admin")

AQCore.Commands.Add("kill", "Kill jezelf of iemand anders (Admin Only)", {{name="id", help="Player ID (optioneel)"}}, false, function(source, args)
	local src = source
	if args[1] then
		local Player = AQCore.Functions.GetPlayer(tonumber(args[1]))
		if Player then
			TriggerClientEvent('hospital:client:KillPlayer', Player.PlayerData.source)
		else
			TriggerClientEvent('AQCore:Notify', src, "Speler niet online", "error")
		end
	else
		TriggerClientEvent('hospital:client:KillPlayer', src)
	end
end, "admin")

-- Items

AQCore.Functions.CreateUseableItem("bandage", function(source, item)
	local src = source
	local Player = AQCore.Functions.GetPlayer(src)
	if Player.Functions.GetItemByName(item.name) ~= nil then
		TriggerClientEvent("hospital:client:UseBandage", src)
	end
end)

AQCore.Functions.CreateUseableItem("painkillers", function(source, item)
	local src = source
	local Player = AQCore.Functions.GetPlayer(src)
	if Player.Functions.GetItemByName(item.name) ~= nil then
		TriggerClientEvent("hospital:client:UsePainkillers", src)
	end
end)

AQCore.Functions.CreateUseableItem("firstaid", function(source, item)
	local src = source
	local Player = AQCore.Functions.GetPlayer(src)
	if Player.Functions.GetItemByName(item.name) ~= nil then
		TriggerClientEvent("hospital:client:UseFirstAid", src)
	end
end)
