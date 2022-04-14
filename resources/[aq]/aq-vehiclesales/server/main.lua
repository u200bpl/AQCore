AQCore.Functions.CreateCallback('aq-occasions:server:getVehicles', function(source, cb)
    local result = exports.oxmysql:fetchSync('SELECT * FROM occasion_vehicles', {})
    if result[1] ~= nil then
        cb(result)
    else
        cb(nil)
    end
end)

AQCore.Functions.CreateCallback("aq-occasions:server:getSellerInformation", function(source, cb, citizenid)
    local src = source

    exports.oxmysql:fetch('SELECT * FROM players WHERE citizenid = ?', {citizenid}, function(result)
        if result[1] ~= nil then
            cb(result[1])
        else
            cb(nil)
        end
    end)
end)

RegisterServerEvent('aq-occasions:server:ReturnVehicle')
AddEventHandler('aq-occasions:server:ReturnVehicle', function(vehicleData)
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    local result = exports.oxmysql:fetchSync('SELECT * FROM occasion_vehicles WHERE plate = ? AND occasionid = ?',
        {vehicleData['plate'], vehicleData["oid"]})
    if result[1] ~= nil then
        if result[1].seller == Player.PlayerData.citizenid then
            exports.oxmysql:insert(
                'INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)',
                {Player.PlayerData.license, Player.PlayerData.citizenid, vehicleData["model"],
                 GetHashKey(vehicleData["model"]), vehicleData["mods"], vehicleData["plate"], 0})
            exports.oxmysql:execute('DELETE FROM occasion_vehicles WHERE occasionid = ? AND plate = ?',
                {vehicleData["oid"], vehicleData['plate']})
            TriggerClientEvent("aq-occasions:client:ReturnOwnedVehicle", src, result[1])
            TriggerClientEvent('aq-occasion:client:refreshVehicles', -1)
        else
            TriggerClientEvent('AQCore:Notify', src, 'This is not your vehicle', 'error', 3500)
        end
    else
        TriggerClientEvent('AQCore:Notify', src, 'Vehicle does not exist', 'error', 3500)
    end
end)

RegisterServerEvent('aq-occasions:server:sellVehicle')
AddEventHandler('aq-occasions:server:sellVehicle', function(vehiclePrice, vehicleData)
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    exports.oxmysql:execute('DELETE FROM player_vehicles WHERE plate = ? AND vehicle = ?',
        {vehicleData.plate, vehicleData.model})
    exports.oxmysql:insert(
        'INSERT INTO occasion_vehicles (seller, price, description, plate, model, mods, occasionid) VALUES (?, ?, ?, ?, ?, ?, ?)',
        {Player.PlayerData.citizenid, vehiclePrice, escapeSqli(vehicleData.desc), vehicleData.plate, vehicleData.model,
         json.encode(vehicleData.mods), generateOID()})
    TriggerEvent("aq-log:server:sendLog", Player.PlayerData.citizenid, "vehiclesold", {
        model = vehicleData.model,
        vehiclePrice = vehiclePrice
    })
    TriggerEvent("aq-log:server:CreateLog", "vehicleshop", "Vehicle for Sale", "red",
        "**" .. GetPlayerName(src) .. "** has a " .. vehicleData.model .. " priced at " .. vehiclePrice)

    TriggerClientEvent('aq-occasion:client:refreshVehicles', -1)
end)

RegisterServerEvent('aq-occasions:server:sellVehicleBack')
AddEventHandler('aq-occasions:server:sellVehicleBack', function(vData)
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    local cid = Player.PlayerData.citizenid
    local price = math.floor(vData.price / 2)
    local plate = vData.plate

    Player.Functions.AddMoney('bank', price)
    TriggerClientEvent('AQCore:Notify', src, 'You have sold your car for $' .. price, 'success', 5500)
    exports.oxmysql:execute('DELETE FROM player_vehicles WHERE plate = ?', {plate})
end)

RegisterServerEvent('aq-occasions:server:buyVehicle')
AddEventHandler('aq-occasions:server:buyVehicle', function(vehicleData)
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    local result = exports.oxmysql:fetchSync('SELECT * FROM occasion_vehicles WHERE plate = ? AND occasionid = ?',
        {vehicleData['plate'], vehicleData["oid"]})
    if result[1] ~= nil and next(result[1]) ~= nil then
        if Player.PlayerData.money.bank >= result[1].price then
            local SellerCitizenId = result[1].seller
            local SellerData = AQCore.Functions.GetPlayerByCitizenId(SellerCitizenId)
            -- New price calculation minus tax
            local NewPrice = math.ceil((result[1].price / 100) * 77)
            Player.Functions.RemoveMoney('bank', result[1].price)
            -- Insert vehicle for buyer
            exports.oxmysql:insert(
                'INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)', {
                    Player.PlayerData.license,
                    Player.PlayerData.citizenid, result[1]["model"],
                    GetHashKey(result[1]["model"]),
                    result[1]["mods"],
                    result[1]["plate"],
                    0
                })
            -- Handle money transfer
            if SellerData ~= nil then
                -- Add money for online
                SellerData.Functions.AddMoney('bank', NewPrice)
            else
                -- Add money for offline
                local BuyerData = exports.oxmysql:fetchSync('SELECT * FROM players WHERE citizenid = ?',
                    {SellerCitizenId})
                if BuyerData[1] ~= nil then
                    local BuyerMoney = json.decode(BuyerData[1].money)
                    BuyerMoney.bank = BuyerMoney.bank + NewPrice
                    exports.oxmysql:execute('UPDATE players SET money = ? WHERE citizenid = ?', {json.encode(BuyerMoney), SellerCitizenId})
                end
            end
            TriggerEvent("aq-log:server:CreateLog", "vehicleshop", "bought", "green", "**" .. GetPlayerName(src) .. "** has bought for " .. result[1].price .. " (" .. result[1].plate ..") from **" .. SellerCitizenId .. "**")
            TriggerClientEvent("aq-occasions:client:BuyFinished", src, result[1])
            TriggerClientEvent('aq-occasion:client:refreshVehicles', -1)
            -- Delete vehicle from Occasion
            exports.oxmysql:execute('DELETE FROM occasion_vehicles WHERE plate = ? AND occasionid = ?',
                {result[1].plate, result[1].occasionid})
            -- Send selling mail to seller
            TriggerEvent('aq-phone:server:sendNewMailToOffline', SellerCitizenId, {
                sender = 'Larrys RV Sales',
                subject = "You have sold a vehicle!",
                message = 'You made $'..NewPrice..' from the sale of your '..AQCore.Shared.Vehicles[result[1].model].name..''
            })
        else
            TriggerClientEvent('AQCore:Notify', src, 'You dont have enough money', 'error', 3500)
        end
    end
end)

AQCore.Functions.CreateCallback("aq-vehiclesales:server:CheckModelName", function(source, cb, plate)
    if plate then
        local ReturnData = exports.oxmysql:scalarSync("SELECT vehicle FROM player_vehicles WHERE plate = ?", {plate})
        cb(ReturnData)
    end
end)

function generateOID()
    local num = math.random(1, 10) .. math.random(111, 999)

    return "OC" .. num
end

function round(number)
    return number - (number % 1)
end

function escapeSqli(str)
    local replacements = {
        ['"'] = '\\"',
        ["'"] = "\\'"
    }
    return str:gsub("['\"]", replacements) -- or string.gsub( source, "['\"]", replacements )
end
