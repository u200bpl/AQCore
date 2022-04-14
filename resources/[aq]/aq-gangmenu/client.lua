local PlayerGang = {}
local isLoggedIn = false
local isInMenu = false
local sleep

RegisterNetEvent('AQCore:Client:OnPlayerLoaded')
AddEventHandler('AQCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
    PlayerGang = AQCore.Functions.GetPlayerData().gang
end)

RegisterNetEvent('AQCore:Client:OnPlayerUnload')
AddEventHandler('AQCore:Client:OnPlayerUnload', function()
	isLoggedIn = false
end)

RegisterNetEvent('AQCore:Client:OnGangUpdate')
AddEventHandler('AQCore:Client:OnGangUpdate', function(GangInfo)
    PlayerGang = GangInfo
end)

-- MENU
local menu = MenuV:CreateMenu(false, 'Boss Menu', 'topright', 155, 0, 0, 'size-125', 'none', 'menuv', 'main')
local menu2 = MenuV:CreateMenu(false, 'Maatschappelijk geld', 'topright', 155, 0, 0, 'size-125', 'none', 'menuv', 'society')
local menu3 = MenuV:CreateMenu(false, 'Personeelsbeheer', 'topright', 155, 0, 0, 'size-125', 'none', 'menuv', 'employees')
local menu4 = MenuV:CreateMenu(false, 'Wervingsmenu', 'topright', 155, 0, 0, 'size-125', 'none', 'menuv', 'recruit')

RegisterNetEvent('aq-gangmenu:client:openMenu')
AddEventHandler('aq-gangmenu:client:openMenu', function()
    MenuV:OpenMenu(menu)
end)

local menu_button = menu:AddButton({
    icon = '📋',
    label = 'Werknemers',
    value = menu3,
    description = 'Personeelsbeheer'
})
local menu_button1 = menu:AddButton({
    icon = '🤝',
    label = 'Rekruut',
    value = menu4,
    description = 'Huur nieuwe spelers in'
})
local menu_button2 = menu:AddButton({
    icon = '📦',
    label = 'Opslag',
    value = nil,
    description = 'Persoonlijke opslag'
})
local menu_button3 = menu:AddButton({
    icon = '👕',
    label = 'Outfits',
    value = nil,
    description = 'Bekijk outfits'
})
local menu_button4 = menu:AddButton({
    icon = '💰',
    label = 'Maatschappelijk geld',
    value = menu2,
    description = 'Maatschappelijk geld bekijken/beheren'
})
local menu_button5 = menu2:AddButton({
    icon = '💶',
    label = '',
    value = nil,
    description = 'Huidige Euros'
})
local menu_button6 = menu2:AddButton({
    icon = '🤑',
    label = 'Opnemen',
    value = menu2,
    description = 'Neem geld op van de pot'
})
local menu_button7 = menu2:AddButton({
    icon = '🏦',
    label = 'Storten',
    value = menu2,
    description = 'Stort geld in de pot'
})

-- Storage
menu_button2:On("select", function()
    MenuV:CloseMenu(menu)
    TriggerServerEvent("inventory:server:OpenInventory", "stash", "boss_" .. PlayerGang.name, {
        maxweight = 4000000,
        slots = 500,
    })
    TriggerEvent("inventory:client:SetCurrentStash", "boss_" .. PlayerGang.name)
end)

-- Outfit
menu_button3:On("select", function()
    MenuV:CloseMenu(menu)
    TriggerEvent('aq-clothing:client:openOutfitMenu')
end)

-- Society
menu_button4:On('select', function()
    UpdateSociety()
end)

-- Withdraw
menu_button6:On("select", function()
    local result = LocalInput('Withdrawal Amount', 255, '')
    if result ~= nil and PlayerGang.name and PlayerGang.isboss then
        TriggerServerEvent("aq-gangmenu:server:withdrawMoney", tonumber(result))
        UpdateSociety()
    else
        AQCore.Functions.Notify('Je rank is te laag', "error")
    end
end)

