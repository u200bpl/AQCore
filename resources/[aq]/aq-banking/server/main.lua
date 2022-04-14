Citizen.CreateThread(function()
    local ready = 0
    local buis = 0
    local cur = 0
    local sav = 0
    local gang = 0

    local accts = exports.oxmysql:fetchSync('SELECT * FROM bank_accounts WHERE account_type = ?', { 'Business' })
    buis = #accts
    if accts[1] ~= nil then
        for k, v in pairs(accts) do
            local acctType = v.business
            if businessAccounts[acctType] == nil then
                businessAccounts[acctType] = {}
            end
            businessAccounts[acctType][tonumber(v.businessid)] = generateBusinessAccount(tonumber(v.account_number), tonumber(v.sort_code), tonumber(v.businessid))
            while businessAccounts[acctType][tonumber(v.businessid)] == nil do Wait(0) end
        end
    end
    ready = ready + 1

    local savings = exports.oxmysql:fetchSync('SELECT * FROM bank_accounts WHERE account_type = ?', { 'Savings' })
    sav = #savings
    if savings[1] ~= nil then
        for k, v in pairs(savings) do
            savingsAccounts[v.citizenid] = generateSavings(v.citizenid)
        end
    end
    ready = ready + 1

    local gangs = exports.oxmysql:fetchSync('SELECT * FROM bank_accounts WHERE account_type = ?', { 'Gang' })
    gang = #gangs
    if gangs[1] ~= nil then
        for k, v in pairs(gangs) do
            gangAccounts[v.gangid] = loadGangAccount(v.gangid)
        end
    end
    ready = ready + 1

    repeat Wait(0) until ready == 5
    local totalAccounts = (buis + cur + sav + gang)
end)

exports('business', function(acctType, bid)
    if businessAccounts[acctType] then
        if businessAccounts[acctType][tonumber(bid)] then
            return businessAccounts[acctType][tonumber(bid)]
        end
    end
end)

RegisterServerEvent('aq-banking:server:modifyBank')
AddEventHandler('aq-banking:server:modifyBank', function(bank, k, v)
    if banks[tonumber(bank)] then
        banks[tonumber(bank)][k] = v
        TriggerClientEvent('aq-banking:client:syncBanks', -1, banks)
    end
end)

exports('modifyBank', function(bank, k, v)
    TriggerEvent('aq-banking:server:modifyBank', bank, k, v)
end)

exports('registerAccount', function(cid)
    local _cid = tonumber(cid)
    currentAccounts[_cid] = generateCurrent(_cid)
end)

exports('current', function(cid)
    if currentAccounts[cid] then
        return currentAccounts[cid]
    end
end)

exports('debitcard', function(cardnumber)
    if bankCards[tonumber(cardnumber)] then
        return bankCards[tonumber(cardnumber)]
    else
        return false
    end
end)

exports('savings', function(cid)
    if savingsAccounts[cid] then
        return savingsAccounts[cid]
    end
end)

exports('gang', function(gid)
    if gangAccounts[cid] then
        return gangAccounts[cid]
    end
end)

function checkAccountExists(acct, sc)
    local success
    local cid
    local actype
    local processed = false
    local exists = exports.oxmysql:fetchSync('SELECT * FROM bank_accounts WHERE account_number = ? AND sort_code = ?', { acct, sc })
    if exists[1] ~= nil then
        success = true
        cid = exists[1].character_id
        actype = exists[1].account_type
    else
        success = false
        cid = false
        actype = false
    end
    processed = true
    repeat Wait(0) until processed == true
    return success, cid, actype
end

RegisterServerEvent('aq-banking:createNewCard')
AddEventHandler('aq-banking:createNewCard', function()
    local src = source
    local xPlayer = AQCore.Functions.GetPlayer(src)

    if xPlayer ~= nil then
        local cid = xPlayer.PlayerData.citizenid
        if (cid) then
            currentAccounts[cid].generateNewCard()
        end
    end

    TriggerEvent('aq-log:server:CreateLog', 'banking', 'Banking', 'lightgreen', "**"..GetPlayerName(xPlayer.PlayerData.source) .. " (citizenid: "..xPlayer.PlayerData.citizenid.." | id: "..xPlayer.PlayerData.source..")**" .. " created new card")
end)

RegisterServerEvent('aq-base:itemUsed')
AddEventHandler('aq-base:itemUsed', function(_src, data)
    if data.item == "moneybag" then
        TriggerClientEvent('aq-banking:client:usedMoneyBag', _src, data)
    end
end)

