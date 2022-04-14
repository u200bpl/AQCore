-- AFK Kick Time Limit (in seconds)
local group = 'user'
local secondsUntilKick = 1800
local AQCore = exports['aq-core']:GetCoreObject()
local prevPos, time = nil, nil

RegisterNetEvent('AQCore:Client:OnPlayerLoaded')
AddEventHandler('AQCore:Client:OnPlayerLoaded', function()
    AQCore.Functions.TriggerCallback('aq-afkkick:server:GetPermissions', function(UserGroup)
        group = UserGroup
    end)
end)

RegisterNetEvent('AQCore:Client:OnPermissionUpdate')
AddEventHandler('AQCore:Client:OnPermissionUpdate', function(UserGroup)
    group = UserGroup
end)

-- Code
Citizen.CreateThread(function()
    while true do
        Wait(1000)
        local playerPed = PlayerPedId()
        if LocalPlayer.state['isLoggedIn'] then
            if group == 'user' then
                currentPos = GetEntityCoords(playerPed, true)
                if prevPos ~= nil then
                    if currentPos == prevPos then
                        if time ~= nil then
                            if time > 0 then
                                if time == (900) then
                                    AQCore.Functions.Notify('Je bent AFk en word over ' .. math.ceil(time / 60) .. ' minuten gekickt!', 'error', 10000)
                                elseif time == (600) then
                                    AQCore.Functions.Notify('Je bent AFk en word over ' .. math.ceil(time / 60) .. ' minuten gekickt!', 'error', 10000)
                                elseif time == (300) then
                                    AQCore.Functions.Notify('Je bent AFk en word over ' .. math.ceil(time / 60) .. ' minuten gekickt!', 'error', 10000)
                                elseif time == (150) then
                                    AQCore.Functions.Notify('Je bent AFk en word over ' .. math.ceil(time / 60) .. ' minuten gekickt!', 'error', 10000)   
                                elseif time == (60) then
                                    AQCore.Functions.Notify('Je bent AFk en word over ' .. math.ceil(time / 60) .. ' minuten gekickt!', 'error', 10000) 
                                elseif time == (30) then
                                    AQCore.Functions.Notify('Je bent AFk en word over ' .. time .. ' secondes gekickt!', 'error', 10000)  
                                elseif time == (20) then
                                    AQCore.Functions.Notify('Je bent AFk en word over ' .. time .. ' secondes gekickt!', 'error', 10000)    
                                elseif time == (10) then
                                    AQCore.Functions.Notify('Je bent AFk en word over ' .. time .. ' secondes gekickt!', 'error', 10000)                                                                                                            
                                end
                                time = time - 1
                            else
                                TriggerServerEvent('KickForAFK')
                            end
                        else
                            time = secondsUntilKick
                        end
                    else
                        time = secondsUntilKick
                    end
                end
                prevPos = currentPos
            end
        end
    end
end)