-- Deposit
menu_button7:On("select", function()
    local result = LocalInput('Deposit Amount', 255, '')
    if result ~= nil then
        TriggerServerEvent("aq-gangmenu:server:depositMoney", tonumber(result))
        UpdateSociety()
    end
end)

-- Employees
menu_button:On("select", function()
    menu3:ClearItems()
    AQCore.Functions.TriggerCallback('aq-gangmenu:server:GetEmployees', function(cb)
        for k,v in pairs(cb) do
            local menu_button8 = menu3:AddButton({
                label = v.grade.name.. ' ' ..v.name,
                value = v,
                description = 'Medewerker',
                select = function(btn)
                    local select = btn.Value
                    ManageEmployees(select)
                end
            })
        end
    end, PlayerGang.name)
end)

-- Recruit
menu_button1:On("select", function()
    menu4:ClearItems()
    local playerPed = PlayerPedId()
    for k,v in pairs(AQCore.Functions.GetPlayersFromCoords(GetEntityCoords(playerPed), 10.0)) do
        if v and v ~= PlayerId() then
            local menu_button10 = menu4:AddButton({
                label = GetPlayerName(v),
                value = v,
                description = 'Beschikbare rekruuts',
                select = function(btn)
                    local select = btn.Value
                    TriggerServerEvent('aq-gangmenu:server:giveJob', GetPlayerServerId(v))
                end
            })
        end
    end
end)

-- MAIN THREAD
CreateThread(function()
    while true do
        sleep = 1000
        if PlayerGang.name ~= nil then
            local pos = GetEntityCoords(PlayerPedId())
            for k, v in pairs(Config.Gangs) do
                if k == PlayerGang.name then
                    if #(pos - v) < 1.0 then
                        sleep = 7
                        DrawText3D(v, "~g~E~w~ - Gang Menu")
                        if IsControlJustReleased(0, 38) then
                            MenuV:OpenMenu(menu)
                        end
                    end
                end
            end
        end
      Wait(sleep)
    end
end)

-- FUNCTIONS
function UpdateSociety()
    AQCore.Functions.TriggerCallback('aq-gangmenu:server:GetAccount', function(cb)
        menu_button5.Label = 'Maatschappelijk bedrag: €' ..comma_value(cb)
    end, PlayerGang.name)
end

function ManageEmployees(employee)
    local manageroptions = MenuV:CreateMenu(false, employee.name .. ' Opties', 'topright', 155, 0, 0, 'size-125', 'none', 'menuv')
    manageroptions:ClearItems()
    MenuV:OpenMenu(manageroptions)
    buttons = {
        [1] = {
            icon = '↕️',
            label = "Promoten/Degraderen",
            value = "promote",
            description = "Promote " .. employee.name
        },
        [3] = {
            icon = '🔥',
            label = "Ontslaan",
            value = "Fire",
            description = "Ontsla " .. employee.name
        }
    }
    for k, v in pairs(buttons) do
        local menu_button9 = manageroptions:AddButton({
            icon = v.icon,
            label = v.label,
            value = v.value,
            description = v.description,
            select = function(btn)
                local values = btn.Value
                if values == 'promote' then
                    local result = LocalInput('New Grade Level', 255, '')
                    if result ~= nil then
                        TriggerServerEvent('aq-gangmenu:server:updateGrade', employee.source, tonumber(result))
                    end
                else
                    TriggerServerEvent('aq-gangmenu:server:fireEmployee', employee.source)
                end
            end
        })
    end
end

-- UTIL
function DrawText3D(v, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(v, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 0)
    ClearDrawOrigin()
end

function LocalInput(text, number, windows)
    AddTextEntry("FMMC_MPM_NA", text)
    DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", windows or "", "", "", "", number or 30)
    while (UpdateOnscreenKeyboard() == 0) do
        DisableAllControlActions(0)
        Wait(0)
    end
    if (GetOnscreenKeyboardResult()) then
    local result = GetOnscreenKeyboardResult()
        return result
    end
end

function comma_value(amount)
    local formatted = amount
    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k==0) then
            break
        end
    end
    return formatted
end
