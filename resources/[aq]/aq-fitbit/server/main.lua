AQCore.Functions.CreateUseableItem("fitbit", function(source, item)
    local Player = AQCore.Functions.GetPlayer(source)
    TriggerClientEvent('aq-fitbit:use', source)
end)

RegisterServerEvent('aq-fitbit:server:setValue')
AddEventHandler('aq-fitbit:server:setValue', function(type, value)
    local src = source
    local ply = AQCore.Functions.GetPlayer(src)
    local fitbitData = {}

    if type == "thirst" then
        local currentMeta = ply.PlayerData.metadata["fitbit"]
        fitbitData = {
            thirst = value,
            food = currentMeta.food
        }
    elseif type == "food" then
        local currentMeta = ply.PlayerData.metadata["fitbit"]
        fitbitData = {
            thirst = currentMeta.thirst,
            food = value
        }
    end

    ply.Functions.SetMetaData('fitbit', fitbitData)
end)

AQCore.Functions.CreateCallback('aq-fitbit:server:HasFitbit', function(source, cb)
    local Ply = AQCore.Functions.GetPlayer(source)
    local Fitbit = Ply.Functions.GetItemByName("fitbit")

    if Fitbit ~= nil then
        cb(true)
    else
        cb(false)
    end
end)