local OutsideVehicles = {}

-- code

RegisterServerEvent('aq-garages:server:UpdateOutsideVehicles')
AddEventHandler('aq-garages:server:UpdateOutsideVehicles', function(Vehicles)
    local src = source
    local Ply = AQCore.Functions.GetPlayer(src)
    local CitizenId = Ply.PlayerData.citizenid

    OutsideVehicles[CitizenId] = Vehicles
end)

AQCore.Functions.CreateCallback("aq-garage:server:checkVehicleOwner", function(source, cb, plate)
    local src = source
    local pData = AQCore.Functions.GetPlayer(src)

    exports.oxmysql:fetch('SELECT * FROM player_vehicles WHERE plate = ? AND citizenid = ?',
        {plate, pData.PlayerData.citizenid}, function(result)
            if result[1] ~= nil then
                cb(true)
            else
                cb(false)
            end
        end)
end)

AQCore.Functions.CreateCallback("aq-garage:server:GetOutsideVehicles", function(source, cb)
    local Ply = AQCore.Functions.GetPlayer(source)
    local CitizenId = Ply.PlayerData.citizenid

    if OutsideVehicles[CitizenId] ~= nil and next(OutsideVehicles[CitizenId]) ~= nil then
        cb(OutsideVehicles[CitizenId])
    else
        cb(nil)
    end
end)

AQCore.Functions.CreateCallback("aq-garage:server:GetUserVehicles", function(source, cb, garage)
    local src = source
    local pData = AQCore.Functions.GetPlayer(src)

    -- exports.oxmysql:fetch('SELECT * FROM player_vehicles WHERE citizenid = ? AND garage = ?',
    exports.oxmysql:fetch('SELECT * FROM player_vehicles WHERE citizenid = ?',
        {pData.PlayerData.citizenid, garage}, function(result)
            if result[1] ~= nil then
                cb(result)
            else
                cb(nil)
            end
        end)
end)

AQCore.Functions.CreateCallback("aq-garage:server:GetVehicleProperties", function(source, cb, plate)
    local src = source
    local properties = {}
    local result = exports.oxmysql:fetchSync('SELECT mods FROM player_vehicles WHERE plate = ?', {plate})
    if result[1] ~= nil then
        properties = json.decode(result[1].mods)
    end
    cb(properties)
end)

AQCore.Functions.CreateCallback("aq-garage:server:GetDepotVehicles", function(source, cb)
    local src = source
    local pData = AQCore.Functions.GetPlayer(src)

    exports.oxmysql:fetch('SELECT * FROM player_vehicles WHERE citizenid = ? AND state = ?',
        {pData.PlayerData.citizenid, 0}, function(result)
            if result[1] ~= nil then
                cb(result)
            else
                cb(nil)
            end
        end)
end)

AQCore.Functions.CreateCallback("aq-garage:server:GetHouseVehicles", function(source, cb, house)
    local src = source
    local pData = AQCore.Functions.GetPlayer(src)

    exports.oxmysql:fetch('SELECT * FROM player_vehicles WHERE garage = ?', {house}, function(result)
        if result[1] ~= nil then
            cb(result)
        else
            cb(nil)
        end
    end)
end)

AQCore.Functions.CreateCallback("aq-garage:server:checkVehicleHouseOwner", function(source, cb, plate, house)
    local src = source
    local pData = AQCore.Functions.GetPlayer(src)
    exports.oxmysql:fetch('SELECT * FROM player_vehicles WHERE plate = ?', {plate}, function(result)
        if result[1] ~= nil then
            local hasHouseKey = exports['aq-houses']:hasKey(result[1].license, result[1].citizenid, house)
            if hasHouseKey then
                cb(true)
            else
                cb(false)
            end
        else
            cb(false)
        end
    end)
end)

RegisterServerEvent('aq-garage:server:PayDepotPrice')
AddEventHandler('aq-garage:server:PayDepotPrice', function(vehicle, garage)
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    local bankBalance = Player.PlayerData.money["bank"]
    exports.oxmysql:fetch('SELECT * FROM player_vehicles WHERE plate = ?', {vehicle.plate}, function(result)
        if result[1] ~= nil then
            -- if Player.Functions.RemoveMoney("cash", result[1].depotprice, "paid-depot") then
            --     TriggerClientEvent("aq-garages:client:takeOutDepot", src, vehicle, garage)
            -- else
            if bankBalance >= result[1].depotprice then
                Player.Functions.RemoveMoney("bank", result[1].depotprice, "paid-depot")
                TriggerClientEvent("aq-garages:client:takeOutDepot", src, vehicle, garage)
            end
        end
    end)
end)

RegisterServerEvent('aq-garage:server:updateVehicleState')
AddEventHandler('aq-garage:server:updateVehicleState', function(state, plate, garage)
    exports.oxmysql:execute('UPDATE player_vehicles SET state = ?, garage = ?, depotprice = ? WHERE plate = ?',
        {state, garage, 0, plate})
end)

RegisterServerEvent('aq-garage:server:updateVehicleStatus')
AddEventHandler('aq-garage:server:updateVehicleStatus', function(fuel, engine, body, plate, garage)
    local src = source
    local pData = AQCore.Functions.GetPlayer(src)

    if engine > 1000 then
        engine = engine / 1000
    end

    if body > 1000 then
        body = body / 1000
    end

    exports.oxmysql:execute(
        'UPDATE player_vehicles SET fuel = ?, engine = ?, body = ? WHERE plate = ? AND citizenid = ? AND garage = ?',
        {fuel, engine, body, plate, pData.PlayerData.citizenid, garage})
end)