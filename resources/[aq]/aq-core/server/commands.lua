AQCore.Commands = {}
AQCore.Commands.List = {}

-- Register & Refresh Commands

function AQCore.Commands.Add(name, help, arguments, argsrequired, callback, permission)
    if type(permission) == 'string' then
        permission = permission:lower()
    else
        permission = 'user'
    end
    AQCore.Commands.List[name:lower()] = {
        name = name:lower(),
        permission = permission,
        help = help,
        arguments = arguments,
        argsrequired = argsrequired,
        callback = callback
    }
end

function AQCore.Commands.Refresh(source)
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    local suggestions = {}
    if Player then
        for command, info in pairs(AQCore.Commands.List) do
            local isGod = AQCore.Functions.HasPermission(src, 'god')
            local hasPerm = AQCore.Functions.HasPermission(src, AQCore.Commands.List[command].permission)
            local isPrincipal = IsPlayerAceAllowed(src, 'command')
            if isGod or hasPerm or isPrincipal then
                suggestions[#suggestions+1] = {
                    name = '/' .. command,
                    help = info.help,
                    params = info.arguments
                }
            end
        end
        TriggerClientEvent('chat:addSuggestions', tonumber(source), suggestions)
    end
end

-- Teleport

AQCore.Commands.Add('tp', 'TP To Player or Coords (Admin Only)', {{name = 'id/x', help = 'ID of player or X position'},{name = 'y', help = 'Y position'}, {name = 'z', help = 'Z position'}}, false, function(source, args)
    local src = source
    if args[1] and not args[2] and not args[3] then
        local target = GetPlayerPed(tonumber(args[1]))
        if target ~= 0 then
            local coords = GetEntityCoords(target)
            TriggerClientEvent('AQCore:Command:TeleportToPlayer', src, coords)
        else
            TriggerClientEvent('AQCore:Notify', src, 'Player Not Online', 'error')
        end
    else
        if args[1] and args[2] and args[3] then
            local x = tonumber(args[1])
            local y = tonumber(args[2])
            local z = tonumber(args[3])
            if (x ~= 0) and (y ~= 0) and (z ~= 0) then
                TriggerClientEvent('AQCore:Command:TeleportToCoords', src, x, y, z)
            else
                TriggerClientEvent('AQCore:Notify', src, 'Incorrect Format', 'error')
            end
        else
            TriggerClientEvent('AQCore:Notify', src, 'Not every argument has been entered (x, y, z)', 'error')
        end
    end
end, 'admin')

AQCore.Commands.Add('tpm', 'TP To Marker (Admin Only)', {}, false, function(source)
    local src = source
    TriggerClientEvent('AQCore:Command:GoToMarker', src)
end, 'admin')

-- Permissions

AQCore.Commands.Add('addpermission', 'Give Player Permissions (God Only)', {{name = 'id', help = 'ID of player'},{name = 'permission', help = 'Permission level'}}, true, function(source, args)
    local src = source
    local Player = AQCore.Functions.GetPlayer(tonumber(args[1]))
    local permission = tostring(args[2]):lower()
    if Player then
        AQCore.Functions.AddPermission(Player.PlayerData.source, permission)
    else
        TriggerClientEvent('AQCore:Notify', src, 'Player Not Online', 'error')
    end
end, 'god')

AQCore.Commands.Add('removepermission', 'Remove Players Permissions (God Only)', {{name = 'id', help = 'ID of player'}}, true, function(source, args)
    local src = source
    local Player = AQCore.Functions.GetPlayer(tonumber(args[1]))
    if Player then
        AQCore.Functions.RemovePermission(Player.PlayerData.source)
    else
        TriggerClientEvent('AQCore:Notify', src, 'Player Not Online', 'error')
    end
end, 'god')

-- Vehicle

AQCore.Commands.Add('car', 'Spawn Vehicle (Admin Only)',{{name = 'model', help = 'Model name of the vehicle'}}, true, function(source, args)
    local src = source
    TriggerClientEvent('AQCore:Command:SpawnVehicle', src, args[1])
end, 'admin')

AQCore.Commands.Add('dv', 'Delete Vehicle (Admin Only)', {}, false, function(source)
    local src = source
    TriggerClientEvent('AQCore:Command:DeleteVehicle', src)
end, 'admin')

-- Money

AQCore.Commands.Add('givemoney', 'Give A Player Money (Admin Only)', {{name = 'id', help = 'Player ID'},{name = 'moneytype', help = 'Type of money (cash, bank, crypto)'},{name = 'amount', help = 'Amount of money'}}, true, function(source, args)
    local src = source
    local Player = AQCore.Functions.GetPlayer(tonumber(args[1]))
    if Player then
        Player.Functions.AddMoney(tostring(args[2]), tonumber(args[3]))
    else
        TriggerClientEvent('AQCore:Notify', src, 'Player Not Online', 'error')
    end
end, 'admin')

