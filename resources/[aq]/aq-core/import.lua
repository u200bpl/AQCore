-- This might eventually be deprecated for the export system

if GetCurrentResourceName() == 'aq-core' then
    function GetSharedObject()
        return AQCore
    end

    exports('GetSharedObject', GetSharedObject)
end

AQCore = exports['aq-core']:GetSharedObject()