AQCore.Commands.Add("setcryptoworth", "Set crypto value", {{name="crypto", help="Name of the crypto currency"}, {name="Value", help="New value of the crypto currency"}}, false, function(source, args)
    local src = source
    local crypto = tostring(args[1])

    if crypto ~= nil then
        if Crypto.Worth[crypto] ~= nil then
            local NewWorth = math.ceil(tonumber(args[2]))

            if NewWorth ~= nil then
                local PercentageChange = math.ceil(((NewWorth - Crypto.Worth[crypto]) / Crypto.Worth[crypto]) * 100)
                local ChangeLabel = "+"
                if PercentageChange < 0 then
                    ChangeLabel = "-"
                    PercentageChange = (PercentageChange * -1)
                end
                if Crypto.Worth[crypto] == 0 then
                    PercentageChange = 0
                    ChangeLabel = ""
                end

                table.insert(Crypto.History[crypto], {
                    PreviousWorth = Crypto.Worth[crypto],
                    NewWorth = NewWorth
                })

                TriggerClientEvent('AQCore:Notify', src, "You have the value of "..Crypto.Labels[crypto].."adapted from: ($"..Crypto.Worth[crypto].." to: $"..NewWorth..") ("..ChangeLabel.." "..PercentageChange.."%)")
                Crypto.Worth[crypto] = NewWorth
                TriggerClientEvent('aq-crypto:client:UpdateCryptoWorth', -1, crypto, NewWorth)
                exports.oxmysql:insert('INSERT INTO crypto (worth, history) VALUES (:worth, :history) ON DUPLICATE KEY UPDATE worth = :worth, history = :history', {
                    ['worth'] = NewWorth,
                    ['history'] = json.encode(Crypto.History[crypto]),
                })
                -- exports.oxmysql:execute('UPDATE crypto SET worth = ?, history = ? WHERE crypto = ?', { NewWorth, "", crypto })
            else
                TriggerClientEvent('AQCore:Notify', src, "You have not given a new value .. Current values: "..Crypto.Worth[crypto])
            end
        else
            TriggerClientEvent('AQCore:Notify', src, "This Crypto does not exist :(, available: Abit")
        end
    else
        TriggerClientEvent('AQCore:Notify', src, "You have not provided Crypto, available: Abit")
    end
end, "admin")

AQCore.Commands.Add("checkcryptoworth", "", {}, false, function(source, args)
    local src = source
    TriggerClientEvent('AQCore:Notify', src, "The Abit has a value of: $"..Crypto.Worth["abit"])
end, "admin")

AQCore.Commands.Add("crypto", "", {}, false, function(source, args)
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    local MyPocket = math.ceil(Player.PlayerData.money.crypto * Crypto.Worth["abit"])

    TriggerClientEvent('AQCore:Notify', src, "Je hebt: "..Player.PlayerData.money.crypto.." ABit, met een value of: €"..MyPocket..",-")
end, "admin")

RegisterServerEvent('aq-crypto:server:FetchWorth')
AddEventHandler('aq-crypto:server:FetchWorth', function()
    for name,_ in pairs(Crypto.Worth) do
        local result = exports.oxmysql:fetchSync('SELECT * FROM crypto WHERE crypto = ?', { name })
        if result[1] ~= nil then
            Crypto.Worth[name] = result[1].worth
            if result[1].history ~= nil then
                Crypto.History[name] = json.decode(result[1].history)
                TriggerClientEvent('aq-crypto:client:UpdateCryptoWorth', -1, name, result[1].worth, json.decode(result[1].history))
            else
                TriggerClientEvent('aq-crypto:client:UpdateCryptoWorth', -1, name, result[1].worth, nil)
            end
        end
    end
end)

RegisterServerEvent('aq-crypto:server:ExchangeFail')
AddEventHandler('aq-crypto:server:ExchangeFail', function()
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    local ItemData = Player.Functions.GetItemByName("cryptostick")

    if ItemData ~= nil then
        Player.Functions.RemoveItem("cryptostick", 1)
        TriggerClientEvent('inventory:client:ItemBox', src, AQCore.Shared.Items["cryptostick"], "remove")
        TriggerClientEvent('AQCore:Notify', src, "Poging mislukt..", 'error', 5000)
    end
end)