AQCore.Commands.Add('setmoney', 'Set Players Money Amount (Admin Only)', {{name = 'id', help = 'Player ID'},{name = 'moneytype', help = 'Type of money (cash, bank, crypto)'},{name = 'amount', help = 'Amount of money'}}, true, function(source, args)
    local src = source
    local Player = AQCore.Functions.GetPlayer(tonumber(args[1]))
    if Player then
        Player.Functions.SetMoney(tostring(args[2]), tonumber(args[3]))
    else
        TriggerClientEvent('AQCore:Notify', src, 'Player Not Online', 'error')
    end
end, 'admin')

-- Job

AQCore.Commands.Add('job', 'Check Your Job', {}, false, function(source)
    local src = source
    local PlayerJob = AQCore.Functions.GetPlayer(src).PlayerData.job
    TriggerClientEvent('AQCore:Notify', src, string.format('[Job]: %s [Grade]: %s [On Duty]: %s', PlayerJob.label, PlayerJob.grade.name, PlayerJob.onduty))
end, 'user')

AQCore.Commands.Add('setjob', 'Set A Players Job (Admin Only)', {{name = 'id', help = 'Player ID'}, {name = 'job', help = 'Job name'},{name = 'grade', help = 'Grade'}}, true, function(source, args)
    local src = source
    local Player = AQCore.Functions.GetPlayer(tonumber(args[1]))
    if Player then
        Player.Functions.SetJob(tostring(args[2]), tonumber(args[3]))
    else
        TriggerClientEvent('AQCore:Notify', src, 'Player Not Online', 'error')
    end
end, 'admin')

-- Gang

AQCore.Commands.Add('gang', 'Check Your Gang', {}, false, function(source)
    local src = source
    local PlayerGang = AQCore.Functions.GetPlayer(source).PlayerData.gang
    TriggerClientEvent('AQCore:Notify', src, string.format('[Gang]: %s [Grade]: %s', PlayerGang.label, PlayerGang.grade.name))
end, 'user')

AQCore.Commands.Add('setgang', 'Set A Players Gang (Admin Only)', {{name = 'id', help = 'Player ID'}, {name = 'gang', help = 'Name of a gang'},{name = 'grade', help = 'Grade'}}, true, function(source, args)
    local src = source
    local Player = AQCore.Functions.GetPlayer(tonumber(args[1]))
    if Player then
        Player.Functions.SetGang(tostring(args[2]), tonumber(args[3]))
    else
        TriggerClientEvent('AQCore:Notify', src, 'Player Not Online', 'error')
    end
end, 'admin')

-- Inventory (should be in aq-inventory?)

AQCore.Commands.Add('clearinv', 'Clear Players Inventory (Admin Only)',{{name = 'id', help = 'Player ID'}}, false, function(source, args)
    local src = source
    local playerId = args[1] or src
    local Player = AQCore.Functions.GetPlayer(tonumber(playerId))
    if Player then
        Player.Functions.ClearInventory()
    else
        TriggerClientEvent('AQCore:Notify', src, 'Player Not Online', 'error')
    end
end, 'admin')

-- Out of Character Chat

AQCore.Commands.Add('ooc', 'OOC Chat Message', {}, false, function(source, args)
    local src = source
    local message = table.concat(args, ' ')
    local Players = AQCore.Functions.GetPlayers()
    local Player = AQCore.Functions.GetPlayer(src)
    for k, v in pairs(Players) do
        if v == src then
            TriggerClientEvent('chat:addMessage', v, 'OOC ' .. GetPlayerName(src), 'normal', message)
        elseif #(GetEntityCoords(GetPlayerPed(src)) -
            GetEntityCoords(GetPlayerPed(v))) < 20.0 then
            TriggerClientEvent('chat:addMessage', v, 'OOC ' .. GetPlayerName(src), 'normal', message)
        elseif AQCore.Functions.HasPermission(v, 'admin') then
            if AQCore.Functions.IsOptin(v) then
                TriggerClientEvent('chat:addMessage', v, 'Proximity OOC ' .. GetPlayerName(src), 'normal', message)
                TriggerEvent('aq-log:server:CreateLog', 'ooc', 'OOC', 'white', '**' .. GetPlayerName(src) .. '** (CitizenID: ' ..Player.PlayerData.citizenid .. ' | ID: ' .. src ..') **Message:** ' .. message, false)
            end
        end
    end
end, 'user')