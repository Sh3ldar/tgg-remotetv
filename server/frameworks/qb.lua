if Config.Framework ~= 'QB' then return end

local Framework = exports[Config.FrameworkCore]:GetCoreObject()

Framework.Functions.CreateUseableItem("remotecontrol", function(source, item)
    TriggerClientEvent('tgg-remotetv:use', source)
end)
