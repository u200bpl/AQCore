RegisterServerEvent('aq-drugs:server:updateDealerItems')
AddEventHandler('aq-drugs:server:updateDealerItems', function(itemData, amount, dealer)
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    if Config.Dealers[dealer]["products"][itemData.slot].amount - 1 >= 0 then
        Config.Dealers[dealer]["products"][itemData.slot].amount =
            Config.Dealers[dealer]["products"][itemData.slot].amount - amount
        TriggerClientEvent('aq-drugs:client:setDealerItems', -1, itemData, amount, dealer)
    else
        Player.Functions.RemoveItem(itemData.name, amount)
        Player.Functions.AddMoney('cash', amount * Config.Dealers[dealer]["products"][itemData.slot].price)

        TriggerClientEvent("AQCore:Notify", src, "Dit artikel is niet beschikbaar.. Je hebt je geld terug.", "error")
    end
end)

RegisterServerEvent('aq-drugs:server:giveDeliveryItems')
AddEventHandler('aq-drugs:server:giveDeliveryItems', function(amount)
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)

    Player.Functions.AddItem('weed_brick', amount)
    TriggerClientEvent('inventory:client:ItemBox', src, AQCore.Shared.Items["weed_brick"], "add")
end)

AQCore.Functions.CreateCallback('aq-drugs:server:RequestConfig', function(source, cb)
    cb(Config.Dealers)
end)

RegisterServerEvent('aq-drugs:server:succesDelivery')
AddEventHandler('aq-drugs:server:succesDelivery', function(deliveryData, inTime)
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    local curRep = Player.PlayerData.metadata["dealerrep"]

    if inTime then
        if Player.Functions.GetItemByName('weed_brick') ~= nil and Player.Functions.GetItemByName('weed_brick').amount >=
            deliveryData["amount"] then
            Player.Functions.RemoveItem('weed_brick', deliveryData["amount"])
            local cops = GetCurrentCops()
            local price = 3000
            if cops == 1 then
                price = 4000
            elseif cops == 2 then
                price = 5000
            elseif cops >= 3 then
                price = 6000
            end
            if curRep < 10 then
                Player.Functions.AddMoney('cash', (deliveryData["amount"] * price / 100 * 8), "dilvery-drugs")
            elseif curRep >= 10 then
                Player.Functions.AddMoney('cash', (deliveryData["amount"] * price / 100 * 10), "dilvery-drugs")
            elseif curRep >= 20 then
                Player.Functions.AddMoney('cash', (deliveryData["amount"] * price / 100 * 12), "dilvery-drugs")
            elseif curRep >= 30 then
                Player.Functions.AddMoney('cash', (deliveryData["amount"] * price / 100 * 15), "dilvery-drugs")
            elseif curRep >= 40 then
                Player.Functions.AddMoney('cash', (deliveryData["amount"] * price / 100 * 18), "dilvery-drugs")
            end

            TriggerClientEvent('inventory:client:ItemBox', src, AQCore.Shared.Items["weed_brick"], "remove")
            TriggerClientEvent('AQCore:Notify', src, 'De bestelling is helemaal afgeleverd', 'success')

            SetTimeout(math.random(5000, 10000), function()
                TriggerClientEvent('aq-drugs:client:sendDeliveryMail', src, 'perfect', deliveryData)

                Player.Functions.SetMetaData('dealerrep', (curRep + 1))
            end)
        else
            TriggerClientEvent('AQCore:Notify', src, 'Dit voldoet niet aan de bestelling...', 'error')

            if Player.Functions.GetItemByName('weed_brick').amount ~= nil then
                Player.Functions.RemoveItem('weed_brick', Player.Functions.GetItemByName('weed_brick').amount)
                Player.Functions
                    .AddMoney('cash', (Player.Functions.GetItemByName('weed_brick').amount * 6000 / 100 * 5))
            end

            TriggerClientEvent('inventory:client:ItemBox', src, AQCore.Shared.Items["weed_brick"], "remove")

            SetTimeout(math.random(5000, 10000), function()
                TriggerClientEvent('aq-drugs:client:sendDeliveryMail', src, 'bad', deliveryData)

                if curRep - 1 > 0 then
                    Player.Functions.SetMetaData('dealerrep', (curRep - 1))
                else
                    Player.Functions.SetMetaData('dealerrep', 0)
                end
            end)
        end
    else
        TriggerClientEvent('AQCore:Notify', src, 'Je bent te laat', 'error')

        Player.Functions.RemoveItem('weed_brick', deliveryData["amount"])
        Player.Functions.AddMoney('cash', (deliveryData["amount"] * 6000 / 100 * 4), "dilvery-drugs-too-late")

        TriggerClientEvent('inventory:client:ItemBox', src, AQCore.Shared.Items["weed_brick"], "remove")

        SetTimeout(math.random(5000, 10000), function()
            TriggerClientEvent('aq-drugs:client:sendDeliveryMail', src, 'late', deliveryData)

            if curRep - 1 > 0 then
                Player.Functions.SetMetaData('dealerrep', (curRep - 1))
            else
                Player.Functions.SetMetaData('dealerrep', 0)
            end
        end)
    end
end)

