local AQCore = exports['aq-core']:GetCoreObject()

-- Functions

local function GiveStarterItems(source)
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
            info.type = "C"
        end
        Player.Functions.AddItem(v.item, v.amount, false, info)
    end
end

local function loadHouseData()
    local HouseGarages = {}
    local Houses = {}
    local result = exports.oxmysql:fetchSync('SELECT * FROM houselocations', {})
    if result[1] ~= nil then
        for k, v in pairs(result) do
            local owned = false
            if tonumber(v.owned) == 1 then
                owned = true
            end
            local garage = v.garage ~= nil and json.decode(v.garage) or {}
            Houses[v.name] = {
                coords = json.decode(v.coords),
                owned = v.owned,
                price = v.price,
                locked = true,
                adress = v.label, 
                tier = v.tier,
                garage = garage,
                decorations = {},
            }
            HouseGarages[v.name] = {
                label = v.label,
                takeVehicle = garage,
            }
        end
    end
    TriggerClientEvent("aq-garages:client:houseGarageConfig", -1, HouseGarages)
    TriggerClientEvent("aq-houses:client:setHouseConfig", -1, Houses)
end

-- Commands

AQCore.Commands.Add("logout", "Logout of Character (Admin Only)", {}, false, function(source)
    local src = source
    AQCore.Player.Logout(src)
    TriggerClientEvent('aq-multicharacter:client:chooseChar', src)
end, "admin")

AQCore.Commands.Add("closeNUI", "Close Multi NUI", {}, false, function(source)
    local src = source
    TriggerClientEvent('aq-multicharacter:client:closeNUI', src)
end)

-- Events

RegisterNetEvent('aq-multicharacter:server:disconnect', function()
    local src = source
    DropPlayer(src, "You have disconnected from AQCore")
end)

RegisterNetEvent('aq-multicharacter:server:loadUserData', function(cData)
    local src = source
    if AQCore.Player.Login(src, cData.citizenid) then
        print('^2[aq-core]^7 '..GetPlayerName(src)..' (Citizen ID: '..cData.citizenid..') has succesfully loaded!')
        AQCore.Commands.Refresh(src)
        loadHouseData()
        TriggerClientEvent('apartments:client:setupSpawnUI', src, cData)
        TriggerEvent("aq-log:server:CreateLog", "joinleave", "Loaded", "green", "**".. GetPlayerName(src) .. "** ("..cData.citizenid.." | "..src..") loaded..")
	end
end)

RegisterNetEvent('aq-multicharacter:server:createCharacter', function(data)
    local src = source
    local newData = {}
    newData.cid = data.cid
    newData.charinfo = data
    if AQCore.Player.Login(src, false, newData) then
        if Config.StartingApartment then
            local randbucket = (GetPlayerPed(src) .. math.random(1,999))
            SetPlayerRoutingBucket(src, randbucket)
            AQCore.Commands.Refresh(src)
            loadHouseData()
            TriggerClientEvent("aq-multicharacter:client:closeNUI", src)
            TriggerClientEvent('apartments:client:setupSpawnUI', src, newData)
            GiveStarterItems(src)
        else
            AQCore.Commands.Refresh(src)
            loadHouseData()
            TriggerClientEvent("aq-multicharacter:client:closeNUIdefault", src)
            GiveStarterItems(src)
        end
	end
end)

RegisterNetEvent('aq-multicharacter:server:deleteCharacter', function(citizenid)
    local src = source
    AQCore.Player.DeleteCharacter(src, citizenid)
end)

-- Callbacks

AQCore.Functions.CreateCallback("aq-multicharacter:server:GetUserCharacters", function(source, cb)
    local src = source
    local license = AQCore.Functions.GetIdentifier(src, 'license')

    exports.oxmysql:fetch('SELECT * FROM players WHERE license = ?', {license}, function(result)
        cb(result)
    end)
end)

AQCore.Functions.CreateCallback("aq-multicharacter:server:GetServerLogs", function(source, cb)
    exports.oxmysql:fetch('SELECT * FROM server_logs', {}, function(result)
        cb(result)
    end)
end)

AQCore.Functions.CreateCallback("aq-multicharacter:server:setupCharacters", function(source, cb)
    local license = AQCore.Functions.GetIdentifier(source, 'license')
    local plyChars = {}
    exports.oxmysql:fetch('SELECT * FROM players WHERE license = ?', {license}, function(result)
        for i = 1, (#result), 1 do
            result[i].charinfo = json.decode(result[i].charinfo)
            result[i].money = json.decode(result[i].money)
            result[i].job = json.decode(result[i].job)
            plyChars[#plyChars+1] = result[i]
        end
        cb(plyChars)
    end)
end)

AQCore.Functions.CreateCallback("aq-multicharacter:server:getSkin", function(source, cb, cid)
    local result = exports.oxmysql:fetchSync('SELECT * FROM playerskins WHERE citizenid = ? AND active = ?', {cid, 1})
    if result[1] ~= nil then
        cb(result[1].model, result[1].skin)
    else
        cb(nil)
    end
end)