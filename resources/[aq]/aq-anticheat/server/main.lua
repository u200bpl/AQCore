-- Get permissions --

AQCore.Functions.CreateCallback('aq-anticheat:server:GetPermissions', function(source, cb)
    local group = AQCore.Functions.GetPermission(source)
    cb(group)
end)

-- Execute ban --

RegisterServerEvent('aq-anticheat:server:banPlayer')
AddEventHandler('aq-anticheat:server:banPlayer', function(reason)
    local src = source
    TriggerEvent("aq-log:server:CreateLog", "anticheat", "Anti-Cheat", "white", GetPlayerName(src).." has been banned for "..reason, false)
    exports.oxmysql:insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        GetPlayerName(src),
        AQCore.Functions.GetIdentifier(src, 'license'),
        AQCore.Functions.GetIdentifier(src, 'discord'),
        AQCore.Functions.GetIdentifier(src, 'ip'),
        reason,
        2145913200,
        'Anti-Cheat'
    })
    DropPlayer(src, "Je bent verbannen voor de anti cheat. Vraag in support chat voor meer informatie: " .. AQCore.Config.Server.discord)
end)

-- Fake events --
function NonRegisteredEventCalled(CalledEvent, source)
    TriggerClientEvent("aq-anticheat:client:NonRegisteredEventCalled", source, "Cheating", CalledEvent)
end


for x, v in pairs(Config.BlacklistedEvents) do
    RegisterServerEvent(v)
    AddEventHandler(v, function(source)
        NonRegisteredEventCalled(v, source)
    end)
end



-- RegisterServerEvent('banking:withdraw')
-- AddEventHandler('banking:withdraw', function(source)
--     NonRegisteredEventCalled('bank:withdraw', source)
-- end)

AQCore.Functions.CreateCallback('aq-anticheat:server:HasWeaponInInventory', function(source, cb, WeaponInfo)
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    local PlayerInventory = Player.PlayerData.items
    local retval = false

    for k, v in pairs(PlayerInventory) do
        if v.name == WeaponInfo["name"] then
            retval = true
        end
    end
    cb(retval)
end)
