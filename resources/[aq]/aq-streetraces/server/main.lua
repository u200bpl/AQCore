local Races = {}
RegisterServerEvent('aq-streetraces:NewRace')
AddEventHandler('aq-streetraces:NewRace', function(RaceTable)
    local src = source
    local RaceId = math.random(1000, 9999)
    local xPlayer = AQCore.Functions.GetPlayer(src)
    if xPlayer.Functions.RemoveMoney('cash', RaceTable.amount, "streetrace-created") then
        Races[RaceId] = RaceTable
        Races[RaceId].creator = AQCore.Functions.GetIdentifier(src, 'license')
        table.insert(Races[RaceId].joined, AQCore.Functions.GetIdentifier(src, 'license'))
        TriggerClientEvent('aq-streetraces:SetRace', -1, Races)
        TriggerClientEvent('aq-streetraces:SetRaceId', src, RaceId)
        TriggerClientEvent('AQCore:Notify', src, "You joind the race for €"..Races[RaceId].amount..",-", 'success')
    end
end)

RegisterServerEvent('aq-streetraces:RaceWon')
AddEventHandler('aq-streetraces:RaceWon', function(RaceId)
    local src = source
    local xPlayer = AQCore.Functions.GetPlayer(src)
    xPlayer.Functions.AddMoney('cash', Races[RaceId].pot, "race-won")
    TriggerClientEvent('AQCore:Notify', src, "You won the race and €"..Races[RaceId].pot..",- recieved", 'success')
    TriggerClientEvent('aq-streetraces:SetRace', -1, Races)
    TriggerClientEvent('aq-streetraces:RaceDone', -1, RaceId, GetPlayerName(src))
end)

RegisterServerEvent('aq-streetraces:JoinRace')
AddEventHandler('aq-streetraces:JoinRace', function(RaceId)
    local src = source
    local xPlayer = AQCore.Functions.GetPlayer(src)
    local zPlayer = AQCore.Functions.GetPlayer(Races[RaceId].creator)
    if zPlayer ~= nil then
        if xPlayer.PlayerData.money.cash >= Races[RaceId].amount then
            Races[RaceId].pot = Races[RaceId].pot + Races[RaceId].amount
            table.insert(Races[RaceId].joined, AQCore.Functions.GetIdentifier(src, 'license'))
            if xPlayer.Functions.RemoveMoney('cash', Races[RaceId].amount, "streetrace-joined") then
                TriggerClientEvent('aq-streetraces:SetRace', -1, Races)
                TriggerClientEvent('aq-streetraces:SetRaceId', src, RaceId)
                TriggerClientEvent('AQCore:Notify', zPlayer.PlayerData.source, GetPlayerName(src).." Joined the race", 'primary')
            end
        else
            TriggerClientEvent('AQCore:Notify', src, "You dont have enough cash", 'error')
        end
    else
        TriggerClientEvent('AQCore:Notify', src, "The person wo made the race is offline!", 'error')
        Races[RaceId] = {}
    end
end)

AQCore.Commands.Add("createrace", "Start A Street Race", {{name="amount", help="The Stake Amount For The Race."}}, false, function(source, args)
    local src = source
    local amount = tonumber(args[1])
    local Player = AQCore.Functions.GetPlayer(src)

    if GetJoinedRace(AQCore.Functions.GetIdentifier(src, 'license')) == 0 then
        TriggerClientEvent('aq-streetraces:CreateRace', src, amount)
    else
        TriggerClientEvent('AQCore:Notify', src, "You Are Already In A Race", 'error')    
    end
end)

AQCore.Commands.Add("stoprace", "Stop The Race You Created", {}, false, function(source, args)
    local src = source
    CancelRace(src)
end)

AQCore.Commands.Add("quitrace", "Get Out Of A Race. (You Will NOT Get Your Money Back!)", {}, false, function(source, args)
    local src = source
    local xPlayer = AQCore.Functions.GetPlayer(src)
    local RaceId = GetJoinedRace(AQCore.Functions.GetIdentifier(src, 'license'))
    local zPlayer = AQCore.Functions.GetPlayer(Races[RaceId].creator)

    if RaceId ~= 0 then
        if GetCreatedRace(AQCore.Functions.GetIdentifier(src, 'license')) ~= RaceId then
            RemoveFromRace(AQCore.Functions.GetIdentifier(src, 'license'))
            TriggerClientEvent('AQCore:Notify', src, "You Have Stepped Out Of The Race! And You Lost Your Money", 'error')
        else
            TriggerClientEvent('AQCore:Notify', src, "/stoprace To Stop The Race", 'error')
        end
    else
        TriggerClientEvent('AQCore:Notify', src, "You Are Not In A Race ", 'error')
    end
end)

AQCore.Commands.Add("startrace", "Start The Race", {}, false, function(source, args)
    local src = source
    local RaceId = GetCreatedRace(AQCore.Functions.GetIdentifier(src, 'license'))
    
    if RaceId ~= 0 then
      
        Races[RaceId].started = true
        TriggerClientEvent('aq-streetraces:SetRace', -1, Races)
        TriggerClientEvent("aq-streetraces:StartRace", -1, RaceId)
    else
        TriggerClientEvent('AQCore:Notify', src, "You Have Not Started A Race", 'error')
        
    end
end)

function CancelRace(source)
    local RaceId = GetCreatedRace(AQCore.Functions.GetIdentifier(source, 'license'))
    local Player = AQCore.Functions.GetPlayer(source)

    if RaceId ~= 0 then
        for key, race in pairs(Races) do
            if Races[key] ~= nil and Races[key].creator == Player.PlayerData.license then
                if not Races[key].started then
                    for _, iden in pairs(Races[key].joined) do
                        local xdPlayer = AQCore.Functions.GetPlayer(iden)
                            xdPlayer.Functions.AddMoney('cash', Races[key].amount, "race-cancelled")
                            TriggerClientEvent('AQCore:Notify', xdPlayer.PlayerData.source, "Race Has Stopped, You Got Back $"..Races[key].amount.."", 'error')
                            TriggerClientEvent('aq-streetraces:StopRace', xdPlayer.PlayerData.source)
                            RemoveFromRace(iden)
                    end
                else
                    TriggerClientEvent('AQCore:Notify', Player.PlayerData.source, "The Race Has Already Started", 'error')
                end
                TriggerClientEvent('AQCore:Notify', source, "Race Stopped!", 'error')
                Races[key] = nil
            end
        end
        TriggerClientEvent('aq-streetraces:SetRace', -1, Races)
    else
        TriggerClientEvent('AQCore:Notify', source, "You Have Not Started A Race!", 'error')
    end
end

function RemoveFromRace(identifier)
    for key, race in pairs(Races) do
        if Races[key] ~= nil and not Races[key].started then
            for i, iden in pairs(Races[key].joined) do
                if iden == identifier then
                    table.remove(Races[key].joined, i)
                end
            end
        end
    end
end

function GetJoinedRace(identifier)
    for key, race in pairs(Races) do
        if Races[key] ~= nil and not Races[key].started then
            for _, iden in pairs(Races[key].joined) do
                if iden == identifier then
                    return key
                end
            end
        end
    end
    return 0
end

function GetCreatedRace(identifier)
    for key, race in pairs(Races) do
        if Races[key] ~= nil and Races[key].creator == identifier and not Races[key].started then
            return key
        end
    end
    return 0
end
