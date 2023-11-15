local CurrentlyWorkingTVs = {}

-- ^^^^^^^^^^^^^^^^--
-- FUNCTIONS START --
---------------------

local function GetCurrentlyWorkingTV(coords)
    for k, v in pairs(CurrentlyWorkingTVs) do
        if #(v3(v.coords) - v3(coords)) < 0.01 then
            return k, v
        end
    end
end

local function SetTelevision(coords, key, value, update)
    local index, data = GetTelevision(coords)

    if (index ~= nil) then
        if (Televisions[index] == nil) then
            Televisions[index] = {}
        end

        Televisions[index][key] = value
    else
        index = os.time()

        while Televisions[index] do
            index = index + 1
            Citizen.Wait(0)
        end

        if (Televisions[index] == nil) then
            Televisions[index] = {}
        end

        Televisions[index][key] = value
    end

    Televisions[index].coords = coords

    if key ~= "volume" and key ~= "paused" then
        Televisions[index].update_time = os.time()
    end

    if (update) then
        TriggerClientEvent("tgg-remotetv:event", -1, Televisions, index, key, value)
    end

    return index
end

local function SetChannel(source, data)
    if data then
        for k, v in pairs(Channels) do
            if (Channels[k].source == source) then
                return
            end
        end

        local index = 1

        while Channels[index] do
            index = index + 1
            Citizen.Wait(0)
        end

        Channels[index] = data
        Channels[index].source = source

        TriggerClientEvent("tgg-remotetv:broadcast", -1, Channels, index)

        return
    else
        for k, v in pairs(Channels) do
            if (Channels[k].source == source) then
                Channels[k] = nil

                TriggerClientEvent("tgg-remotetv:broadcast", -1, Channels, k)

                return
            end
        end
    end
end

-------------------
-- FUNCTIONS END --
-- **************--

-- ^^^^^^^^^^^^^^--
-- THREADS START --
-------------------

CreateThread(function()
    local dependeciesStarted = false;

    local genericStatus = GetResourceState('generic_texture_renderer_gfx')

    if genericStatus == 'started' then
        dependeciesStarted = true
    else
        local repeatCount = 0
        local repeatMax = 10
        -- Wait for the resouce to start.
        while genericStatus == 'starting' do
            print('Waiting for `generic_texture_renderer_gfx` to start...')

            Wait(500)
            genericStatus = GetResourceState('generic_texture_renderer_gfx')
            repeatCount = repeatCount + 1

            if repeatCount >= repeatMax then
                break
            end
        end

        if genericStatus == 'started' then
            dependeciesStarted = true
        end

        if not dependeciesStarted then
            print('Dependency missing - `generic_texture_renderer_gfx`(Read INSTRUCTIONS)')
        end
    end
end)

-----------------
-- THREADS END --
-- ************--

-- ^^^^^^^^^^^^^^^^^--q
-- NET EVENTS START --
----------------------

RegisterNetEvent("tgg-remotetv:update-currently-working-tv-app", function(coords, currentApp)
    local key, value = GetCurrentlyWorkingTV(coords)

    CurrentlyWorkingTVs[key].currentApp = currentApp

    TriggerClientEvent("tgg-remotetv:sync-currently-working-tvs", -1, CurrentlyWorkingTVs)
end)

RegisterNetEvent("tgg-remotetv:update-currently-working-tv-volume", function(coords, volume)
    local key, value = GetCurrentlyWorkingTV(coords)

    CurrentlyWorkingTVs[key].volume = volume

    TriggerClientEvent("tgg-remotetv:sync-currently-working-tvs", -1, CurrentlyWorkingTVs)
end)

RegisterNetEvent("tgg-remotetv:update-currently-working-tvs", function(tv)
    local key, value = GetCurrentlyWorkingTV(tv.coords)
    if not value then
        tv.volume = 0.5
        tv.currentApp = 'home'

        table.insert(CurrentlyWorkingTVs, tv)
    elseif value then
        table.remove(CurrentlyWorkingTVs, key)

        TriggerClientEvent("tgg-remotetv:remove-current-tv", -1)
    end

    TriggerClientEvent("tgg-remotetv:sync-currently-working-tvs", -1, CurrentlyWorkingTVs)
end)

RegisterNetEvent("tgg-remotetv:request-sync-currently-working-tvs", function()
    TriggerClientEvent("tgg-remotetv:sync-currently-working-tvs", -1, CurrentlyWorkingTVs)
end)

RegisterNetEvent("tgg-remotetv:request-sync-currently-working-tvs-local", function(source)
    local _source = source

    TriggerClientEvent("tgg-remotetv:sync-currently-working-tvs", _source, CurrentlyWorkingTVs)
end)

RegisterNetEvent("tgg-remotetv:requestSync", function(coords)
    local _source = source

    TriggerClientEvent("tgg-remotetv:requestSync", _source, coords, {
        current_time = os.time()
    })
end)

RegisterNetEvent("tgg-remotetv:event", function(data, key, value)
    SetTelevision(data.coords, key, value, true)
end)

RegisterNetEvent("tgg-remotetv:broadcast", function(data)
    local _source = source

    SetChannel(_source, data)
end)

RegisterNetEvent("tgg-remotetv:requestUpdate", function()
    local _source = source

    TriggerClientEvent("tgg-remotetv:requestUpdate", _source, {
        Televisions = Televisions,
        Channels = Channels
    })
end)

--------------------
-- NET EVENTS END --
-- ****************--

AddEventHandler('onResourceStart', function()
    local resource = GetInvokingResource() or GetCurrentResourceName()

    if not Config.CheckForUpdates or not resource == 'tgg-remotetv' then return end

    local currentVersion = GetResourceMetadata(resource, 'version', 0)
    if currentVersion then
        currentVersion = currentVersion:match('%d+%.%d+%.%d+')
    end

    if not currentVersion then
        return print(("^1Unable to determine current resource version for '%s' ^0"):format(
            resource))
    end

    SetTimeout(3000, function()
        PerformHttpRequest(('https://api.github.com/repos/TeamsGG-Development/tgg-remotetv/releases/latest'),
            function(status, response)
                if status ~= 200 then return end

                response = json.decode(response)
                if response.prerelease then return end

                local latestVersion = response.tag_name:match('%d+%.%d+%.%d+')

                if not latestVersion or latestVersion == currentVersion then return end

                local cv = { string.strsplit('.', currentVersion) }
                local lv = { string.strsplit('.', latestVersion) }

                for i = 1, #cv do
                    local current, minimum = tonumber(cv[i]), tonumber(lv[i])

                    if current ~= minimum then
                        if current < minimum then
                            return print(('^4📺 An update is available for %s (current ^1v%s^4, latest ^2v%s^4)^0 🆙')
                                :format(
                                    resource,
                                    currentVersion,
                                    latestVersion))
                        else
                            break
                        end
                    end
                end
            end, 'GET')
    end)
end)
