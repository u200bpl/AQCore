RegisterNetEvent('aq-vineyard:server:getGrapes')
AddEventHandler('aq-vineyard:server:getGrapes', function()
    local Player = AQCore.Functions.GetPlayer(source)

    Player.Functions.AddItem("grape", Config.GrapeAmount)
    TriggerClientEvent('inventory:client:ItemBox', source, AQCore.Shared.Items['grape'], "add")
end)

RegisterServerEvent('aq-vineyard:server:loadIngredients') 
AddEventHandler('aq-vineyard:server:loadIngredients', function()
	local xPlayer = AQCore.Functions.GetPlayer(tonumber(source))
    local grape = xPlayer.Functions.GetItemByName('grape')

	if xPlayer.PlayerData.items ~= nil then 
        if grape ~= nil then 
            if grape.amount >= 23 then 

                xPlayer.Functions.RemoveItem("grape", 23, false)
                TriggerClientEvent('inventory:client:ItemBox', source, AQCore.Shared.Items['grape'], "remove")
                
                TriggerClientEvent("aq-vineyard:client:loadIngredients", source)

            else
                TriggerClientEvent('AQCore:Notify', source, "You do not have the correct items", 'error')   
            end
        else
            TriggerClientEvent('AQCore:Notify', source, "You do not have the correct items", 'error')   
        end
	else
		TriggerClientEvent('AQCore:Notify', source, "You Have Nothing...", "error")
	end 
	
end) 

RegisterServerEvent('aq-vineyard:server:grapeJuice') 
AddEventHandler('aq-vineyard:server:grapeJuice', function()
	local xPlayer = AQCore.Functions.GetPlayer(tonumber(source))
    local grape = xPlayer.Functions.GetItemByName('grape')

	if xPlayer.PlayerData.items ~= nil then 
        if grape ~= nil then 
            if grape.amount >= 16 then 

                xPlayer.Functions.RemoveItem("grape", 16, false)
                TriggerClientEvent('inventory:client:ItemBox', source, AQCore.Shared.Items['grape'], "remove")
                
                TriggerClientEvent("aq-vineyard:client:grapeJuice", source)

            else
                TriggerClientEvent('AQCore:Notify', source, "You do not have the correct items", 'error')   
            end
        else
            TriggerClientEvent('AQCore:Notify', source, "You do not have the correct items", 'error')   
        end
	else
		TriggerClientEvent('AQCore:Notify', source, "You Have Nothing...", "error")
	end 
	
end) 

RegisterServerEvent('aq-vineyard:server:receiveWine')
AddEventHandler('aq-vineyard:server:receiveWine', function()
	local xPlayer = AQCore.Functions.GetPlayer(tonumber(source))

	xPlayer.Functions.AddItem("wine", Config.WineAmount, false)
	TriggerClientEvent('inventory:client:ItemBox', source, AQCore.Shared.Items['wine'], "add")
end)

RegisterServerEvent('aq-vineyard:server:receiveGrapeJuice')
AddEventHandler('aq-vineyard:server:receiveGrapeJuice', function()
	local xPlayer = AQCore.Functions.GetPlayer(tonumber(source))

	xPlayer.Functions.AddItem("grapejuice", Config.GrapeJuiceAmount, false)
	TriggerClientEvent('inventory:client:ItemBox', source, AQCore.Shared.Items['grapejuice'], "add")
end)


-- Hire/Fire

--[[ AQCore.Commands.Add("hirevineyard", "Hire a player to the Vineyard!", {{name="id", help="Player ID"}}, true, function(source, args)
    local Player = AQCore.Functions.GetPlayer(tonumber(args[1]))
    local Myself = AQCore.Functions.GetPlayer(source)
    if Player ~= nil then 
        if (Myself.PlayerData.gang.name == "la_familia") then
            Player.Functions.SetJob("vineyard")
        end
    end
end)

AQCore.Commands.Add("firevineyard", "Fire a player to the Vineyard!", {{name="id", help="Player ID"}}, true, function(source, args)
    local Player = AQCore.Functions.GetPlayer(tonumber(args[1]))
    local Myself = AQCore.Functions.GetPlayer(source)
    if Player ~= nil then 
        if (Myself.PlayerData.gang.name == "la_familia") then
            Player.Functions.SetJob("unemployed")
        end
    end
end) ]]