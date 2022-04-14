local isLoggedIn = false
local requiredItemsShowed = false

function DrawText3Ds(coords, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(coords.x, coords.y, coords.z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

Citizen.CreateThread(function()
	while true do
		local inRange = false

		if AQCore ~= nil then
			local requiredItems = {
				[1] = {name = AQCore.Shared.Items["cryptostick"]["name"], image = AQCore.Shared.Items["cryptostick"]["image"]},
			}
			if isLoggedIn then
				local ped = PlayerPedId()
				local pos = GetEntityCoords(ped)
				local dist = #(pos - Crypto.Exchange.coords)

				if dist < 15 then
					inRange = true
					
					if dist < 1.5 then
						if not Crypto.Exchange.RebootInfo.state then
							DrawText3Ds(Crypto.Exchange.coords, '~g~E~w~ - Gebruik USB')
							if not requiredItemsShowed then
								requiredItemsShowed = true
								TriggerEvent('inventory:client:requiredItems', requiredItems, true)
							end
							
							if IsControlJustPressed(0, 38) then
								AQCore.Functions.TriggerCallback('aq-crypto:server:HasSticky', function(HasItem)
									if HasItem then
										TriggerEvent("mhacking:show")
										TriggerEvent("mhacking:start", math.random(4, 6), 45, HackingSuccess)
									else
										AQCore.Functions.Notify('Je hebt geen Cryptostick ..', 'error')
									end
								end)
							end
						else
							DrawText3Ds(Crypto.Exchange.coords, 'Systeem wordt opnieuw opgestart - '..Crypto.Exchange.RebootInfo.percentage..'%')
						end
					else
						if requiredItemsShowed then
							requiredItemsShowed = false
							TriggerEvent('inventory:client:requiredItems', requiredItems, false)
						end
					end
				end
			end
		end

		if not inRange then
			Citizen.Wait(5000)
		end

		Citizen.Wait(3)
    end
end)

function ExchangeSuccess()
	TriggerServerEvent('aq-crypto:server:ExchangeSuccess', math.random(1, 10))
end

function ExchangeFail()
	local Odd = 5
	local RemoveChance = math.random(1, Odd)
	local LosingNumber = math.random(1, Odd)

	if RemoveChance == LosingNumber then
		TriggerServerEvent('aq-crypto:server:ExchangeFail')
		TriggerServerEvent('aq-crypto:server:SyncReboot')
	end
end

RegisterNetEvent('aq-crypto:client:SyncReboot')
AddEventHandler('aq-crypto:client:SyncReboot', function()
	Crypto.Exchange.RebootInfo.state = true
	SystemCrashCooldown()
end)

function SystemCrashCooldown()
	Citizen.CreateThread(function()
		while Crypto.Exchange.RebootInfo.state do

			if (Crypto.Exchange.RebootInfo.percentage + 1) <= 100 then
				Crypto.Exchange.RebootInfo.percentage = Crypto.Exchange.RebootInfo.percentage + 1
				TriggerServerEvent('aq-crypto:server:Rebooting', true, Crypto.Exchange.RebootInfo.percentage)
			else
				Crypto.Exchange.RebootInfo.percentage = 0
				Crypto.Exchange.RebootInfo.state = false
				TriggerServerEvent('aq-crypto:server:Rebooting', false, 0)
			end

			Citizen.Wait(1200)
		end
	end)
end

function HackingSuccess(success, timeremaining)
    if success then
        TriggerEvent('mhacking:hide')
        ExchangeSuccess()
    else
		TriggerEvent('mhacking:hide')
		ExchangeFail()
	end
end

RegisterNetEvent('AQCore:Client:OnPlayerLoaded')
AddEventHandler('AQCore:Client:OnPlayerLoaded', function()
	isLoggedIn = true
	TriggerServerEvent('aq-crypto:server:FetchWorth')
	TriggerServerEvent('aq-crypto:server:GetRebootState')
end)

RegisterNetEvent('aq-crypto:client:UpdateCryptoWorth')
AddEventHandler('aq-crypto:client:UpdateCryptoWorth', function(crypto, amount, history)
	Crypto.Worth[crypto] = amount
	if history ~= nil then
		Crypto.History[crypto] = history
	end
end)

RegisterNetEvent('aq-crypto:client:GetRebootState')
AddEventHandler('aq-crypto:client:GetRebootState', function(RebootInfo)
	if RebootInfo.state then
		Crypto.Exchange.RebootInfo.state = RebootInfo.state
		Crypto.Exchange.RebootInfo.percentage = RebootInfo.percentage
		SystemCrashCooldown()
	end
end)
