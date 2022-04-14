local function tPrint(tbl, indent)
    indent = indent or 0
    for k, v in pairs(tbl) do
        local tblType = type(v)
        local formatting = ("%s ^3%s:^0"):format(string.rep("  ", indent), k)

        if tblType == "table" then
            print(formatting)
            tPrint(v, indent + 1)
        elseif tblType == 'boolean' then
            print(("%s^1 %s ^0"):format(formatting,v))
        elseif tblType == "function" then
            print(("%s^9 %s ^0"):format(formatting,v))
        elseif tblType == 'number' then
            print(("%s^5 %s ^0"):format(formatting,v))
        elseif tblType == 'string' then
            print(("%s ^2'%s' ^0"):format(formatting,v))
        else
            print(("%s^2 %s ^0"):format(formatting,v))
        end
    end
end

RegisterServerEvent('AQCore:DebugSomething', function(table, indent)
    local resource = GetInvokingResource() or "aq-core"

    print(('\x1b[4m\x1b[36m[ %s : DEBUG]\x1b[0m'):format(resource))

    tPrint(table, indent)

    print('\x1b[4m\x1b[36m[ END DEBUG ]\x1b[0m')
end)

function AQCore.Debug(table, indent)
    TriggerEvent('AQCore:DebugSomething', table, indent)
end

function AQCore.ShowError(resource, msg)
    print('\x1b[31m[' .. resource .. ':ERROR]\x1b[0m ' .. msg)
end

function AQCore.ShowSuccess(resource, msg)
    print('\x1b[32m[' .. resource .. ':LOG]\x1b[0m ' .. msg)
end