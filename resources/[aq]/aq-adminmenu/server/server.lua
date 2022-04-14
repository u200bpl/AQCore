-- Variables
local AQCore = exports['aq-core']:GetCoreObject()
local frozen = false
local permissions = {
    ['kill'] = 'god',
    ['ban'] = 'admin',
    ['noclip'] = 'admin',
    ['kickall'] = 'admin',
    ['kick'] = 'admin'
}

-- Get Dealers
AQCore.Functions.CreateCallback('test:getdealers', function(source, cb)
    cb(exports['aq-drugs']:GetDealers())
end)

-- Get Players
AQCore.Functions.CreateCallback('test:getplayers', function(source, cb) -- WORKS
    local players = {}
    for k, v in pairs(AQCore.Functions.GetPlayers()) do
        local targetped = GetPlayerPed(v)
        local ped = AQCore.Functions.GetPlayer(v)
        table.insert(players, {
            name = ped.PlayerData.charinfo.firstname .. ' ' .. ped.PlayerData.charinfo.lastname .. ' | (' .. GetPlayerName(v) .. ')',
            id = v,
            coords = GetEntityCoords(targetped),
            cid = ped.PlayerData.charinfo.firstname .. ' ' .. ped.PlayerData.charinfo.lastname,
            citizenid = ped.PlayerData.citizenid,
            sources = GetPlayerPed(ped.PlayerData.source),
            sourceplayer= ped.PlayerData.source

        })
    end
    cb(players)
end)

AQCore.Functions.CreateCallback('aq-admin:server:getrank', function(source, cb)
    local src = source
    if AQCore.Functions.HasPermission(src, 'god') or IsPlayerAceAllowed(src, 'command') then
        cb(true)
    else
        cb(false)
    end
end)

-- Functions

local function tablelength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

-- Events

RegisterNetEvent('aq-admin:server:GetPlayersForBlips', function()
    local src = source					                        
    local players = {}                                          
    for k, v in pairs(AQCore.Functions.GetPlayers()) do         
        local targetped = GetPlayerPed(v)                       
        local ped = AQCore.Functions.GetPlayer(v)             
        table.insert(players, {                             
            name = ped.PlayerData.charinfo.firstname .. ' ' .. ped.PlayerData.charinfo.lastname .. ' | (' .. GetPlayerName(v) .. ')',
            id = v,                                      
            coords = GetEntityCoords(targetped),             
            cid = ped.PlayerData.charinfo.firstname .. ' ' .. ped.PlayerData.charinfo.lastname,
            citizenid = ped.PlayerData.citizenid,            
            sources = GetPlayerPed(ped.PlayerData.source),    
            sourceplayer= ped.PlayerData.source              
        })                                                  
    end                                                  
    TriggerClientEvent('aq-admin:client:Show', src, players)  
end)

RegisterNetEvent('aq-admin:server:kill', function(player)
    TriggerClientEvent('hospital:client:KillPlayer', player.id)
end)

RegisterNetEvent('aq-admin:server:revive', function(player)
    TriggerClientEvent('hospital:client:Revive', player.id)
end)

RegisterNetEvent('aq-admin:server:kick', function(player, reason)
    local src = source
    if AQCore.Functions.HasPermission(src, permissions['kick']) or IsPlayerAceAllowed(src, 'command')  then
        TriggerEvent('aq-log:server:CreateLog', 'bans', 'Player Kicked', 'red', string.format('%s was kicked by %s for %s', GetPlayerName(player.id), GetPlayerName(src), reason), true)
        DropPlayer(player.id, 'Je bent gekickt van deze server:\nReden: ' .. reason .. '\n\n🔸 Vraag in de support chat voor meer informatie: ' .. AQCore.Config.Server.discord)
    end
end)