RegisterServerEvent('aq-banking:server:unpackMoneyBag')
AddEventHandler('aq-banking:server:unpackMoneyBag', function(item)
    local _src = source
    if item ~= nil then
        local xPlayer = AQCore.Functions.GetPlayer(_src)
        local xPlayerCID = xPlayer.PlayerData.citizenid
        local decode = json.decode(item.metapublic)
        --_char:Inventories():Remove().Item(item, 1)
        --_char:Cash().Add(tonumber(decode.amount))
        --TriggerClientEvent('pw:notification:SendAlert', _src, {type = "success", text = "The cashier has counted your money bag and gave you $"..decode.amount.." cash.", length = 5000})
    end
end)

function getCharacterName(cid)
    local src = source
    local player = AQCore.Functions.GetPlayer(src)
    local name = player.PlayerData.name
end

RegisterServerEvent('aq-banking:initiateTransfer')
AddEventHandler('aq-banking:initiateTransfer', function(data)
    --[[
    local _src = source
    local _startChar = AQCore.Functions.GetPlayer(_src)
    while _startChar == nil do Wait(0) end

    local checkAccount, cid, acType = checkAccountExists(data.account, data.sortcode)
    while checkAccount == nil do Wait(0) end

    if (checkAccount) then 
        local receiptName = getCharacterName(cid)
        while receiptName == nil do Wait(0) end

        if receiptName ~= false or receiptName ~= nil then 
            local userOnline = exports.aq-base:checkOnline(cid)
            
            if userOnline ~= false then
                -- User is online so we can do a straght transfer 
                local _targetUser = exports.aq-base:Source(userOnline)
                if acType == "Current" then
                    local targetBank = _targetUser:Bank().Add(data.amount, 'Bank Transfer from '.._startChar.GetName())
                    while targetBank == nil do Wait(0) end
                    local bank = _startChar:Bank().Remove(data.amount, 'Bank Transfer to '..receiptName)
                    TriggerClientEvent('pw:notification:SendAlert', _src, {type = "inform", text = "You have sent a bank transfer to "..receiptName..' for the amount of $'..data.amount, length = 5000})
                    TriggerClientEvent('pw:notification:SendAlert', userOnline, {type = "inform", text = "You have received a bank transfer from ".._startChar.GetName()..' for the amount of $'..data.amount, length = 5000})
                    TriggerClientEvent('aq-banking:openBankScreen', _src)
                    TriggerClientEvent('aq-banking:successAlert', _src, 'You have sent a bank transfer to '..receiptName..' for the amount of $'..data.amount)
                else
                    local targetBank = savingsAccounts[cid].AddMoney(data.amount, 'Bank Transfer from '.._startChar.GetName())
                    while targetBank == nil do Wait(0) end
                    local bank = _startChar:Bank().Remove(data.amount, 'Bank Transfer to '..receiptName)
                    TriggerClientEvent('pw:notification:SendAlert', _src, {type = "inform", text = "You have sent a bank transfer to "..receiptName..' for the amount of $'..data.amount, length = 5000})
                    TriggerClientEvent('pw:notification:SendAlert', userOnline, {type = "inform", text = "You have received a bank transfer from ".._startChar.GetName()..' for the amount of $'..data.amount, length = 5000})
                    TriggerClientEvent('aq-banking:openBankScreen', _src)
                    TriggerClientEvent('aq-banking:successAlert', _src, 'You have sent a bank transfer to '..receiptName..' for the amount of $'..data.amount)
                end
                
            else
                -- User is not online so we need to manually adjust thier bank balance.
                    MySQL.Async.fetchScalar("SELECT `amount` FROM `bank_accounts` WHERE `account_number` = @an AND `sort_code` = @sc AND `character_id` = @cid", {
                        ['@an'] = data.account,
                        ['@sc'] = data.sortcode,
                        ['@cid'] = cid
                    }, function(currentBalance)
                        if currentBalance ~= nil then
                            local newBalance = currentBalance + data.amount
                            if newBalance ~= currentBalance then
                                MySQL.Async.execute("UPDATE `bank_accounts` SET `amount` = @newBalance WHERE `account_number` = @an AND `sort_code` = @sc AND `character_id` = @cid", {
                                    ['@an'] = data.account,
                                    ['@sc'] = data.sortcode,
                                    ['@cid'] = cid,
                                    ['@newBalance'] = newBalance
                                }, function(rowsChanged)
                                    if rowsChanged == 1 then
                                        local time = os.date("%Y-%m-%d %H:%M:%S")
                                        MySQL.Async.insert("INSERT INTO `bank_statements` (`account`, `character_id`, `account_number`, `sort_code`, `deposited`, `withdraw`, `balance`, `date`, `type`) VALUES (@accountty, @cid, @account, @sortcode, @deposited, @withdraw, @balance, @date, @type)", {
                                            ['@accountty'] = acType,
                                            ['@cid'] = cid,
                                            ['@account'] = data.account,
                                            ['@sortcode'] = data.sortcode,
                                            ['@deposited'] = data.amount,
                                            ['@withdraw'] = nil,
                                            ['@balance'] = newBalance,
                                            ['@date'] = time,
                                            ['@type'] = 'Bank Transfer from '.._startChar.GetName()
                                        }, function(statementUpdated)
                                            if statementUpdated > 0 then 
                                                local bank = _startChar:Bank().Remove(data.amount, 'Bank Transfer to '..receiptName)
                                                TriggerClientEvent('pw:notification:SendAlert', _src, {type = "inform", text = "You have sent a bank transfer to "..receiptName..' for the amount of $'..data.amount, length = 5000})
                                                TriggerClientEvent('aq-banking:openBankScreen', _src)
                                                TriggerClientEvent('aq-banking:successAlert', _src, 'You have sent a bank transfer to '..receiptName..' for the amount of $'..data.amount)
                                            end
                                        end)
                                    end
                                end)
                            end
                        end
                    end)
            end
        end
    else
        -- Send error to client that account details do no exist.
        TriggerClientEvent('aq-banking:transferError', _src, 'The account details entered could not be located.')
    end
]]
end)

