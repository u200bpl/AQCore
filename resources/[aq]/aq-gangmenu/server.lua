local Accounts = {}

CreateThread(function()
    Wait(500)
    local result = json.decode(LoadResourceFile(GetCurrentResourceName(), "./accounts.json"))
    if not result then
        return
    end
    for k, v in pairs(result) do
        local k = tostring(k)
        local v = tonumber(v)
        if k and v then
            Accounts[k] = v
        end
    end
end)

AQCore.Functions.CreateCallback('aq-gangmenu:server:GetAccount', function(source, cb, gangname)
    local result = GetAccount(gangname)
    cb(result)
end)

-- Export
function GetAccount(account)
    return Accounts[account] or 0
end

-- Withdraw Money
RegisterServerEvent("aq-gangmenu:server:withdrawMoney")
AddEventHandler("aq-gangmenu:server:withdrawMoney", function(amount)
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    local gang = Player.PlayerData.gang.name

    if not Accounts[gang] then
        Accounts[gang] = 0
    end

    if Accounts[gang] >= amount and amount > 0 then
        Accounts[gang] = Accounts[gang] - amount
        Player.Functions.AddMoney("cash", amount)
    else
        TriggerClientEvent('AQCore:Notify', src, 'Niet genoeg geld', 'error')
        return
    end
    SaveResourceFile(GetCurrentResourceName(), "./accounts.json", json.encode(Accounts), -1)
    TriggerEvent('aq-log:server:CreateLog', 'bossmenu', 'Geld opnemen',
        "Succesvol opgenomen geld: €" .. amount .. ' (' .. gang .. ')', src)
end)

-- Deposit Money
RegisterServerEvent("aq-gangmenu:server:depositMoney")
AddEventHandler("aq-gangmenu:server:depositMoney", function(amount)
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    local gang = Player.PlayerData.gang.name

    if not Accounts[gang] then
        Accounts[gang] = 0
    end

    if Player.Functions.RemoveMoney("cash", amount) then
        Accounts[gang] = Accounts[gang] + amount
    else
        TriggerClientEvent('AQCore:Notify', src, 'Niet genoeg geld', "error")
        return
    end
    SaveResourceFile(GetCurrentResourceName(), "./accounts.json", json.encode(Accounts), -1)
    TriggerEvent('aq-log:server:CreateLog', 'bossmenu', 'Deposit Money',
        "Succesvol gestorte geld: €" .. amount .. ' (' .. gang .. ')', src)
end)

RegisterServerEvent("aq-gangmenu:server:addAccountMoney")
AddEventHandler("aq-gangmenu:server:addAccountMoney", function(account, amount)
    if not Accounts[account] then
        Accounts[account] = 0
    end

    Accounts[account] = Accounts[account] + amount
    TriggerClientEvent('aq-gangmenu:client:refreshSociety', -1, account, Accounts[account])
    SaveResourceFile(GetCurrentResourceName(), "./accounts.json", json.encode(Accounts), -1)
end)

RegisterServerEvent("aq-gangmenu:server:removeAccountMoney")
AddEventHandler("aq-gangmenu:server:removeAccountMoney", function(account, amount)
    if not Accounts[account] then
        Accounts[account] = 0
    end

    if Accounts[account] >= amount then
        Accounts[account] = Accounts[account] - amount
    end

    TriggerClientEvent('aq-gangmenu:client:refreshSociety', -1, account, Accounts[account])
    SaveResourceFile(GetCurrentResourceName(), "./accounts.json", json.encode(Accounts), -1)
end)

-- Get Employees
AQCore.Functions.CreateCallback('aq-gangmenu:server:GetEmployees', function(source, cb, gangname)
    local employees = {}
    if not Accounts[gangname] then
        Accounts[gangname] = 0
    end
    local query = '%' .. gangname .. '%'
    local players = exports.oxmysql:fetchSync('SELECT * FROM players WHERE gang LIKE ?', {query})
    if players[1] ~= nil then
        for key, value in pairs(players) do
            local isOnline = AQCore.Functions.GetPlayerByCitizenId(value.citizenid)

            if isOnline then
                table.insert(employees, {
                    source = isOnline.PlayerData.citizenid,
                    grade = isOnline.PlayerData.gang.grade,
                    isboss = isOnline.PlayerData.gang.isboss,
                    name = isOnline.PlayerData.charinfo.firstname .. ' ' .. isOnline.PlayerData.charinfo.lastname
                })
            else
                table.insert(employees, {
                    source = value.citizenid,
                    grade = json.decode(value.gang).grade,
                    isboss = json.decode(value.gang).isboss,
                    name = json.decode(value.charinfo).firstname .. ' ' .. json.decode(value.charinfo).lastname
                })
            end
        end
    end
    cb(employees)
end)