RegisterNetEvent('aq-admin:server:ban', function(player, time, reason)
    local src = source
    if AQCore.Functions.HasPermission(src, permissions['ban']) or IsPlayerAceAllowed(src, 'command') then
        local time = tonumber(time)
        local banTime = tonumber(os.time() + time)
        if banTime > 2147483647 then
            banTime = 2147483647
        end
        local timeTable = os.date('*t', banTime)
        exports.oxmysql:insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
            GetPlayerName(player.id),
            AQCore.Functions.GetIdentifier(player.id, 'license'),
            AQCore.Functions.GetIdentifier(player.id, 'discord'),
            AQCore.Functions.GetIdentifier(player.id, 'ip'),
            reason,
            banTime,
            GetPlayerName(src)
        })
        TriggerClientEvent('chat:addMessage', -1, {
            template = "<div class=chat-message server'><strong>ANNOUNCEMENT | {0} has been banned:</strong> {1}</div>",
            args = {GetPlayerName(player.id), reason}
        })
        TriggerEvent('aq-log:server:CreateLog', 'bans', 'Player Banned', 'red', string.format('%s was banned by %s for %s', GetPlayerName(player.id), GetPlayerName(src), reason), true)
        if banTime >= 2147483647 then
            DropPlayer(player.id, 'Je bent verbannen van deze server:\nReden: ' .. reason .. '\n\nDeze ban is voor altijd bro\n🔸 Vraag in suppport chat voor meer informatie: ' .. AQCore.Config.Server.discord)
        else
            DropPlayer(player.id, 'Je bent verbannen:\n' .. reason .. '\n\nBan verloopt over: ' .. timeTable['day'] .. '/' .. timeTable['month'] .. '/' .. timeTable['year'] .. ' ' .. timeTable['hour'] .. ':' .. timeTable['min'] .. '\n🔸 Vraag in support chat voor meer informatie: ' .. AQCore.Config.Server.discord)
        end
    end
end)

RegisterNetEvent('aq-admin:server:spectate')
AddEventHandler('aq-admin:server:spectate', function(player)
    local src = source
    local targetped = GetPlayerPed(player.id)
    local coords = GetEntityCoords(targetped)
    TriggerClientEvent('aq-admin:client:spectate', src, player.id, coords)
end)

RegisterNetEvent('aq-admin:server:freeze')
AddEventHandler('aq-admin:server:freeze', function(player)
    local target = GetPlayerPed(player.id)
    if not frozen then
        frozen = true
        FreezeEntityPosition(target, true)
    else
        frozen = false
        FreezeEntityPosition(target, false)
    end
end)

RegisterNetEvent('aq-admin:server:goto', function(player)
    local src = source
    local admin = GetPlayerPed(src)
    local coords = GetEntityCoords(GetPlayerPed(player.id))
    SetEntityCoords(admin, coords)
end)

RegisterNetEvent('aq-admin:server:intovehicle', function(player)
    local src = source
    local admin = GetPlayerPed(src)
    -- local coords = GetEntityCoords(GetPlayerPed(player.id))
    local targetPed = GetPlayerPed(player.id)
    local vehicle = GetVehiclePedIsIn(targetPed,false)
    local seat = -1
    if vehicle ~= 0 then
        for i=0,8,1 do
            if GetPedInVehicleSeat(vehicle,i) == 0 then
                seat = i
                break
            end
        end
        if seat ~= -1 then
            SetPedIntoVehicle(admin,vehicle,seat)
            TriggerClientEvent('AQCore:Notify', src, 'Entered vehicle', 'success', 5000)
        else
            TriggerClientEvent('AQCore:Notify', src, 'The vehicle has no free seats!', 'danger', 5000)
        end
    end
end)


RegisterNetEvent('aq-admin:server:bring', function(player)
    local src = source
    local admin = GetPlayerPed(src)
    local coords = GetEntityCoords(admin)
    local target = GetPlayerPed(player.id)
    SetEntityCoords(target, coords)
end)

RegisterNetEvent('aq-admin:server:inventory', function(player)
    local src = source
    TriggerClientEvent('aq-admin:client:inventory', src, player.id)
end)

RegisterNetEvent('aq-admin:server:cloth', function(player)
    TriggerClientEvent('aq-clothing:client:openMenu', player.id)
end)

RegisterNetEvent('aq-admin:server:setPermissions', function(targetId, group)
    local src = source
    if AQCore.Functions.HasPermission(src, 'god') or IsPlayerAceAllowed(src, 'command') then
        AQCore.Functions.AddPermission(targetId, group[1].rank)
        TriggerClientEvent('AQCore:Notify', targetId, 'Your Permission Level Is Now '..group[1].label)
    end
end)

RegisterNetEvent('aq-admin:server:SendReport', function(name, targetSrc, msg)
    local src = source
    if AQCore.Functions.HasPermission(src, 'admin')or IsPlayerAceAllowed(src, 'command') then
        if AQCore.Functions.IsOptin(src) then
            TriggerClientEvent('chat:addMessage', src, 'REPORT - '..name..' ('..targetSrc..')', 'report', msg)
        end
    end
end)

