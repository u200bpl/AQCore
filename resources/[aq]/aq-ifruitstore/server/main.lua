local alarmTriggered = false
local certificateAmount = 43

RegisterServerEvent('aq-ifruitstore:server:LoadLocationList')
AddEventHandler('aq-ifruitstore:server:LoadLocationList', function()
    local src = source 
    TriggerClientEvent("aq-ifruitstore:server:LoadLocationList", src, Config.Locations)
end)

RegisterServerEvent('aq-ifruitstore:server:setSpotState')
AddEventHandler('aq-ifruitstore:server:setSpotState', function(stateType, state, spot)
    if stateType == "isBusy" then
        Config.Locations["takeables"][spot].isBusy = state
    elseif stateType == "isDone" then
        Config.Locations["takeables"][spot].isDone = state
    end
    TriggerClientEvent('aq-ifruitstore:client:setSpotState', -1, stateType, state, spot)
end)

RegisterServerEvent('aq-ifruitstore:server:SetThermiteStatus')
AddEventHandler('aq-ifruitstore:server:SetThermiteStatus', function(stateType, state)
    if stateType == "isBusy" then
        Config.Locations["thermite"].isBusy = state
    elseif stateType == "isDone" then
        Config.Locations["thermite"].isDone = state
    end
    TriggerClientEvent('aq-ifruitstore:client:SetThermiteStatus', -1, stateType, state)
end)

RegisterServerEvent('aq-ifruitstore:server:SafeReward')
AddEventHandler('aq-ifruitstore:server:SafeReward', function()
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    Player.Functions.AddMoney('cash', math.random(1500, 2000), "robbery-ifruit")
    Player.Functions.AddItem("certificate", certificateAmount)
    TriggerClientEvent('inventory:client:ItemBox', src, AQCore.Shared.Items["certificate"], "add")
    Citizen.Wait(500)
    local luck = math.random(1, 100)
    if luck <= 10 then
        Player.Functions.AddItem("goldbar", math.random(1, 2))
        TriggerClientEvent('inventory:client:ItemBox', src, AQCore.Shared.Items["goldbar"], "add")
    end
end)

RegisterServerEvent('aq-ifruitstore:server:SetSafeStatus')
AddEventHandler('aq-ifruitstore:server:SetSafeStatus', function(stateType, state)
    if stateType == "isBusy" then
        Config.Locations["safe"].isBusy = state
    elseif stateType == "isDone" then
        Config.Locations["safe"].isDone = state
    end
    TriggerClientEvent('aq-ifruitstore:client:SetSafeStatus', -1, stateType, state)
end)

RegisterServerEvent('aq-ifruitstore:server:itemReward')
AddEventHandler('aq-ifruitstore:server:itemReward', function(spot)
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    local item = Config.Locations["takeables"][spot].reward

    if Player.Functions.AddItem(item.name, item.amount) then
        TriggerClientEvent('inventory:client:ItemBox', src, AQCore.Shared.Items[item.name], 'add')
    else
        TriggerClientEvent('AQCore:Notify', src, 'Je hebt te veel in je zakken..', 'error')
    end    
end)

RegisterServerEvent('aq-ifruitstore:server:PoliceAlertMessage')
AddEventHandler('aq-ifruitstore:server:PoliceAlertMessage', function(msg, coords, blip)
    local src = source
    for k, v in pairs(AQCore.Functions.GetPlayers()) do
        local Player = AQCore.Functions.GetPlayer(v)
        if Player ~= nil then 
            if (Player.PlayerData.job.name == "police") then  
                TriggerClientEvent("aq-ifruitstore:client:PoliceAlertMessage", v, msg, coords, blip) 
            end
        end
    end
end)

RegisterServerEvent('aq-ifruitstore:server:callCops')
AddEventHandler('aq-ifruitstore:server:callCops', function(streetLabel, coords)
    local place = "iFruitStore"
    local msg = "Het Alram is geactiveerd bij de "..place.. " bij " ..streetLabel

    TriggerClientEvent("aq-ifruitstore:client:robberyCall", -1, streetLabel, coords)

end)