RegisterServerEvent('aq-crypto:server:Rebooting')
AddEventHandler('aq-crypto:server:Rebooting', function(state, percentage)
    Crypto.Exchange.RebootInfo.state = state
    Crypto.Exchange.RebootInfo.percentage = percentage
end)

RegisterServerEvent('aq-crypto:server:GetRebootState')
AddEventHandler('aq-crypto:server:GetRebootState', function()
    local src = source
    TriggerClientEvent('aq-crypto:client:GetRebootState', src, Crypto.Exchange.RebootInfo)
end)

RegisterServerEvent('aq-crypto:server:SyncReboot')
AddEventHandler('aq-crypto:server:SyncReboot', function()
    TriggerClientEvent('aq-crypto:client:SyncReboot', -1)
end)

RegisterServerEvent('aq-crypto:server:ExchangeSuccess')
AddEventHandler('aq-crypto:server:ExchangeSuccess', function(LuckChance)
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    local ItemData = Player.Functions.GetItemByName("cryptostick")

    if ItemData ~= nil then
        local LuckyNumber = math.random(1, 10)
        local DeelNumber = 1000000
        local Amount = (math.random(611111, 1599999) / DeelNumber)
        if LuckChance == LuckyNumber then
            Amount = (math.random(1599999, 2599999) / DeelNumber)
        end

        Player.Functions.RemoveItem("cryptostick", 1)
        Player.Functions.AddMoney('crypto', Amount)
        TriggerClientEvent('AQCore:Notify', src, "Je hebt je Cryptostick ingeruild voor: "..Amount.." ABit(\'s)", "success", 3500)
        TriggerClientEvent('inventory:client:ItemBox', src, AQCore.Shared.Items["cryptostick"], "remove")
        TriggerClientEvent('aq-phone:client:AddTransaction', src, Player, {}, "Er is "..Amount.." Abit('s) gecrediteerd!", "Credit")
    end
end)

AQCore.Functions.CreateCallback('aq-crypto:server:HasSticky', function(source, cb)
    local Player = AQCore.Functions.GetPlayer(source)
    local Item = Player.Functions.GetItemByName("cryptostick")

    if Item ~= nil then
        cb(true)
    else
        cb(false)
    end
end)

AQCore.Functions.CreateCallback('aq-crypto:server:GetCryptoData', function(source, cb, name)
    local Player = AQCore.Functions.GetPlayer(source)
    local CryptoData = {
        History = Crypto.History[name],
        Worth = Crypto.Worth[name],
        Portfolio = Player.PlayerData.money.crypto,
        WalletId = Player.PlayerData.metadata["walletid"],
    }

    cb(CryptoData)
end)

AQCore.Functions.CreateCallback('aq-crypto:server:BuyCrypto', function(source, cb, data)
    local Player = AQCore.Functions.GetPlayer(source)

    if Player.PlayerData.money.bank >= tonumber(data.Price) then
        local CryptoData = {
            History = Crypto.History["abit"],
            Worth = Crypto.Worth["abit"],
            Portfolio = Player.PlayerData.money.crypto + tonumber(data.Coins),
            WalletId = Player.PlayerData.metadata["walletid"],
        }
        Player.Functions.RemoveMoney('bank', tonumber(data.Price))
        TriggerClientEvent('aq-phone:client:AddTransaction', source, Player, data, "Jij hebt "..tonumber(data.Coins).." Abit('s) gekocht!", "Credit")
        Player.Functions.AddMoney('crypto', tonumber(data.Coins))
        cb(CryptoData)
    else
        cb(false)
    end
end)

AQCore.Functions.CreateCallback('aq-crypto:server:SellCrypto', function(source, cb, data)
    local Player = AQCore.Functions.GetPlayer(source)

    if Player.PlayerData.money.crypto >= tonumber(data.Coins) then
        local CryptoData = {
            History = Crypto.History["abit"],
            Worth = Crypto.Worth["abit"],
            Portfolio = Player.PlayerData.money.crypto - tonumber(data.Coins),
            WalletId = Player.PlayerData.metadata["walletid"],
        }
        Player.Functions.RemoveMoney('crypto', tonumber(data.Coins))
        TriggerClientEvent('aq-phone:client:AddTransaction', source, Player, data, "Jij hebt "..tonumber(data.Coins).." Abit('s) verkocht!", "Depreciation")
        Player.Functions.AddMoney('bank', tonumber(data.Price))
        cb(CryptoData)
    else
        cb(false)
    end
end)