RegisterNetEvent('aq-admin:server:Staffchat:addMessage', function(name, msg)
    local src = source
    if AQCore.Functions.HasPermission(src, 'admin') or IsPlayerAceAllowed(src, 'command') then
        if AQCore.Functions.IsOptin(src) then
            TriggerClientEvent('chat:addMessage', src, 'STAFFCHAT - '..name, 'error', msg)
        end
    end
end)

RegisterNetEvent('aq-admin:server:SaveCar', function(mods, vehicle, hash, plate)
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    local result = exports.oxmysql:fetchSync('SELECT plate FROM player_vehicles WHERE plate = ?', { plate })
    if result[1] == nil then
        exports.oxmysql:insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)', {
            Player.PlayerData.license,
            Player.PlayerData.citizenid,
            vehicle.model,
            vehicle.hash,
            json.encode(mods),
            plate,
            0
        })
        TriggerClientEvent('AQCore:Notify', src, 'The vehicle is now yours!', 'success', 5000)
    else
        TriggerClientEvent('AQCore:Notify', src, 'This vehicle is already yours..', 'error', 3000)
    end
end)

-- Commands

AQCore.Commands.Add('blips', 'Show blips for players (Admin Only)', {}, false, function(source, args)
    TriggerClientEvent('aq-admin:client:toggleBlips', source)
end, 'admin')

AQCore.Commands.Add('names', 'Show player name overhead (Admin Only)', {}, false, function(source, args)
    TriggerClientEvent('aq-admin:client:toggleNames', source)
end, 'admin')

AQCore.Commands.Add('coords', 'Enable coord display for development stuff (Admin Only)', {}, false, function(source, args)
    TriggerClientEvent('aq-admin:client:ToggleCoords', source)
end, 'admin')

AQCore.Commands.Add('admincar', 'Save Vehicle To Your Garage (Admin Only)', {}, false, function(source, args)
    local ply = AQCore.Functions.GetPlayer(source)
    TriggerClientEvent('aq-admin:client:SaveCar', source)
end, 'admin')

AQCore.Commands.Add('announce', 'Make An Announcement (Admin Only)', {}, false, function(source, args)
    local msg = table.concat(args, ' ')
    for i = 1, 3, 1 do
        TriggerClientEvent('chat:addMessage', -1, 'SYSTEM', 'error', msg)
    end
end, 'admin')

AQCore.Commands.Add('admin', 'Open Admin Menu (Admin Only)', {}, false, function(source, args)
    TriggerClientEvent('aq-admin:client:openMenu', source)
end, 'admin')

AQCore.Commands.Add('report', 'Admin Report', {{name='message', help='Message'}}, true, function(source, args)
    local msg = table.concat(args, ' ')
    local Player = AQCore.Functions.GetPlayer(source)
    TriggerClientEvent('aq-admin:client:SendReport', -1, GetPlayerName(source), source, msg)
    TriggerClientEvent('chat:addMessage', source, 'REPORT Send', 'normal', msg)
    TriggerEvent('aq-log:server:CreateLog', 'report', 'Report', 'green', '**'..GetPlayerName(source)..'** (CitizenID: '..Player.PlayerData.citizenid..' | ID: '..source..') **Report:** ' ..msg, false)
end)

AQCore.Commands.Add('staffchat', 'Send A Message To All Staff (Admin Only)', {{name='message', help='Message'}}, true, function(source, args)
    local msg = table.concat(args, ' ')
    TriggerClientEvent('aq-admin:client:SendStaffChat', -1, GetPlayerName(source), msg)
end, 'admin')

AQCore.Commands.Add('givenuifocus', 'Give A Player NUI Focus (Admin Only)', {{name='id', help='Player id'}, {name='focus', help='Set focus on/off'}, {name='mouse', help='Set mouse on/off'}}, true, function(source, args)
    local playerid = tonumber(args[1])
    local focus = args[2]
    local mouse = args[3]
    TriggerClientEvent('aq-admin:client:GiveNuiFocus', playerid, focus, mouse)
end, 'admin')

