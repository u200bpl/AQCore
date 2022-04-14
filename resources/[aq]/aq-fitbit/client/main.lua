local inWatch = false
local isLoggedIn = false

RegisterNetEvent("AQCore:Client:OnPlayerUnload")
AddEventHandler("AQCore:Client:OnPlayerUnload", function()
    isLoggedIn = false
end)

RegisterNetEvent("AQCore:Client:OnPlayerLoaded")
AddEventHandler("AQCore:Client:OnPlayerLoaded", function()
    isLoggedIn = true
end)

function openWatch()
    SendNUIMessage({
        action = "openWatch",
        watchData = {}
    })
    SetNuiFocus(true, true)
    inWatch = true
end

function closeWatch()
    SetNuiFocus(false, false)
end

RegisterNUICallback('close', function()
    closeWatch()
end)

RegisterNetEvent('aq-fitbit:use')
AddEventHandler('aq-fitbit:use', function()
    openWatch(true)
end)

RegisterNUICallback('setFoodWarning', function(data)
    local foodValue = tonumber(data.value)

    TriggerServerEvent('aq-fitbit:server:setValue', 'food', foodValue)

    AQCore.Functions.Notify('Fitbit: Hongerwaarschuwing ingesteld op '..foodValue..'%')
end)

RegisterNUICallback('setThirstWarning', function(data)
    local thirstValue = tonumber(data.value)

    TriggerServerEvent('aq-fitbit:server:setValue', 'thirst', thirstValue)

    AQCore.Functions.Notify('Fitbit: Dorstwaarschuwing ingesteld op '..thirstValue..'%')
end)

Citizen.CreateThread(function()
    while true do

        Citizen.Wait(5 * 60 * 1000)
        
        if isLoggedIn then
            AQCore.Functions.TriggerCallback('aq-fitbit:server:HasFitbit', function(hasItem)
                if hasItem then
                    local PlayerData = AQCore.Functions.GetPlayerData()
                    if PlayerData.metadata["fitbit"].food ~= nil then
                        if PlayerData.metadata["hunger"] < PlayerData.metadata["fitbit"].food then
                            TriggerEvent("chatMessage", "FITBIT ", "warning", "Je honger is "..round(PlayerData.metadata["hunger"], 2).."%")
                            PlaySound(-1, "Event_Start_Text", "GTAO_FM_Events_Soundset", 0, 0, 1)
                        end
                    end
        
                    if PlayerData.metadata["fitbit"].thirst ~= nil then
                        if PlayerData.metadata["thirst"] < PlayerData.metadata["fitbit"].thirst  then
                            TriggerEvent("chatMessage", "FITBIT ", "warning", "Je dorst is "..round(PlayerData.metadata["thirst"], 2).."%")
                            PlaySound(-1, "Event_Start_Text", "GTAO_FM_Events_Soundset", 0, 0, 1)
                        end
                    end
                end
            end, "fitbit")
        end
    end
end)

function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end
