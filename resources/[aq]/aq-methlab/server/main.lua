Citizen.CreateThread(function()
    Config.CurrentLab = math.random(1, #Config.Locations["laboratories"])
    --print('Lab entry has been set to location: '..Config.CurrentLab)
end)

AQCore.Functions.CreateCallback('aq-methlab:server:GetData', function(source, cb)
    local LabData = {
        CurrentLab = Config.CurrentLab
    }
    cb(LabData)
end)

AQCore.Functions.CreateUseableItem("labkey", function(source, item)
    local Player = AQCore.Functions.GetPlayer(source)
    local LabKey = item.info.lab ~= nil and item.info.lab or 1

    TriggerClientEvent('aq-methlab:client:UseLabKey', source, LabKey)
end)

function GenerateRandomLab()
    local Lab = math.random(1, #Config.Locations["laboratories"])
    return Lab
end

RegisterServerEvent('aq-methlab:server:loadIngredients')
AddEventHandler('aq-methlab:server:loadIngredients', function()
	local Player = AQCore.Functions.GetPlayer(tonumber(source))
    local hydrochloricacid = Player.Functions.GetItemByName('hydrochloricacid')
    local ephedrine = Player.Functions.GetItemByName('ephedrine')
    local acetone = Player.Functions.GetItemByName('acetone')
	if Player.PlayerData.items ~= nil then 
        if (hydrochloricacid ~= nil and ephedrine ~= nil and acetone ~= nil) then
            if hydrochloricacid.amount >= 0 and ephedrine.amount >= 0 and acetone.amount >= 0 then 
                Player.Functions.RemoveItem("hydrochloricacid", Config.HydrochloricAcid, false)
                TriggerClientEvent('inventory:client:ItemBox', source, AQCore.Shared.Items['hydrochloricacid'], "remove")
                Player.Functions.RemoveItem("ephedrine", Config.Ephedrine, false)
                TriggerClientEvent('inventory:client:ItemBox', source, AQCore.Shared.Items['ephedrine'], "remove")
                Player.Functions.RemoveItem("acetone", Config.Acetone, false)
                TriggerClientEvent('inventory:client:ItemBox', source, AQCore.Shared.Items['acetone'], "remove")
            end
        end
	end
end)

RegisterServerEvent('aq-methlab:server:CheckIngredients')
AddEventHandler('aq-methlab:server:CheckIngredients', function()
	local Player = AQCore.Functions.GetPlayer(tonumber(source))
    local hydrochloricacid = Player.Functions.GetItemByName('hydrochloricacid')
    local ephedrine = Player.Functions.GetItemByName('ephedrine')
    local acetone = Player.Functions.GetItemByName('acetone')
	if Player.PlayerData.items ~= nil then 
        if (hydrochloricacid ~= nil and ephedrine ~= nil and acetone ~= nil) then 
            if hydrochloricacid.amount >= Config.HydrochloricAcid and ephedrine.amount >= Config.Ephedrine and acetone.amount >= Config.Acetone then 
                TriggerClientEvent("aq-methlab:client:loadIngredients", source)
            else
                TriggerClientEvent('AQCore:Notify', source, "U heeft niet de juiste items", 'error')
            end
        else
            TriggerClientEvent('AQCore:Notify', source, "U heeft niet de juiste items", 'error')
        end
	else
		TriggerClientEvent('AQCore:Notify', source, "Je hebt niks...", "error")
	end
end)

RegisterServerEvent('aq-methlab:server:breakMeth')
AddEventHandler('aq-methlab:server:breakMeth', function()
	local Player = AQCore.Functions.GetPlayer(tonumber(source))
    local meth = Player.Functions.GetItemByName('methtray')
    local puremethtray = Player.Functions.GetItemByName('puremethtray')

	if Player.PlayerData.items ~= nil then 
        if (meth ~= nil or puremethtray ~= nil) then 
                TriggerClientEvent("aq-methlab:client:breakMeth", source)
        else
            TriggerClientEvent('AQCore:Notify', source, "U heeft niet de juiste items", 'error')   
        end
	else
		TriggerClientEvent('AQCore:Notify', source, "Je hebt niks...", "error")
	end
end)

RegisterServerEvent('aq-methlab:server:getmethtray')
AddEventHandler('aq-methlab:server:getmethtray', function(amount)
    local Player = AQCore.Functions.GetPlayer(tonumber(source))
    
    local methtray = Player.Functions.GetItemByName('methtray')
    local puremethtray = Player.Functions.GetItemByName('puremethtray')

    if puremethtray ~= nil then 
        if puremethtray.amount >= 1 then 
            Player.Functions.AddItem("puremeth", amount, false)
            TriggerClientEvent('inventory:client:ItemBox', source, AQCore.Shared.Items['puremeth'], "add")

            Player.Functions.RemoveItem("puremethtray", 1, false)
            TriggerClientEvent('inventory:client:ItemBox', source, AQCore.Shared.Items['puremethtray'], "remove")
        end
    elseif methtray ~= nil then 
        if methtray.amount >= 1 then 
            Player.Functions.AddItem("meth", amount, false)
            TriggerClientEvent('inventory:client:ItemBox', source, AQCore.Shared.Items['meth'], "add")

            Player.Functions.RemoveItem("methtray", 1, false)
            TriggerClientEvent('inventory:client:ItemBox', source, AQCore.Shared.Items['methtray'], "remove")
        end
    else
        TriggerClientEvent('AQCore:Notify', source, "U heeft niet de juiste items", 'error')
    end
end)

RegisterServerEvent('aq-methlab:server:receivemethtray')
AddEventHandler('aq-methlab:server:receivemethtray', function()
    local chance = math.random(1, 100)
    print(chance)
    if chance >= 90 then
        local Player = AQCore.Functions.GetPlayer(tonumber(source))
        Player.Functions.AddItem("puremethtray", 3, false)
        TriggerClientEvent('inventory:client:ItemBox', source, AQCore.Shared.Items['puremethtray'], "add")
    else
        local Player = AQCore.Functions.GetPlayer(tonumber(source))
        Player.Functions.AddItem("methtray", 3, false)
        TriggerClientEvent('inventory:client:ItemBox', source, AQCore.Shared.Items['methtray'], "add")
    end
end)