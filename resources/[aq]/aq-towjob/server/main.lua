local PaymentTax = 15
local Bail = {}

RegisterServerEvent('aq-tow:server:DoBail')
AddEventHandler('aq-tow:server:DoBail', function(bool, vehInfo)
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)

    if bool then
        -- if Player.PlayerData.money.cash >= Config.BailPrice then
        --     Bail[Player.PlayerData.citizenid] = Config.BailPrice
        --     Player.Functions.RemoveMoney('cash', Config.BailPrice, "tow-paid-bail")
        --     TriggerClientEvent('AQCore:Notify', src, 'You Have The Deposit of $1000,- paid', 'success')
        --     TriggerClientEvent('aq-tow:client:SpawnVehicle', src, vehInfo)
        -- else
        if Player.PlayerData.money.bank >= Config.BailPrice then
            Bail[Player.PlayerData.citizenid] = Config.BailPrice
            Player.Functions.RemoveMoney('bank', Config.BailPrice, "tow-paid-bail")
            TriggerClientEvent('AQCore:Notify', src, 'You Have Paid The Deposit Of $'..Config.BailPrice..' Paid', 'success')
            TriggerClientEvent('aq-tow:client:SpawnVehicle', src, vehInfo)
        else
            TriggerClientEvent('AQCore:Notify', src, 'You Do Not Have Enough Cash, The Deposit Is $'..Config.BailPrice..'', 'error')
        end
    else
        if Bail[Player.PlayerData.citizenid] ~= nil then
            Player.Functions.AddMoney('bank', Bail[Player.PlayerData.citizenid], "tow-bail-paid")
            Bail[Player.PlayerData.citizenid] = nil
            TriggerClientEvent('AQCore:Notify', src, 'You Got Back $'..Config.BailPrice..' From The Deposit', 'success')
        end
    end
end)

RegisterNetEvent('aq-tow:server:nano')
AddEventHandler('aq-tow:server:nano', function()
    local xPlayer = AQCore.Functions.GetPlayer(tonumber(source))

	xPlayer.Functions.AddItem("cryptostick", 1, false)
	TriggerClientEvent('inventory:client:ItemBox', source, AQCore.Shared.Items["cryptostick"], "add")
end)

RegisterNetEvent('aq-tow:server:11101110')
AddEventHandler('aq-tow:server:11101110', function(drops)
    local src = source 
    local Player = AQCore.Functions.GetPlayer(src)
    local drops = tonumber(drops)
    local bonus = 0
    local DropPrice = math.random(150, 170)
    if drops > 5 then 
        bonus = math.ceil((DropPrice / 10) * 5)
    elseif drops > 10 then
        bonus = math.ceil((DropPrice / 10) * 7)
    elseif drops > 15 then
        bonus = math.ceil((DropPrice / 10) * 10)
    elseif drops > 20 then
        bonus = math.ceil((DropPrice / 10) * 12)
    end
    local price = (DropPrice * drops) + bonus
    local taxAmount = math.ceil((price / 100) * PaymentTax)
    local payment = price - taxAmount

    Player.Functions.AddJobReputation(1)
    Player.Functions.AddMoney("bank", payment, "tow-salary")
    TriggerClientEvent('chatMessage', source, "JOB", "warning", "You Received Your Salary From: $"..payment..", Gross: $"..price.." (From What $"..bonus.." Bonus) In $"..taxAmount.." Tax ("..PaymentTax.."%)")
end)

AQCore.Commands.Add("npc", "Toggle Npc Job", {}, false, function(source, args)
	TriggerClientEvent("jobs:client:ToggleNpc", source)
end)

AQCore.Commands.Add("tow", "Place A Car On The Back Of Your Flatbed", {}, false, function(source, args)
    local Player = AQCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "tow" then
        TriggerClientEvent("aq-tow:client:TowVehicle", source)
    end
end)