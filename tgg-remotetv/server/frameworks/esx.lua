if Config.Framework ~= 'ESX' then return end

local Framework = exports[Config.FrameworkCore]:getSharedObject()

Framework.RegisterUsableItem('remotecontrol', function(source)
    TriggerClientEvent('tgg-remotetv:use', source)
end)
