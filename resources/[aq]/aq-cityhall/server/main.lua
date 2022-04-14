local DrivingSchools = {
    
}

RegisterServerEvent('aq-cityhall:server:requestId')
AddEventHandler('aq-cityhall:server:requestId', function(identityData)
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    local info = {}
    if identityData.item == "id_card" then
        info.citizenid = Player.PlayerData.citizenid
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname = Player.PlayerData.charinfo.lastname
        info.birthdate = Player.PlayerData.charinfo.birthdate
        info.gender = Player.PlayerData.charinfo.gender
        info.nationality = Player.PlayerData.charinfo.nationality
    elseif identityData.item == "driver_license" then
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname = Player.PlayerData.charinfo.lastname
        info.birthdate = Player.PlayerData.charinfo.birthdate
        info.type = "Class C Driver License"
    end

    Player.Functions.AddItem(identityData.item, 1, nil, info)

    TriggerClientEvent('inventory:client:ItemBox', src, AQCore.Shared.Items[identityData.item], 'add')
end)


RegisterServerEvent('aq-cityhall:server:getIDs')
AddEventHandler('aq-cityhall:server:getIDs', function()
    local src = source
    GiveStarterItems(src)
end)


RegisterServerEvent('aq-cityhall:server:sendDriverTest')
AddEventHandler('aq-cityhall:server:sendDriverTest', function()
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    for k, v in pairs(DrivingSchools) do 
        local SchoolPlayer = AQCore.Functions.GetPlayerByCitizenId(v)
        if SchoolPlayer ~= nil then 
            TriggerClientEvent("aq-cityhall:client:sendDriverEmail", SchoolPlayer.PlayerData.source, Player.PlayerData.charinfo)
        else
            local mailData = {
                sender = "Township",
                subject = "Driving lessons request",
                message = "Hallo,<br /><br />We hebben zojuist bericht gekregen dat iemand rijles wil gaan volgen.<br />Als je bereid bent om les te geven, neem dan contact met ons op:<br />Naam: <strong>".. Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname .. "<br />Telefoon nummer: <strong>"..Player.PlayerData.charinfo.phone.."</strong><br/><br/>Met vriendelijke groeten,<br />Gemeente of Los Santos",
                button = {}
            }
            TriggerEvent("aq-phone:server:sendNewEventMail", v, mailData)
        end
    end
    TriggerClientEvent('AQCore:Notify', src, 'Er is een e-mail verzonden naar rijscholen en er wordt automatisch contact met u opgenomen', "success", 5000)
end)

RegisterServerEvent('aq-cityhall:server:ApplyJob')
AddEventHandler('aq-cityhall:server:ApplyJob', function(job)
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    local JobInfo = AQCore.Shared.Jobs[job]

    Player.Functions.SetJob(job, 0)

    TriggerClientEvent('AQCore:Notify', src, 'Gefeliciteerd met je nieuwe baan! ('..JobInfo.label..')')
end)


-- AQCore.Commands.Add("drivinglicense", "Give a driver's license to someone", {{"id", "ID of a person"}}, true, function(source, args)
--     local Player = AQCore.Functions.GetPlayer(source)

--         local SearchedPlayer = AQCore.Functions.GetPlayer(tonumber(args[1]))
--         if SearchedPlayer ~= nil then
--             local driverLicense = SearchedPlayer.PlayerData.metadata["licences"]["driver"]
--             if not driverLicense then
--                 local licenses = {
--                     ["driver"] = true,
--                     ["business"] = SearchedPlayer.PlayerData.metadata["licences"]["business"]
--                 }
--                 SearchedPlayer.Functions.SetMetaData("licences", licenses)
--                 TriggerClientEvent('AQCore:Notify', SearchedPlayer.PlayerData.source, "You have passed! Pick up your driver's license at the town hall", "success", 5000)
--             else
--                 TriggerClientEvent('AQCore:Notify', src, "Can't give driver's license ..", "error")
--             end
--         end

-- end)

function GiveStarterItems(source)
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)

    for k, v in pairs(AQCore.Shared.StarterItems) do
        local info = {}
        if v.item == "id_card" then
            info.citizenid = Player.PlayerData.citizenid
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.gender = Player.PlayerData.charinfo.gender
            info.nationality = Player.PlayerData.charinfo.nationality
        elseif v.item == "driver_license" then
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.type = "Class C Driver License"
        end
        Player.Functions.AddItem(v.item, 1, false, info)
    end
end

function IsWhitelistedSchool(citizenid)
    local retval = false
    for k, v in pairs(DrivingSchools) do 
        if v == citizenid then
            retval = true
        end
    end
    return retval
end

RegisterServerEvent('aq-cityhall:server:banPlayer')
AddEventHandler('aq-cityhall:server:banPlayer', function()
    local src = source
    TriggerClientEvent('chatMessage', -1, "AQ Anti-Cheat", "error", GetPlayerName(src).." has been banned for sending POST Request's ")
    exports.oxmysql:insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        GetPlayerName(src),
        AQCore.Functions.GetIdentifier(src, 'license'),
        AQCore.Functions.GetIdentifier(src, 'discord'),
        AQCore.Functions.GetIdentifier(src, 'ip'),
        'Abuse localhost:13172 For POST Requests',
        2145913200,
        GetPlayerName(src)
    })
    DropPlayer(src, 'Attempting To Exploit')
end)