AQCore.Functions.CreateCallback('aq-crypto:server:TransferCrypto', function(source, cb, data)
    local Player = AQCore.Functions.GetPlayer(source)

    if Player.PlayerData.money.crypto >= tonumber(data.Coins) then
        local query = '%'..data.WalletId..'%'
        local result = exports.oxmysql:fetchSync('SELECT * FROM `players` WHERE `metadata` LIKE ?', { query })
        if result[1] ~= nil then
            local CryptoData = {
                History = Crypto.History["abit"],
                Worth = Crypto.Worth["abit"],
                Portfolio = Player.PlayerData.money.crypto - tonumber(data.Coins),
                WalletId = Player.PlayerData.metadata["walletid"],
            }
            Player.Functions.RemoveMoney('crypto', tonumber(data.Coins))
            TriggerClientEvent('aq-phone:client:AddTransaction', source, Player, data, "Jij hebt "..tonumber(data.Coins).." Abit('s) overgedragen!", "Depreciation")
            local Target = AQCore.Functions.GetPlayerByCitizenId(result[1].citizenid)

            if Target ~= nil then
                Target.Functions.AddMoney('crypto', tonumber(data.Coins))
                TriggerClientEvent('aq-phone:client:AddTransaction', Target.PlayerData.source, Player, data, "Er zijn "..tonumber(data.Coins).." Abit('s) gecrediteerd!", "Credit")
            else
                MoneyData = json.decode(result[1].money)
                MoneyData.crypto = MoneyData.crypto + tonumber(data.Coins)
                exports.oxmysql:execute('UPDATE players SET money = ? WHERE citizenid = ?', { json.encode(MoneyData), result[1].citizenid })
            end
            cb(CryptoData)
        else
            cb("notvalid")
        end
    else
        cb("notenough")
    end
end)


-- Crypto New Value (Random)
local coin = Crypto.Coin

Citizen.CreateThread(function() 
    while true do
        Citizen.Wait(Crypto.RefreshTimer*60000)
        HandlePriceChance()            
    end
end)

HandlePriceChance = function()
    local currentValue = Crypto.Worth[coin]
    local prevValue = Crypto.Worth[coin]
    local trend = math.random(0,100) 
    local event = math.random(0,100)
    local chance = event - Crypto.ChanceOfCrashOrLuck

    if event > chance then 
        if trend <= Crypto.ChanceOfDown then 
            currentValue = currentValue - math.random(Crypto.CasualDown[1], Crypto.CasualDown[2])
        elseif trend >= Crypto.ChanceOfUp then 
            currentValue = currentValue + math.random(Crypto.CasualUp[1], Crypto.CasualUp[2])
        end
    else
        if math.random(0, 1) == 1 then 
            currentValue = currentValue + math.random(Crypto.Luck[1], Crypto.Luck[2])
        else
            currentValue = currentValue - math.random(Crypto.Crash[1], Crypto.Crash[2])
        end
    end

    if currentValue <= 1 then 
        currentValue = 1
    end

    table.insert(Crypto.History[coin], {PreviousWorth = prevValue, NewWorth = currentValue})
    Crypto.Worth[coin] = currentValue

    exports.oxmysql:insert('INSERT INTO crypto (worth, history) VALUES (:worth, :history) ON DUPLICATE KEY UPDATE worth = :worth, history = :history', {
        ['worth'] = currentValue,
        ['history'] = json.encode(Crypto.History[coin]),
    })
    RefreshCrypto()
end

RefreshCrypto = function()
    local result = exports.oxmysql:fetchSync('SELECT * FROM crypto WHERE crypto = ?', { coin })
    if result ~= nil and result[1] ~= nil then
        Crypto.Worth[coin] = result[1].worth
        if result[1].history ~= nil then
            Crypto.History[coin] = json.decode(result[1].history)
            TriggerClientEvent("AQCore:Notify", -1,"Crypto staat nu op "..result[1].worth.."", "success")
            TriggerClientEvent('aq-crypto:client:UpdateCryptoWorth', -1, coin, result[1].worth, json.decode(result[1].history))
        else
            TriggerClientEvent('aq-crypto:client:UpdateCryptoWorth', -1, coin, result[1].worth, nil)
        end
    end
end
