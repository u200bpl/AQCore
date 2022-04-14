AQCore.Functions.CreateCallback('aq-weed:server:getBuildingPlants', function(source, cb, building)
    local buildingPlants = {}

    exports.oxmysql:fetch('SELECT * FROM house_plants WHERE building = ?', {building}, function(plants)
        for i = 1, #plants, 1 do
            table.insert(buildingPlants, plants[i])
        end

        if buildingPlants ~= nil then
            cb(buildingPlants)
        else
            cb(nil)
        end
    end)
end)

RegisterServerEvent('aq-weed:server:placePlant')
AddEventHandler('aq-weed:server:placePlant', function(coords, sort, currentHouse)
    local random = math.random(1, 2)
    local gender
    if random == 1 then
        gender = "man"
    else
        gender = "woman"
    end
    exports.oxmysql:insert('INSERT INTO house_plants (building, coords, gender, sort, plantid) VALUES (?, ?, ?, ?, ?)',
        {currentHouse, coords, gender, sort, math.random(111111, 999999)})
    TriggerClientEvent('aq-weed:client:refreshHousePlants', -1, currentHouse)
end)

RegisterServerEvent('aq-weed:server:removeDeathPlant')
AddEventHandler('aq-weed:server:removeDeathPlant', function(building, plantId)
    exports.oxmysql:execute('DELETE FROM house_plants WHERE plantid = ? AND building = ?', {plantId, building})
    TriggerClientEvent('aq-weed:client:refreshHousePlants', -1, building)
end)

Citizen.CreateThread(function()
    while true do
        local housePlants = exports.oxmysql:fetchSync('SELECT * FROM house_plants', {})
        for k, v in pairs(housePlants) do
            if housePlants[k].food >= 50 then
                exports.oxmysql:execute('UPDATE house_plants SET food = ? WHERE plantid = ?',
                    {(housePlants[k].food - 1), housePlants[k].plantid})
                if housePlants[k].health + 1 < 100 then
                    exports.oxmysql:execute('UPDATE house_plants SET health = ? WHERE plantid = ?',
                        {(housePlants[k].health + 1), housePlants[k].plantid})
                end
            end

            if housePlants[k].food < 50 then
                if housePlants[k].food - 1 >= 0 then
                    exports.oxmysql:execute('UPDATE house_plants SET food = ? WHERE plantid = ?',
                        {(housePlants[k].food - 1), housePlants[k].plantid})
                end
                if housePlants[k].health - 1 >= 0 then
                    exports.oxmysql:execute('UPDATE house_plants SET health = ? WHERE plantid = ?',
                        {(housePlants[k].health - 1), housePlants[k].plantid})
                end
            end
        end
        TriggerClientEvent('aq-weed:client:refreshPlantStats', -1)
        Citizen.Wait((60 * 1000) * 19.2)
    end
end)

Citizen.CreateThread(function()
    while true do
        local housePlants = exports.oxmysql:fetchSync('SELECT * FROM house_plants', {})
        for k, v in pairs(housePlants) do
            if housePlants[k].health > 50 then
                local Grow = math.random(1, 3)
                if housePlants[k].progress + Grow < 100 then
                    exports.oxmysql:execute('UPDATE house_plants SET progress = ? WHERE plantid = ?',
                        {(housePlants[k].progress + Grow), housePlants[k].plantid})
                elseif housePlants[k].progress + Grow >= 100 then
                    if housePlants[k].stage ~= QBWeed.Plants[housePlants[k].sort]["highestStage"] then
                        if housePlants[k].stage == "stage-a" then
                            exports.oxmysql:execute('UPDATE house_plants SET stage = ? WHERE plantid = ?',
                                {'stage-b', housePlants[k].plantid})
                        elseif housePlants[k].stage == "stage-b" then
                            exports.oxmysql:execute('UPDATE house_plants SET stage = ? WHERE plantid = ?',
                                {'stage-c', housePlants[k].plantid})
                        elseif housePlants[k].stage == "stage-c" then
                            exports.oxmysql:execute('UPDATE house_plants SET stage = ? WHERE plantid = ?',
                                {'stage-d', housePlants[k].plantid})
                        elseif housePlants[k].stage == "stage-d" then
                            exports.oxmysql:execute('UPDATE house_plants SET stage = ? WHERE plantid = ?',
                                {'stage-e', housePlants[k].plantid})
                        elseif housePlants[k].stage == "stage-e" then
                            exports.oxmysql:execute('UPDATE house_plants SET stage = ? WHERE plantid = ?',
                                {'stage-f', housePlants[k].plantid})
                        elseif housePlants[k].stage == "stage-f" then
                            exports.oxmysql:execute('UPDATE house_plants SET stage = ? WHERE plantid = ?',
                                {'stage-g', housePlants[k].plantid})
                        end
                        exports.oxmysql:execute('UPDATE house_plants SET progress = ? WHERE plantid = ?',
                            {0, housePlants[k].plantid})
                    end
                end
            end
        end
        TriggerClientEvent('aq-weed:client:refreshPlantStats', -1)
        Citizen.Wait((60 * 1000) * 9.6)
    end
end)

