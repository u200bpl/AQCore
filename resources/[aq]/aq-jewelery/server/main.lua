local timeOut = false

local alarmTriggered = false

RegisterServerEvent('aq-jewellery:server:setVitrineState')
AddEventHandler('aq-jewellery:server:setVitrineState', function(stateType, state, k)
    Config.Locations[k][stateType] = state
    TriggerClientEvent('aq-jewellery:client:setVitrineState', -1, stateType, state, k)
end)

RegisterServerEvent('aq-jewellery:server:vitrineReward')
AddEventHandler('aq-jewellery:server:vitrineReward', function()
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    local otherchance = math.random(1, 4)
    local odd = math.random(1, 4)

    if otherchance == odd then
        local item = math.random(1, #Config.VitrineRewards)
        local amount = math.random(Config.VitrineRewards[item]["amount"]["min"], Config.VitrineRewards[item]["amount"]["max"])
        if Player.Functions.AddItem(Config.VitrineRewards[item]["item"], amount) then
            TriggerClientEvent('inventory:client:ItemBox', src, AQCore.Shared.Items[Config.VitrineRewards[item]["item"]], 'add')
        else
            TriggerClientEvent('AQCore:Notify', src, 'Je hebt teveel opzak', 'error')
        end
    else
        local amount = math.random(2, 4)
        if Player.Functions.AddItem("10kgoldchain", amount) then
            TriggerClientEvent('inventory:client:ItemBox', src, AQCore.Shared.Items["10kgoldchain"], 'add')
        else
            TriggerClientEvent('AQCore:Notify', src, 'Je hebt teveel opzak..', 'error')
        end
    end
end)

RegisterServerEvent('aq-jewellery:server:setTimeout')
AddEventHandler('aq-jewellery:server:setTimeout', function()
    if not timeOut then
        timeOut = true
        TriggerEvent('aq-scoreboard:server:SetActivityBusy', "jewellery", true)
        Citizen.CreateThread(function()
            Citizen.Wait(Config.Timeout)

            for k, v in pairs(Config.Locations) do
                Config.Locations[k]["isOpened"] = false
                TriggerClientEvent('aq-jewellery:client:setVitrineState', -1, 'isOpened', false, k)
                TriggerClientEvent('aq-jewellery:client:setAlertState', -1, false)
                TriggerEvent('aq-scoreboard:server:SetActivityBusy', "jewellery", false)
            end
            timeOut = false
            alarmTriggered = false
        end)
    end
end)

RegisterServerEvent('aq-jewellery:server:PoliceAlertMessage')
AddEventHandler('aq-jewellery:server:PoliceAlertMessage', function(title, coords, blip)
    local src = source
    local alertData = {
        title = title,
        coords = {x = coords.x, y = coords.y, z = coords.z},
        description = "Mogelijke overval bij Juwelier<br>Available camera's: 31, 32, 33, 34",
    }

    for k, v in pairs(AQCore.Functions.GetPlayers()) do
        local Player = AQCore.Functions.GetPlayer(v)
        if Player ~= nil then 
            if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
                if blip then
                    if not alarmTriggered then
                        TriggerClientEvent("aq-phone:client:addPoliceAlert", v, alertData)
                        TriggerClientEvent("aq-jewellery:client:PoliceAlertMessage", v, title, coords, blip)
                        alarmTriggered = true
                    end
                else
                    TriggerClientEvent("aq-phone:client:addPoliceAlert", v, alertData)
                    TriggerClientEvent("aq-jewellery:client:PoliceAlertMessage", v, title, coords, blip)
                end
            end
        end
    end
end)

AQCore.Functions.CreateCallback('aq-jewellery:server:getCops', function(source, cb)
	local amount = 0
    for k, v in pairs(AQCore.Functions.GetPlayers()) do
        local Player = AQCore.Functions.GetPlayer(v)
        if Player ~= nil then 
            if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
                amount = amount + 1
            end
        end
	end
	cb(amount)
end)