AQCore.Commands.Add('warn', 'Warn A Player (Admin Only)', {{name='ID', help='Player'}, {name='Reason', help='Mention a reason'}}, true, function(source, args)
    local targetPlayer = AQCore.Functions.GetPlayer(tonumber(args[1]))
    local senderPlayer = AQCore.Functions.GetPlayer(source)
    table.remove(args, 1)
    local msg = table.concat(args, ' ')
    local myName = senderPlayer.PlayerData.name
    local warnId = 'WARN-'..math.random(1111, 9999)
    if targetPlayer ~= nil then
        TriggerClientEvent('chat:addMessage', targetPlayer.PlayerData.source, 'SYSTEM', 'error', 'You have been warned by: '..GetPlayerName(source)..', Reason: '..msg)
        TriggerClientEvent('chat:addMessage', source, 'SYSTEM', 'error', 'You have warned '..GetPlayerName(targetPlayer.PlayerData.source)..' for: '..msg)
        exports.oxmysql:insert('INSERT INTO player_warns (senderIdentifier, targetIdentifier, reason, warnId) VALUES (?, ?, ?, ?)', {
            senderPlayer.PlayerData.license,
            targetPlayer.PlayerData.license,
            msg,
            warnId
        })
    else
        TriggerClientEvent('AQCore:Notify', source, 'This player is not online', 'error')
    end
end, 'admin')

AQCore.Commands.Add('checkwarns', 'Check Player Warnings (Admin Only)', {{name='ID', help='Player'}, {name='Warning', help='Number of warning, (1, 2 or 3 etc..)'}}, false, function(source, args)
    if args[2] == nil then
        local targetPlayer = AQCore.Functions.GetPlayer(tonumber(args[1]))
        local result = exports.oxmysql:fetchSync('SELECT * FROM player_warns WHERE targetIdentifier = ?', { targetPlayer.PlayerData.license })
        TriggerClientEvent('chat:addMessage', source, 'SYSTEM', 'warning', targetPlayer.PlayerData.name..' has '..tablelength(result)..' warnings!')
    else
        local targetPlayer = AQCore.Functions.GetPlayer(tonumber(args[1]))
        local warnings = exports.oxmysql:fetchSync('SELECT * FROM player_warns WHERE targetIdentifier = ?', { targetPlayer.PlayerData.license })
        local selectedWarning = tonumber(args[2])
        if warnings[selectedWarning] ~= nil then
            local sender = AQCore.Functions.GetPlayer(warnings[selectedWarning].senderIdentifier)
            TriggerClientEvent('chat:addMessage', source, 'SYSTEM', 'warning', targetPlayer.PlayerData.name..' has been warned by '..sender.PlayerData.name..', Reason: '..warnings[selectedWarning].reason)
        end
    end
end, 'admin')

AQCore.Commands.Add('delwarn', 'Delete Players Warnings (Admin Only)', {{name='ID', help='Player'}, {name='Warning', help='Number of warning, (1, 2 or 3 etc..)'}}, true, function(source, args)
    local targetPlayer = AQCore.Functions.GetPlayer(tonumber(args[1]))
    local warnings = exports.oxmysql:fetchSync('SELECT * FROM player_warns WHERE targetIdentifier = ?', { targetPlayer.PlayerData.license })
    local selectedWarning = tonumber(args[2])
    if warnings[selectedWarning] ~= nil then
        local sender = AQCore.Functions.GetPlayer(warnings[selectedWarning].senderIdentifier)
        TriggerClientEvent('chat:addMessage', source, 'SYSTEM', 'warning', 'You have deleted warning ('..selectedWarning..') , Reason: '..warnings[selectedWarning].reason)
        exports.oxmysql:execute('DELETE FROM player_warns WHERE warnId = ?', { warnings[selectedWarning].warnId })
    end
end, 'admin')