RegisterServerEvent('aq-drugs:server:callCops')
AddEventHandler('aq-drugs:server:callCops', function(streetLabel, coords)
    local msg = "Er is een verdachte situatie geconstateerd op " .. streetLabel .. ", mogelijk drugshandel."
    local alertData = {
        title = "Drug Dealing",
        coords = {
            x = coords.x,
            y = coords.y,
            z = coords.z
        },
        description = msg
    }
    for k, v in pairs(AQCore.Functions.GetPlayers()) do
        local Player = AQCore.Functions.GetPlayer(v)
        if Player ~= nil then
            if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
                TriggerClientEvent("aq-drugs:client:robberyCall", Player.PlayerData.source, msg, streetLabel, coords)
                TriggerClientEvent("aq-phone:client:addPoliceAlert", Player.PlayerData.source, alertData)
            end
        end
    end
end)

function GetCurrentCops()
    local amount = 0
    for k, v in pairs(AQCore.Functions.GetPlayers()) do
        local Player = AQCore.Functions.GetPlayer(v)
        if Player ~= nil then
            if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
                amount = amount + 1
            end
        end
    end
    return amount
end

AQCore.Commands.Add("newdealer", "Plaats een drugsdealer (Admin Only)", {{
    name = "name",
    help = "Dealer name"
}, {
    name = "min",
    help = "Minimum time"
}, {
    name = "max",
    help = "Maximum time"
}}, true, function(source, args)
    local dealerName = args[1]
    local mintime = tonumber(args[2])
    local maxtime = tonumber(args[3])

    TriggerClientEvent('aq-drugs:client:CreateDealer', source, dealerName, mintime, maxtime)
end, "admin")

AQCore.Commands.Add("deletedealer", "Een dealer drugsverwijderen (Admin Only)", {{
    name = "name",
    help = "Name of the dealer"
}}, true, function(source, args)
    local dealerName = args[1]
    local result = exports.oxmysql:fetchSync('SELECT * FROM dealers WHERE name = ?', {dealerName})
    if result[1] ~= nil then
        exports.oxmysql:execute('DELETE FROM dealers WHERE name = ?', {dealerName})
        Config.Dealers[dealerName] = nil
        TriggerClientEvent('aq-drugs:client:RefreshDealers', -1, Config.Dealers)
        TriggerClientEvent('AQCore:Notify', source, "Dealer: " .. dealerName .. " Has Been Deleted", "success")
    else
        TriggerClientEvent('AQCore:Notify', source, "Dealer: " .. dealerName .. " Doesn\'t Exist", "error")
    end
end, "admin")

AQCore.Commands.Add("dealers", "View All Dealers (Admin Only)", {}, false, function(source, args)
    local DealersText = ""
    if Config.Dealers ~= nil and next(Config.Dealers) ~= nil then
        for k, v in pairs(Config.Dealers) do
            DealersText = DealersText .. "Name: " .. v["name"] .. "<br>"
        end
        TriggerClientEvent('chat:addMessage', source, {
            template = '<div class="chat-message advert"><div class="chat-message-body"><strong>Lijst van alle dealers: </strong><br><br> ' ..
                DealersText .. '</div></div>',
            args = {}
        })
    else
        TriggerClientEvent('AQCore:Notify', source, 'Er zijn geen dealers geplaatst.', 'error')
    end
end, "admin")

AQCore.Commands.Add("dealergoto", "Teleporteren naar een dealer (Admin Only)", {{
    name = "name",
    help = "Dealer name"
}}, true, function(source, args)
    local DealerName = tostring(args[1])

    if Config.Dealers[DealerName] ~= nil then
        TriggerClientEvent('aq-drugs:client:GotoDealer', source, Config.Dealers[DealerName])
    else
        TriggerClientEvent('AQCore:Notify', source, 'Deze dealer bestaat niet.', 'error')
    end
end, "admin")

Citizen.CreateThread(function()
    Wait(500)
    local dealers = exports.oxmysql:fetchSync('SELECT * FROM dealers', {})
    if dealers[1] ~= nil then
        for k, v in pairs(dealers) do
            local coords = json.decode(v.coords)
            local time = json.decode(v.time)

            Config.Dealers[v.name] = {
                ["name"] = v.name,
                ["coords"] = {
                    ["x"] = coords.x,
                    ["y"] = coords.y,
                    ["z"] = coords.z
                },
                ["time"] = {
                    ["min"] = time.min,
                    ["max"] = time.max
                },
                ["products"] = Config.Products
            }
        end
    end
    TriggerClientEvent('aq-drugs:client:RefreshDealers', -1, Config.Dealers)
end)

RegisterServerEvent('aq-drugs:server:CreateDealer')
AddEventHandler('aq-drugs:server:CreateDealer', function(DealerData)
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    local result = exports.oxmysql:fetchSync('SELECT * FROM dealers WHERE name = ?', {DealerData.name})
    if result[1] ~= nil then
        TriggerClientEvent('AQCore:Notify', src, "Er bestaat al een dealer met deze naam..", "error")
    else
        exports.oxmysql:insert('INSERT INTO dealers (name, coords, time, createdby) VALUES (?, ?, ?, ?)', {DealerData.name,
                                                                                                  json.encode(
            DealerData.pos), json.encode(DealerData.time), Player.PlayerData.citizenid}, function()
            Config.Dealers[DealerData.name] = {
                ["name"] = DealerData.name,
                ["coords"] = {
                    ["x"] = DealerData.pos.x,
                    ["y"] = DealerData.pos.y,
                    ["z"] = DealerData.pos.z
                },
                ["time"] = {
                    ["min"] = DealerData.time.min,
                    ["max"] = DealerData.time.max
                },
                ["products"] = Config.Products
            }

            TriggerClientEvent('aq-drugs:client:RefreshDealers', -1, Config.Dealers)
        end)
    end
end)

function GetDealers()
    return Config.Dealers
end