function format_int(number)
    local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
    int = int:reverse():gsub("(%d%d%d)", "%1,")
    return minus .. int:reverse():gsub("^,", "") .. fraction
end

AQCore.Functions.CreateCallback('aq-banking:getBankingInformation', function(source, cb)
    local src = source
    local xPlayer = AQCore.Functions.GetPlayer(src)
    while xPlayer == nil do Wait(0) end
        if (xPlayer) then
            local banking = {
                    ['name'] = xPlayer.PlayerData.charinfo.firstname .. ' ' .. xPlayer.PlayerData.charinfo.lastname,
                    ['bankbalance'] = '$'.. format_int(xPlayer.PlayerData.money['bank']),
                    ['cash'] = '$'.. format_int(xPlayer.PlayerData.money['cash']),
                    ['accountinfo'] = xPlayer.PlayerData.charinfo.account,
                }
                
                if savingsAccounts[xPlayer.PlayerData.citizenid] then
                    local cid = xPlayer.PlayerData.citizenid
                    banking['savings'] = {
                        ['amount'] = savingsAccounts[cid].GetBalance(),
                        ['details'] = savingsAccounts[cid].getAccount(),
                        ['statement'] = savingsAccounts[cid].getStatement(),
                    }
                end

                cb(banking)
        else
            cb(nil)
        end
end)