AQCore.Commands.Add('reportr', 'Reply To A Report (Admin Only)', {}, false, function(source, args)
    local playerId = tonumber(args[1])
    table.remove(args, 1)
    local msg = table.concat(args, ' ')
    local OtherPlayer = AQCore.Functions.GetPlayer(playerId)
    local Player = AQCore.Functions.GetPlayer(source)
    if OtherPlayer ~= nil then
        TriggerClientEvent('chat:addMessage', playerId, 'ADMIN - '..GetPlayerName(source), 'warning', msg)
        TriggerClientEvent('AQCore:Notify', source, 'Sent reply')
        for k, v in pairs(AQCore.Functions.GetPlayers()) do
            if AQCore.Functions.HasPermission(v, 'admin') or IsPlayerAceAllowed(src, 'command') then
                if AQCore.Functions.IsOptin(v) then
                    TriggerClientEvent('chat:addMessage', v, 'REPORT REPLY ('..source..') - '..GetPlayerName(source), 'warning', msg)
                    TriggerEvent('aq-log:server:CreateLog', 'report', 'Report Reply', 'red', '**'..GetPlayerName(source)..'** replied on: **'..OtherPlayer.PlayerData.name.. ' **(ID: '..OtherPlayer.PlayerData.source..') **Message:** ' ..msg, false)
                end
            end
        end
    else
        TriggerClientEvent('AQCore:Notify', source, 'Player is not online', 'error')
    end
end, 'admin')

AQCore.Commands.Add('setmodel', 'Change Ped Model (Admin Only)', {{name='model', help='Name of the model'}, {name='id', help='Id of the Player (empty for yourself)'}}, false, function(source, args)
    local model = args[1]
    local target = tonumber(args[2])
    if model ~= nil or model ~= '' then
        if target == nil then
            TriggerClientEvent('aq-admin:client:SetModel', source, tostring(model))
        else
            local Trgt = AQCore.Functions.GetPlayer(target)
            if Trgt ~= nil then
                TriggerClientEvent('aq-admin:client:SetModel', target, tostring(model))
            else
                TriggerClientEvent('AQCore:Notify', source, 'This person is not online..', 'error')
            end
        end
    else
        TriggerClientEvent('AQCore:Notify', source, 'You did not set a model..', 'error')
    end
end, 'admin')

AQCore.Commands.Add('setspeed', 'Set Player Foot Speed (Admin Only)', {}, false, function(source, args)
    local speed = args[1]
    if speed ~= nil then
        TriggerClientEvent('aq-admin:client:SetSpeed', source, tostring(speed))
    else
        TriggerClientEvent('AQCore:Notify', source, 'You did not set a speed.. (`fast` for super-run, `normal` for normal)', 'error')
    end
end, 'admin')

AQCore.Commands.Add('reporttoggle', 'Toggle Incoming Reports (Admin Only)', {}, false, function(source, args)
    AQCore.Functions.ToggleOptin(source)
    if AQCore.Functions.IsOptin(source) then
        TriggerClientEvent('AQCore:Notify', source, 'You are receiving reports', 'success')
    else
        TriggerClientEvent('AQCore:Notify', source, 'You are not receiving reports', 'error')
    end
end, 'admin')

RegisterCommand('kickall', function(source, args, rawCommand)
    local src = source
    if src > 0 then
        local reason = table.concat(args, ' ')
        local Player = AQCore.Functions.GetPlayer(src)

        if AQCore.Functions.HasPermission(src, 'god') or IsPlayerAceAllowed(src, 'command') then
            if args[1] ~= nil then
                for k, v in pairs(AQCore.Functions.GetPlayers()) do
                    local Player = AQCore.Functions.GetPlayer(v)
                    if Player ~= nil then
                        DropPlayer(Player.PlayerData.source, reason)
                    end
                end
            else
                TriggerClientEvent('chat:addMessage', src, 'SYSTEM', 'error', 'Mention a reason..')
            end
        else
            TriggerClientEvent('chat:addMessage', src, 'SYSTEM', 'error', 'You can\'t do this..')
        end
    else
        for k, v in pairs(AQCore.Functions.GetPlayers()) do
            local Player = AQCore.Functions.GetPlayer(v)
            if Player ~= nil then
                DropPlayer(Player.PlayerData.source, 'Server restart, check our Discord for more information: ' .. AQCore.Config.Server.discord)
            end
        end
    end
end, false)

AQCore.Commands.Add('setammo', 'Set Your Ammo Amount (Admin Only)', {{name='amount', help='Amount of bullets, for example: 20'}, {name='weapon', help='Name of the weapen, for example: WEAPON_VINTAGEPISTOL'}}, false, function(source, args)
    local src = source
    local weapon = args[2]
    local amount = tonumber(args[1])

    if weapon ~= nil then
        TriggerClientEvent('aq-weapons:client:SetWeaponAmmoManual', src, weapon, amount)
    else
        TriggerClientEvent('aq-weapons:client:SetWeaponAmmoManual', src, 'current', amount)
    end
end, 'admin')