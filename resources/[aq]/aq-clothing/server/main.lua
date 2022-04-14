RegisterServerEvent("aq-clothing:saveSkin")
AddEventHandler('aq-clothing:saveSkin', function(model, skin)
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    if model ~= nil and skin ~= nil then
        -- TODO: Update primary key to be citizenid so this can be an insert on duplicate update query
        exports.oxmysql:execute('DELETE FROM playerskins WHERE citizenid = ?', { Player.PlayerData.citizenid }, function()
            exports.oxmysql:insert('INSERT INTO playerskins (citizenid, model, skin, active) VALUES (?, ?, ?, ?)', {
                Player.PlayerData.citizenid,
                model,
                skin,
                1
            })
        end)
    end
end)

RegisterServerEvent("aq-clothes:loadPlayerSkin")
AddEventHandler('aq-clothes:loadPlayerSkin', function()
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    local result = exports.oxmysql:fetchSync('SELECT * FROM playerskins WHERE citizenid = ? AND active = ?', { Player.PlayerData.citizenid, 1 })
    if result[1] ~= nil then
        TriggerClientEvent("aq-clothes:loadSkin", src, false, result[1].model, result[1].skin)
    else
        TriggerClientEvent("aq-clothes:loadSkin", src, true)
    end
end)

RegisterServerEvent("aq-clothes:saveOutfit")
AddEventHandler("aq-clothes:saveOutfit", function(outfitName, model, skinData)
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    if model ~= nil and skinData ~= nil then
        local outfitId = "outfit-"..math.random(1, 10).."-"..math.random(1111, 9999)
        exports.oxmysql:insert('INSERT INTO player_outfits (citizenid, outfitname, model, skin, outfitId) VALUES (?, ?, ?, ?, ?)', {
            Player.PlayerData.citizenid,
            outfitName,
            model,
            json.encode(skinData),
            outfitId
        }, function()
            local result = exports.oxmysql:fetchSync('SELECT * FROM player_outfits WHERE citizenid = ?', { Player.PlayerData.citizenid })
            if result[1] ~= nil then
                TriggerClientEvent('aq-clothing:client:reloadOutfits', src, result)
            else
                TriggerClientEvent('aq-clothing:client:reloadOutfits', src, nil)
            end
        end)
    end
end)

RegisterServerEvent("aq-clothing:server:removeOutfit")
AddEventHandler("aq-clothing:server:removeOutfit", function(outfitName, outfitId)
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    exports.oxmysql:execute('DELETE FROM player_outfits WHERE citizenid = ? AND outfitname = ? AND outfitId = ?', {
        Player.PlayerData.citizenid,
        outfitName,
        outfitId
    }, function()
        local result = exports.oxmysql:fetchSync('SELECT * FROM player_outfits WHERE citizenid = ?', { Player.PlayerData.citizenid })
        if result[1] ~= nil then
            TriggerClientEvent('aq-clothing:client:reloadOutfits', src, result)
        else
            TriggerClientEvent('aq-clothing:client:reloadOutfits', src, nil)
        end
    end)
end)

AQCore.Functions.CreateCallback('aq-clothing:server:getOutfits', function(source, cb)
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    local anusVal = {}

    local result = exports.oxmysql:fetchSync('SELECT * FROM player_outfits WHERE citizenid = ?', { Player.PlayerData.citizenid })
    if result[1] ~= nil then
        for k, v in pairs(result) do
            result[k].skin = json.decode(result[k].skin)
            anusVal[k] = v
        end
        cb(anusVal)
    end
    cb(anusVal)
end)