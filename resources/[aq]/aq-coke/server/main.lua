local ItemList = {
    ["cocaleaf"] = "cocaleaf"
}

local DrugList = {
    ["cokebaggy"] = "cokebaggy"
}


RegisterServerEvent('aq-coke:server:grindleaves')
AddEventHandler('aq-coke:server:grindleaves', function()
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    local cocaleaf = Player.Functions.GetItemByName('cocaleaf')

    if Player.PlayerData.items ~= nil then 
        for k, v in pairs(Player.PlayerData.items) do 
            if cocaleaf ~= nil then
                if ItemList[Player.PlayerData.items[k].name] ~= nil then 
                    if Player.PlayerData.items[k].name == "cocaleaf" and Player.PlayerData.items[k].amount >= 2 then 
                        Player.Functions.RemoveItem("cocaleaf", 2)
                        TriggerClientEvent('inventory:client:ItemBox', source, AQCore.Shared.Items['cocaleaf'], "remove")

                        TriggerClientEvent("aq-coke:client:grindleavesMinigame", src)
                    else
                        TriggerClientEvent('AQCore:Notify', src, "Je hebt niet genoeg cocabladeren", 'error')
                        break
                    end
                end
            else
                TriggerClientEvent('AQCore:Notify', src, "Je hebt niet genoeg cocabladeren", 'error')
                break
            end
        end
    end
end)

RegisterServerEvent('aq-coke:server:processCrack')
AddEventHandler('aq-coke:server:processCrack', function()
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    local cokebaggy = Player.Functions.GetItemByName('cokebaggy')

    if Player.PlayerData.gang.name == "ballas" then
        if Player.PlayerData.items ~= nil then 
            if cokebaggy ~= nil then 
                if cokebaggy.amount >= 2 then 

                    Player.Functions.RemoveItem("cokebaggy", 2, false)
                    TriggerClientEvent('inventory:client:ItemBox', src, AQCore.Shared.Items['cokebaggy'], "remove")

                    TriggerClientEvent("aq-coke:client:processCrack", src)
                else
                    TriggerClientEvent('AQCore:Notify', src, "Je hebt niet de goede items", 'error')   
                end
            else
                TriggerClientEvent('AQCore:Notify', src, "Je hebt niet de goede items", 'error')   
            end
        else
            TriggerClientEvent('AQCore:Notify', src, "Je hebt niks...", "error")
        end
    else
        TriggerClientEvent('AQCore:Notify', src, "Je moet misschien met een gang member praten...", 'error')   
        
    end
end)

RegisterServerEvent('aq-coke:server:cokesell')
AddEventHandler('aq-coke:server:cokesell', function()
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    local cokebaggy = Player.Functions.GetItemByName('cokebaggy')

    if Player.PlayerData.items ~= nil then 
        for k, v in pairs(Player.PlayerData.items) do 
            if cokebaggy ~= nil then
                if DrugList[Player.PlayerData.items[k].name] ~= nil then 
                    if Player.PlayerData.items[k].name == "cokebaggy" and Player.PlayerData.items[k].amount >= 1 then 
                        local random = math.random(50, 65)
                        local amount = Player.PlayerData.items[k].amount * random

                        TriggerClientEvent('chatMessage', source, "Dealer Johnny", "normal", 'Hey '..Player.PlayerData.firstname..', Wow je hebt '..Player.PlayerData.items[k].amount..'tassen coke')
                        TriggerClientEvent('chatMessage', source, "Dealer Johnny", "normal", 'Ik koop het voor €'..amount )

                        Player.Functions.RemoveItem("cokebaggy", Player.PlayerData.items[k].amount)
                        TriggerClientEvent('inventory:client:ItemBox', source, AQCore.Shared.Items['cokebaggy'], "remove")
                        Player.Functions.AddMoney("cash", amount)
                        break
                    else
                        TriggerClientEvent('AQCore:Notify', src, "Je hebt geen coke", 'error')
                        break
                    end
                end
            else
                TriggerClientEvent('AQCore:Notify', src, "Je hebt geen coke", 'error')
                break
            end
        end
    end
end)


RegisterServerEvent('aq-coke:server:getleaf')
AddEventHandler('aq-coke:server:getleaf', function()
    local Player = AQCore.Functions.GetPlayer(source)
    Player.Functions.AddItem("cocaleaf", 10)
    TriggerClientEvent('inventory:client:ItemBox', source, AQCore.Shared.Items['cocaleaf'], "add")
end)

RegisterServerEvent('aq-coke:server:getcoke')
AddEventHandler('aq-coke:server:getcoke', function()
    local Player = AQCore.Functions.GetPlayer(source)
    Player.Functions.AddItem("cokebaggy", 1)
    TriggerClientEvent('inventory:client:ItemBox', source, AQCore.Shared.Items['cokebaggy'], "add")
end)

RegisterServerEvent('aq-coke:server:getcrack')
AddEventHandler('aq-coke:server:getcrack', function()
    local Player = AQCore.Functions.GetPlayer(source)
    Player.Functions.AddItem("crack_baggy", 1)
    TriggerClientEvent('inventory:client:ItemBox', source, AQCore.Shared.Items['crack_baggy'], "add")
end)