-- Grade Change
RegisterServerEvent('aq-gangmenu:server:updateGrade')
AddEventHandler('aq-gangmenu:server:updateGrade', function(target, grade)
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    local Employee = AQCore.Functions.GetPlayerByCitizenId(target)
    if Employee then
        if Employee.Functions.SetGang(Player.PlayerData.gang.name, grade) then
            TriggerClientEvent('AQCore:Notify', src, "Grade succesvol gewijzigd", "success")
            TriggerClientEvent('AQCore:Notify', Employee.PlayerData.source, "je grade is nu [" .. grade .. "].",
                "success")
        else
            TriggerClientEvent('AQCore:Notify', src, "Grade bestaat niet", "error")
        end
    else
        local player = exports.oxmysql:fetchSync('SELECT * FROM players WHERE citizenid = ? LIMIT 1', {target})
        if player[1] ~= nil then
            Employee = player[1]
            local gang = AQCore.Shared.Gangs[Player.PlayerData.gang.name]
            local employeegang = json.decode(Employee.gang)
            employeegang.grade = gang.grades[data.grade]
            exports.oxmysql:execute('UPDATE players SET gang = ? WHERE citizenid = ?',
                {json.encode(employeegang), target})
            TriggerClientEvent('AQCore:Notify', src, "Grade succesvol aangepast!", "success")
        else
            TriggerClientEvent('AQCore:Notify', src, "Speler bestaat niet", "error")
        end
    end
end)

-- Fire Employee
RegisterServerEvent('aq-gangmenu:server:fireEmployee')
AddEventHandler('aq-gangmenu:server:fireEmployee', function(target)
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    local Employee = AQCore.Functions.GetPlayerByCitizenId(target)
    if Employee then
        if Employee.Functions.SetGang("none", '0') then
            TriggerEvent('aq-log:server:CreateLog', 'bossmenu', 'Gang Fire', "Successfully fired " ..
                GetPlayerName(Employee.PlayerData.source) .. ' (' .. Player.PlayerData.gang.name .. ')', src)
            TriggerClientEvent('AQCore:Notify', src, "Fired successfully!", "success")
            TriggerClientEvent('AQCore:Notify', Employee.PlayerData.source, "Je bent ontslagen", "error")
        else
            TriggerClientEvent('AQCore:Notify', src, "Neem contact op met de developers", "error")
        end
    else
        local player = exports.oxmysql:fetchSync('SELECT * FROM players WHERE citizenid = ? LIMIT 1', {target})
        if player[1] ~= nil then
            Employee = player[1]
            local gang = {}
            gang.name = "none"
            gang.label = "No Gang"
            gang.payment = 10
            gang.onduty = true
            gang.isboss = false
            gang.grade = {}
            gang.grade.name = nil
            gang.grade.level = 0
            exports.oxmysql:execute('UPDATE players SET gang = ? WHERE citizenid = ?', {json.encode(gang), target})
            TriggerClientEvent('AQCore:Notify', src, "Ontslag succesvol!", "success")
            TriggerEvent('aq-log:server:CreateLog', 'bossmenu', 'Fire',
                "Successfully fired " .. target.source .. ' (' .. Player.PlayerData.gang.name .. ')', src)
        else
            TriggerClientEvent('AQCore:Notify', src, "Speler bestaat niet", "error")
        end
    end
end)

-- Recruit Player
RegisterServerEvent('aq-gangmenu:server:giveJob')
AddEventHandler('aq-gangmenu:server:giveJob', function(recruit)
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    local Target = AQCore.Functions.GetPlayer(recruit)
    if Target and Target.Functions.SetGang(Player.PlayerData.gang.name, 0) then
        TriggerClientEvent('AQCore:Notify', src,
            "Je hebt " .. (Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname) ..
                "aangenomen voor " .. Player.PlayerData.gang.label .. "", "success")
        TriggerClientEvent('AQCore:Notify', Target.PlayerData.source,
            "Je bent aangenomen voor " .. Player.PlayerData.gang.label .. "", "success")
        TriggerEvent('aq-log:server:CreateLog', 'bossmenu', 'Recruit',
            "Succesvol aangenomen " ..
                (Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname) .. ' (' ..
                Player.PlayerData.gang.name .. ')', src)
    end
end)