AQCore.Functions.CreateUseableItem("weed_white-widow_seed", function(source, item)
    local Player = AQCore.Functions.GetPlayer(source)
    TriggerClientEvent('aq-weed:client:placePlant', source, 'white-widow', item)
end)

AQCore.Functions.CreateUseableItem("weed_skunk_seed", function(source, item)
    local Player = AQCore.Functions.GetPlayer(source)
    TriggerClientEvent('aq-weed:client:placePlant', source, 'skunk', item)
end)

AQCore.Functions.CreateUseableItem("weed_purple-haze_seed", function(source, item)
    local Player = AQCore.Functions.GetPlayer(source)
    TriggerClientEvent('aq-weed:client:placePlant', source, 'purple-haze', item)
end)

AQCore.Functions.CreateUseableItem("weed_og-kush_seed", function(source, item)
    local Player = AQCore.Functions.GetPlayer(source)
    TriggerClientEvent('aq-weed:client:placePlant', source, 'og-kush', item)
end)

AQCore.Functions.CreateUseableItem("weed_amnesia_seed", function(source, item)
    local Player = AQCore.Functions.GetPlayer(source)
    TriggerClientEvent('aq-weed:client:placePlant', source, 'amnesia', item)
end)

AQCore.Functions.CreateUseableItem("weed_ak47_seed", function(source, item)
    local Player = AQCore.Functions.GetPlayer(source)
    TriggerClientEvent('aq-weed:client:placePlant', source, 'ak47', item)
end)

AQCore.Functions.CreateUseableItem("weed_nutrition", function(source, item)
    local Player = AQCore.Functions.GetPlayer(source)
    TriggerClientEvent('aq-weed:client:foodPlant', source, item)
end)

RegisterServerEvent('aq-weed:server:removeSeed')
AddEventHandler('aq-weed:server:removeSeed', function(itemslot, seed)
    local Player = AQCore.Functions.GetPlayer(source)
    Player.Functions.RemoveItem(seed, 1, itemslot)
end)

RegisterServerEvent('aq-weed:server:harvestPlant')
AddEventHandler('aq-weed:server:harvestPlant', function(house, amount, plantName, plantId)
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    local weedBag = Player.Functions.GetItemByName('empty_weed_bag')
    local sndAmount = math.random(12, 16)

    if weedBag ~= nil then
        if weedBag.amount >= sndAmount then
            if house ~= nil then
                local result = exports.oxmysql:fetchSync(
                    'SELECT * FROM house_plants WHERE plantid = ? AND building = ?', {plantId, house})
                if result[1] ~= nil then
                    Player.Functions.AddItem('weed_' .. plantName .. '_seed', amount)
                    Player.Functions.AddItem('weed_' .. plantName, sndAmount)
                    Player.Functions.RemoveItem('empty_weed_bag', 1)
                    exports.oxmysql:execute('DELETE FROM house_plants WHERE plantid = ? AND building = ?',
                        {plantId, house})
                    TriggerClientEvent('AQCore:Notify', src, 'The plant has been harvested', 'success', 3500)
                    TriggerClientEvent('aq-weed:client:refreshHousePlants', -1, house)
                else
                    TriggerClientEvent('AQCore:Notify', src, 'This plant no longer exists?', 'error', 3500)
                end
            else
                TriggerClientEvent('AQCore:Notify', src, 'House Not Found', 'error', 3500)
            end
        else
            TriggerClientEvent('AQCore:Notify', src, "You Don't Have Enough Resealable Bags", 'error', 3500)
        end
    else
        TriggerClientEvent('AQCore:Notify', src, "You Don't Have Enough Resealable Bags", 'error', 3500)
    end
end)

RegisterServerEvent('aq-weed:server:foodPlant')
AddEventHandler('aq-weed:server:foodPlant', function(house, amount, plantName, plantId)
    local src = source
    local Player = AQCore.Functions.GetPlayer(src)
    local plantStats = exports.oxmysql:fetchSync(
        'SELECT * FROM house_plants WHERE building = ? AND sort = ? AND plantid = ?',
        {house, plantName, tostring(plantId)})
    TriggerClientEvent('AQCore:Notify', src,
        QBWeed.Plants[plantName]["label"] .. ' | Nutrition: ' .. plantStats[1].food .. '% + ' .. amount .. '% (' ..
            (plantStats[1].food + amount) .. '%)', 'success', 3500)
    if plantStats[1].food + amount > 100 then
        exports.oxmysql:execute('UPDATE house_plants SET food = ? WHERE building = ? AND plantid = ?',
            {100, house, plantId})
    else
        exports.oxmysql:execute('UPDATE house_plants SET food = ? WHERE building = ? AND plantid = ?',
            {(plantStats[1].food + amount), house, plantId})
    end
    Player.Functions.RemoveItem('weed_nutrition', 1)
    TriggerClientEvent('aq-weed:client:refreshHousePlants', -1, house)
end)