RegisterServerEvent('aq-banking:createBankCard')
AddEventHandler('aq-banking:createBankCard', function(pin)
    local src = source
    local xPlayer = AQCore.Functions.GetPlayer(src)
    local cid = xPlayer.PlayerData.citizenid
    local cardNumber = math.random(1000000000000000,9999999999999999)
    xPlayer.Functions.SetCreditCard(cardNumber)

    local info = {}
    local selectedCard = Config.cardTypes[math.random(1,#Config.cardTypes)]
    info.citizenid = cid
    info.name = xPlayer.PlayerData.charinfo.firstname .. ' ' .. xPlayer.PlayerData.charinfo.lastname
    info.cardNumber = cardNumber
    info.cardPin = tonumber(pin)
    info.cardActive = true
    info.cardType = selectedCard
    
    if selectedCard == "visa" then
        xPlayer.Functions.AddItem('visa', 1, nil, info)
    elseif selectedCard == "mastercard" then
        xPlayer.Functions.AddItem('mastercard', 1, nil, info)
    end

    TriggerClientEvent('aq-banking:openBankScreen', src)
    TriggerClientEvent('AQCore:Notify', src, 'You have successfully ordered a Debit Card.', 'success')
    
    TriggerEvent('aq-log:server:CreateLog', 'banking', 'Banking', 'lightgreen', "**"..GetPlayerName(xPlayer.PlayerData.source) .. " (citizenid: "..xPlayer.PlayerData.citizenid.." | id: "..xPlayer.PlayerData.source..")** successfully ordered a debit card")
end)

RegisterServerEvent('aq-banking:doQuickDeposit')
AddEventHandler('aq-banking:doQuickDeposit', function(amount)
    local src = source
    local xPlayer = AQCore.Functions.GetPlayer(src)
    while xPlayer == nil do Wait(0) end
    local currentCash = xPlayer.Functions.GetMoney('cash')

    if tonumber(amount) <= currentCash then
        local cash = xPlayer.Functions.RemoveMoney('cash', tonumber(amount), 'banking-quick-depo')
        local bank = xPlayer.Functions.AddMoney('bank', tonumber(amount), 'banking-quick-depo')
        if bank then
            TriggerClientEvent('aq-banking:openBankScreen', src)
            TriggerClientEvent('aq-banking:successAlert', src, 'You made a cash deposit of $'..amount..' successfully.')
            TriggerEvent('aq-log:server:CreateLog', 'banking', 'Banking', 'lightgreen', "**"..GetPlayerName(xPlayer.PlayerData.source) .. " (citizenid: "..xPlayer.PlayerData.citizenid.." | id: "..xPlayer.PlayerData.source..")** made a cash deposit of $"..amount.." successfully.")
        end
    end
end)

RegisterServerEvent('aq-banking:toggleCard')
AddEventHandler('aq-banking:toggleCard', function(toggle)
    local src = source
    local xPlayer = AQCore.Functions.GetPlayer(src)
    
    while xPlayer == nil do Wait(0) end
        --_char:Bank():ToggleDebitCard(toggle)
end)

RegisterServerEvent('aq-banking:doQuickWithdraw')
AddEventHandler('aq-banking:doQuickWithdraw', function(amount, branch)
    local src = source
    local xPlayer = AQCore.Functions.GetPlayer(src)
    while xPlayer == nil do Wait(0) end
    local currentCash = xPlayer.Functions.GetMoney('bank')
    
    if tonumber(amount) <= currentCash then
        local cash = xPlayer.Functions.RemoveMoney('bank', tonumber(amount), 'banking-quick-withdraw')
        local bank = xPlayer.Functions.AddMoney('cash', tonumber(amount), 'banking-quick-withdraw')
        if cash then 
            TriggerClientEvent('aq-banking:openBankScreen', src)
            TriggerClientEvent('aq-banking:successAlert', src, 'You made a cash withdrawal of $'..amount..' successfully.')
            TriggerEvent('aq-log:server:CreateLog', 'banking', 'Banking', 'red', "**"..GetPlayerName(xPlayer.PlayerData.source) .. " (citizenid: "..xPlayer.PlayerData.citizenid.." | id: "..xPlayer.PlayerData.source..")** made a cash withdrawal of $"..amount.." successfully.")
        end
    end
end)

RegisterServerEvent('aq-banking:updatePin')
AddEventHandler('aq-banking:updatePin', function(pin)
    if pin ~= nil then 
        local src = source
        local xPlayer = AQCore.Functions.GetPlayer(src)
        while xPlayer == nil do Wait(0) end

        --   _char:Bank().UpdateDebitCardPin(pin)
        TriggerClientEvent('aq-banking:openBankScreen', src)
        TriggerClientEvent('aq-banking:successAlert', src, 'You have successfully updated your debit card pin.')
    end
end)

RegisterServerEvent('aq-banking:savingsDeposit')
AddEventHandler('aq-banking:savingsDeposit', function(amount)
    local src = source
    local xPlayer = AQCore.Functions.GetPlayer(src)
    while xPlayer == nil do Wait(0) end
    local currentBank = xPlayer.Functions.GetMoney('bank')
    
    if tonumber(amount) <= currentBank then
        local bank = xPlayer.Functions.RemoveMoney('bank', tonumber(amount))
        local savings = savingsAccounts[xPlayer.PlayerData.citizenid].AddMoney(tonumber(amount), 'Current Account to Savings Transfer')
        while bank == nil do Wait(0) end
        while savings == nil do Wait(0) end
        TriggerClientEvent('aq-banking:openBankScreen', src)
        TriggerClientEvent('aq-banking:successAlert', src, 'You made a savings deposit of $'..tostring(amount)..' successfully.')
        TriggerEvent('aq-log:server:CreateLog', 'banking', 'Banking', 'lightgreen', "**"..GetPlayerName(xPlayer.PlayerData.source) .. " (citizenid: "..xPlayer.PlayerData.citizenid.." | id: "..xPlayer.PlayerData.source..")** made a savings deposit of $"..tostring(amount).." successfully..")
    end
end)

RegisterServerEvent('aq-banking:savingsWithdraw')
AddEventHandler('aq-banking:savingsWithdraw', function(amount)
    local src = source
    local xPlayer = AQCore.Functions.GetPlayer(src)
    while xPlayer == nil do Wait(0) end
    local currentSavings = savingsAccounts[xPlayer.PlayerData.citizenid].GetBalance()
    
    if tonumber(amount) <= currentSavings then
        local savings = savingsAccounts[xPlayer.PlayerData.citizenid].RemoveMoney(tonumber(amount), 'Savings to Current Account Transfer')
        local bank = xPlayer.Functions.AddMoney('bank', tonumber(amount), 'banking-quick-withdraw')
        while bank == nil do Wait(0) end
        while savings == nil do Wait(0) end
        TriggerClientEvent('aq-banking:openBankScreen', src)
        TriggerClientEvent('aq-banking:successAlert', src, 'You made a savings withdrawal of $'..tostring(amount)..' successfully.')
        TriggerEvent('aq-log:server:CreateLog', 'banking', 'Banking', 'red', "**"..GetPlayerName(xPlayer.PlayerData.source) .. " (citizenid: "..xPlayer.PlayerData.citizenid.." | id: "..xPlayer.PlayerData.source..")** made a savings withdrawal of $"..tostring(amount).." successfully.")
    end
end)

RegisterServerEvent('aq-banking:createSavingsAccount')
AddEventHandler('aq-banking:createSavingsAccount', function()
    local src = source
    local xPlayer = AQCore.Functions.GetPlayer(src)
    local success = createSavingsAccount(xPlayer.PlayerData.citizenid)
    
    repeat Wait(0) until success ~= nil
    TriggerClientEvent('aq-banking:openBankScreen', src)
    TriggerClientEvent('aq-banking:successAlert', src, 'You have successfully opened a savings account.')
    TriggerEvent('aq-log:server:CreateLog', 'banking', 'Banking', "lightgreen", "**"..GetPlayerName(xPlayer.PlayerData.source) .. " (citizenid: "..xPlayer.PlayerData.citizenid.." | id: "..xPlayer.PlayerData.source..")** opened a savings account")
end)


AQCore.Commands.Add('givecash', 'Give cash to player.', {{name = 'id', help = 'Player ID'}, {name = 'amount', help = 'Amount'}}, true, function(source, args)
    local src = source
	local id = tonumber(args[1])
	local amount = math.ceil(tonumber(args[2]))
    
	if id and amount then
		local xPlayer = AQCore.Functions.GetPlayer(src)
		local xReciv = AQCore.Functions.GetPlayer(id)
		
		if xReciv and xPlayer then
			if not xPlayer.PlayerData.metadata["isdead"] then
				local distance = xPlayer.PlayerData.metadata["inlaststand"] and 3.0 or 10.0
				if #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(id))) < distance then
					if xPlayer.Functions.RemoveMoney('cash', amount) then
						if xReciv.Functions.AddMoney('cash', amount) then
							TriggerClientEvent('AQCore:Notify', src, "Success fully gave to ID " .. tostring(id) .. ' ' .. tostring(amount) .. '$.', "success")
							TriggerClientEvent('AQCore:Notify', id, "Success recived gave " .. tostring(amount) .. '$ from ID ' .. tostring(src), "success")
							TriggerClientEvent("payanimation", src)
						else
							TriggerClientEvent('AQCore:Notify', src, "Could not give item to the given id.", "error")
						end
					else
						TriggerClientEvent('AQCore:Notify', src, "You don\'t have this amount.", "error")
					end
				else
					TriggerClientEvent('AQCore:Notify', src, "You are too far away lmfao.", "error")
				end
			else
				TriggerClientEvent('AQCore:Notify', src, "You are dead LOL.", "error")
			end
		else
			TriggerClientEvent('AQCore:Notify', src, "Wrong ID.", "error")
		end
	else
		TriggerClientEvent('AQCore:Notify', src, "Usage /givecash [ID] [AMOUNT]", "error")
	end
end)

RegisterNetEvent("payanimation")
AddEventHandler("payanimation", function()
TriggerEvent('animations:client:EmoteCommandStart', {"id"})
end)
