--NOTIFY
RegisterNetEvent(GetCurrentResourceName() .. ":client:notify", function(title, text, length, type)
	Notify(title, text, length, type)
end)

-- Showns notification to the player. Uses Config.Notify to select notification resource
--- @param title string
--- @param text string
--- @param type string
--- @param src number
function Notify(title, text, type, src)
	local length = 5000
	if IsDuplicityVersion() then
		-- Running on server
		if Config.SetNotify == "qb" then
			-- https://docs.qbcore.org/qbcore-documentation/qb-core/client-event-reference#qbcore-notify
			TriggerClientEvent("QBCore:Notify", src, text, type, length)
		elseif Config.SetNotify == "okok" then
			-- https://docs.okokscripts.io/scripts/okoknotify
			TriggerClientEvent("okokNotify:Alert", src, title, text, length, type)
		elseif Config.SetNotify == "es.lib" then
			-- https://github.com/ESFramework/es.lib
			TriggerClientEvent("es.lib:showNotify", src, title, "noicon", text, length, type)
		elseif Config.SetNotify == "brutal" then
			-- https://docs.brutalscripts.com/site/scripts/brutal-notify
			TriggerClientEvent("brutal_notify:SendAlert", src, title, text, length, type)
		elseif Config.SetNotify == "b-dev" then
			-- https://forum.cfx.re/t/paid-standalone-notify-the-best-notify-with-6-different-types/4905568
			TriggerClientEvent("b-notify:notify", src, type, title, text)
		elseif Config.SetNotify == "ox" then
			-- https://overextended.github.io/docs/ox_lib/Interface/Client/notify/
			TriggerClientEvent(GetCurrentResourceName() .. ":client:notify", src, title, text, length, type)
		elseif Config.SetNotify == "other" then
			SendNotificationToClient(type, title, text, "far fa-id-card", length)
		end
	else
		-- Running on client
		if Config.SetNotify == "qb" then
			-- https://docs.qbcore.org/qbcore-documentation/qb-core/client-event-reference#qbcore-notify
			TriggerEvent("QBCore:Notify", text, type, length)
		elseif Config.SetNotify == "okok" then
			-- https://docs.okokscripts.io/scripts/okoknotify
			exports["okokNotify"]:Alert(title, text, length, type)
		elseif Config.SetNotify == "es.lib" then
			-- https://github.com/ESFramework/es.lib
			TriggerEvent("es.lib:showNotify", title, "noicon", text, length, type)
		elseif Config.SetNotify == "brutal" then
			-- https://docs.brutalscripts.com/site/scripts/brutal-notify
			exports["brutal_notify"]:SendAlert(title, text, length, type)
		elseif Config.SetNotify == "b-dev" then
			-- https://forum.cfx.re/t/paid-standalone-notify-the-best-notify-with-6-different-types/4905568
			TriggerEvent("b-notify:notify", type, title, text)
		elseif Config.SetNotify == "ox" then
			-- https://overextended.github.io/docs/ox_lib/Interface/Client/notify/
			-- You need to import ox_lib in the fxmanifest.lua
			lib.notify({
				title = title,
				description = text,
				type = type,
				duration = length,
			})
		elseif Config.SetNotify == "other" then
			exports.notify:display(
				{
					type = "error",
					title = Locales[Config.Locale].television.TelevisionName,
					text = title,
					icon = "far fa-id-card",
					length = length,
				})
		end
	end
end

--STANDALONE (USABLE ITEM) WRITE YOUR OWN FUNCTION (WIP)
--
--RegisterNetEvent("inventory:usedItem")
--AddEventHandler(
--    "inventory:usedItem",
--    function(itemName, slot, data)
--        if itemName == "remotecontrol" then
--			EnableRemoteControl()
--        end
--    end
--)
