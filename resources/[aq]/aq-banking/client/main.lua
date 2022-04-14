InBank = false
blips = {}
local banks
local showing, playerLoaded = false, false

RegisterNetEvent('AQCore:Client:OnPlayerLoaded')
AddEventHandler('AQCore:Client:OnPlayerLoaded', function()
    playerLoaded = true
    createBlips()
    if showing then
        showing = false
    end
end)

RegisterNetEvent('AQCore:Client:OnPlayerUnload')
AddEventHandler('AQCore:Client:OnPlayerUnload', function()
    playerLoaded = false
    banks = nil
    removeBlips()
    if showing then
        showing = false
    end
end)

RegisterNetEvent('aq-banking:client:syncBanks')
AddEventHandler('aq-banking:client:syncBanks', function(data)
    banks = data
    if showing then
        showing = false
    end
end)

function createBlips()
    for k, v in pairs(Config.BankLocations) do
        blips[k] = AddBlipForCoord(tonumber(v.x), tonumber(v.y), tonumber(v.z))
        SetBlipSprite(blips[k], Config.Blip.blipType)
        SetBlipDisplay(blips[k], 4)
        SetBlipScale  (blips[k], Config.Blip.blipScale)
        SetBlipColour (blips[k], Config.Blip.blipColor)
        SetBlipAsShortRange(blips[k], true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(tostring(Config.Blip.blipName))
        EndTextCommandSetBlipName(blips[k])
    end
end

function removeBlips()
    for k, v in pairs(Config.BankLocations) do
        RemoveBlip(blips[k])
    end
    blips = {}
end

function openAccountScreen()
    AQCore.Functions.TriggerCallback('aq-banking:getBankingInformation', function(banking)
        if banking ~= nil then
            InBank = true
            SetNuiFocus(true, true)
            SendNUIMessage({
                status = "openbank",
                information = banking
            })
        end        
    end)
end

function atmRefresh()
    AQCore.Functions.TriggerCallback('aq-banking:getBankingInformation', function(infor)
        InBank = true
        SetNuiFocus(true, true)
        SendNUIMessage({
            status = "refreshatm",
            information = infor
        })
    end)
end

RegisterNetEvent('aq-banking:openBankScreen')
AddEventHandler('aq-banking:openBankScreen', function()
    openAccountScreen()
end)

local letSleep = true
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        letSleep = true
        if playerLoaded and AQCore ~= nil and not InBank then 
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed, true)
            for k, v in pairs(Config.BankLocations) do 
                local bankDist = #(playerCoords - v)
                if bankDist < 3.0 then
                    letSleep = false
                    if bankDist < 1.5 then
                        DrawText3Ds(v.x, v.y, v.z-0.25, '~g~E~w~ - Bank openen')

                        if IsControlJustPressed(0, 38) then
                            openAccountScreen()
                        end
                    end
                end
            end
        elseif InBank then
            letSleep = false
        end

        if letSleep then
            Citizen.Wait(100)
        end
    end
end)

function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

RegisterNetEvent('aq-banking:transferError')
AddEventHandler('aq-banking:transferError', function(msg)
    SendNUIMessage({
        status = "transferError",
        error = msg
    })
end)

RegisterNetEvent('aq-banking:successAlert')
AddEventHandler('aq-banking:successAlert', function(msg)
    SendNUIMessage({
        status = "successMessage",
        message = msg
    })
end)
