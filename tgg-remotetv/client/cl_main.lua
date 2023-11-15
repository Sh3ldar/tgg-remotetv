local DEFAULT_TV_URL = "https://cfx-nui-" .. CurrentResourceName .. "/html/index.html"

local sfName = 'generic_texture_renderer'

local remoteControlAnimLib = ""
local remoteControlAnim = ""

local remotecontrolModel = "prop_remotecontrol"
local currentApp = nil -- 'youtube', 'twitch', 'browser', 'home', 'tv'

local Locations = Config.Locations
local duiUrl = DEFAULT_TV_URL

local remoteControlProp = 0
local width = 1280
local height = 720
local volume = 0.5

local lastPlayedVideos = {}
local CURRENT_SCREEN = nil
local sfHandle = nil
local duiObj = nil

local RemoteControlOpen = false
local isCurrentScreenOn = false
local isVideoPaused = false
local playerLoaded = false
local waitForLoad = false

local CurrentlyWorkingTVsLocal = {}
local TelevisionsLocal = {}

if not Config.UsableItem and Config.Framework == 'Standalone' then
    if Config.CommandDescription and Config.Keybind then
        RegisterKeyMapping('tggtv', Config.CommandDescription, 'keyboard', Config.Keybind)
    else
        print('Please provide a command description and keybind in the config.lua file.')
    end
else
    if Config.Framework == 'Standalone' then
        print('Please disable Config.UsableItem in the config.lua file if you are using the Standalone framework.')
    end
end

-- ^^^^^^^^^^^^^^^^--
-- FUNCTIONS START --
---------------------

local function LoadAnimation(dict)
    RequestAnimDict(dict)

    while not HasAnimDictLoaded(dict) do
        Wait(1)
    end
end

local function DeleteRemoteControlProp()
    if remoteControlProp ~= 0 then
        DeleteObject(remoteControlProp)
        remoteControlProp = 0
    end
end

local function CheckAnimLoop()
    CreateThread(function()
        while remoteControlAnimLib ~= nil and remoteControlAnim ~= nil do
            local ped = PlayerPedId()

            if not IsEntityPlayingAnim(ped, remoteControlAnimLib, remoteControlAnim, 3) then
                LoadAnimation(remoteControlAnimLib)
                TaskPlayAnim(ped, remoteControlAnimLib, remoteControlAnim, 3.0, 3.0, -1, 50, 0, false, false, false)
            end

            Wait(500)
        end
    end)
end

local function DoRemoteControlAnimation(anim)
    local ped = PlayerPedId()
    local AnimationLib = 'cellphone@'
    local AnimationStatus = anim

    LoadAnimation(AnimationLib)

    TaskPlayAnim(ped, AnimationLib, AnimationStatus, 3.0, 3.0, -1, 50, 0, false, false, false)

    remoteControlAnimLib = AnimationLib
    remoteControlAnim = AnimationStatus

    CheckAnimLoop()
end

local function NewremoteControlProp()
    local player = PlayerPedId()

    DeleteRemoteControlProp()

    local hash = GetHashKey(remotecontrolModel)

    remoteControlProp = CreateObject(hash, GetEntityCoords(player), true, true, false)

    DoRemoteControlAnimation("cellphone_text_in")

    AttachEntityToEntity(remoteControlProp, player, GetPedBoneIndex(player, 57005), 0.16, 0.02, -0.01, -170.0, -21.0,
        109.0, true, true, false, false, 1, true)
end

local function DoRemoteControlAnim()
    TriggerEvent('tgg-remotetv:animation-sync')
end

local function GetCurrentlyWorkingTVLocal(coords)
    if CurrentlyWorkingTVsLocal then
        for k, v in pairs(CurrentlyWorkingTVsLocal) do
            if #(v3(v.coords) - v3(coords)) < 0.01 then
                return k, v
            end
        end
    end
end

local function EnableRemoteControl(enable)
    if CURRENT_SCREEN and #(GetEntityCoords(PlayerPedId()) - CURRENT_SCREEN.coords) <= Config.DistanceToTv then
        if enable then
            if Config.RemoteControlInHand then
                DoRemoteControlAnim()
            end

            SetNuiFocus(true, true)

            RemoteControlOpen = true

            -- Check if the TV is already working
            local index, data = GetCurrentlyWorkingTVLocal(CURRENT_SCREEN.coords)
            if index and data then
                isCurrentScreenOn = true
                currentApp = data.currentApp and data.currentApp or 'home'
            else
                currentApp = 'home'
                isCurrentScreenOn = false
            end

            SendNUIMessage({
                type = "open",
                isOn = isCurrentScreenOn,
                currentApp = currentApp
            })
        else
            SetNuiFocus(false, false)

            RemoteControlOpen = false

            if Config.RemoteControlInHand then
                DoRemoteControlAnimation('cellphone_text_out')

                SetTimeout(500, function()
                    StopAnimTask(PlayerPedId(), remoteControlAnimLib, remoteControlAnim, 2.5)

                    DeleteRemoteControlProp()

                    remoteControlAnim = nil
                    remoteControlAnimLib = nil
                end)
            end
        end
    else
        print('You are not near a TV.')
    end
end

local function CreateNamedRenderTargetForModel(name, model)
    local handle = 0

    if not IsNamedRendertargetRegistered(name) then
        RegisterNamedRendertarget(name, 0)
    end

    if not IsNamedRendertargetLinked(model) then
        LinkNamedRendertarget(model)
    end

    if IsNamedRendertargetRegistered(name) then
        handle = GetNamedRendertargetRenderId(name)
    end

    return handle
end

local function LoadModel(model)
    if not IsModelInCdimage(model) then
        return
    end

    RequestModel(model)

    while not HasModelLoaded(model) do
        Wait(0)
    end

    return model
end

local function RenderScaleformTV(renderTarget, scaleform, entity)
    SetTextRenderId(renderTarget)

    Set_2dLayer(4)

    SetScriptGfxDrawBehindPausemenu(1)

    DrawSprite("remotetv_b_dict", "remotetv_b_txd", 0.5, 0.5, 1.0, 1.0, 0.0, 255, 255, 255, 255)

    SetTextRenderId(GetDefaultScriptRendertargetRenderId())

    SetScriptGfxDrawBehindPausemenu(0)
end

local function getDuiURL()
    return duiUrl
end

local function setDuiURL(url)
    duiUrl = url

    SetDuiUrl(duiObj, duiUrl)
end

local function GetTelevisionLocal(coords)
    for k, v in pairs(TelevisionsLocal) do
        if #(v3(v.coords) - v3(coords)) < 0.01 then
            return k, v
        end
    end
end

local function SetTelevisionLocal(coords, key, value)
    local index, data = GetTelevisionLocal(coords)

    if (index ~= nil) then
        if (TelevisionsLocal[index] == nil) then
            TelevisionsLocal[index] = {}
        end

        TelevisionsLocal[index][key] = value
    else
        index = GetGameTimer()

        while TelevisionsLocal[index] do
            index = index + 1
            Citizen.Wait(0)
        end

        if (TelevisionsLocal[index] == nil) then
            TelevisionsLocal[index] = {}
        end

        TelevisionsLocal[index][key] = value
    end

    TelevisionsLocal[index].coords = coords

    return index
end

local function RemoveTelevisionLocal(coords)
    local index, data = GetTelevisionLocal(coords)

    if (index ~= nil) then
        TelevisionsLocal[index] = nil
    end
end

local function ResetDisplay()
    setDuiURL(DEFAULT_TV_URL)
end

local function SetVolume(coords, num)
    local index, data = GetTelevisionLocal(coords)

    if (index ~= nil) then
        TriggerServerEvent("tgg-remotetv:event", TelevisionsLocal[index], "volume", num)
    end
end

local function GetVolume(dist, range)
    if not volume then
        return 0
    end

    local rem = (dist / range)

    rem = rem > volume and volume or rem

    local _vol = math.floor((volume - rem) * 100)

    return _vol
end

local function loadScaleform(scaleform)
    local scaleformHandle = RequestScaleformMovie(scaleform)

    while not HasScaleformMovieLoaded(scaleformHandle) do
        scaleformHandle = RequestScaleformMovie(scaleform)
        Citizen.Wait(0)
    end

    return scaleformHandle
end

local function ShowScreen(data)
    CURRENT_SCREEN = data

    local k, currentTvLocal = GetCurrentlyWorkingTVLocal(data.coords)
    if not currentTvLocal then
        return
    end

    sfHandle = loadScaleform(sfName)

    local txd = CreateRuntimeTxd('remotetv_b_dict')

    duiObj = CreateDui(duiUrl, width, height)

    local dui = GetDuiHandle(duiObj)
    local tx = CreateRuntimeTextureFromDuiHandle(txd, 'remotetv_b_txd', dui)

    Citizen.Wait(10)

    PushScaleformMovieFunction(sfHandle, 'SET_TEXTURE')

    PushScaleformMovieMethodParameterString('remotetv_b_dict')
    PushScaleformMovieMethodParameterString('remotetv_b_txd')

    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(width)
    PushScaleformMovieFunctionParameterInt(height)

    PopScaleformMovieFunctionVoid()

    Citizen.CreateThread(function()
        TriggerServerEvent("tgg-remotetv:requestSync", data.coords)

        local tvObj = data.entity
        local screenModel = Config.Models[data.model]

        local scale = screenModel.Scale
        local offset = GetOffsetFromEntityInWorldCoords(tvObj, screenModel.Offset.x, screenModel.Offset.y,
            screenModel.Offset.z)

        while duiObj do
            if (tvObj and sfHandle ~= nil and HasScaleformMovieLoaded(sfHandle)) then
                if (screenModel.Target) then
                    local id = CreateNamedRenderTargetForModel(screenModel.Target, data.model)

                    if (id ~= -1) then
                        RenderScaleformTV(id, sfHandle, tvObj)
                    end
                else
                    local hz = GetEntityHeading(tvObj)

                    DrawScaleformMovie_3dSolid(sfHandle, offset, 0.0, 0.0, -hz, 2.0, 2.0, 2.0, scale * 1,
                        scale * (9 / 16), 2)
                end
            end

            Citizen.Wait(0)
        end
    end)

    Citizen.CreateThread(function()
        local screen = CURRENT_SCREEN
        local modelData = Config.Models[screen.model]
        local coords = screen.coords
        local range = modelData.Range

        if (currentTvLocal and currentTvLocal.volume) then
            SetVolume(coords, currentTvLocal.volume)
        else
            SetVolume(coords, modelData.DefaultVolume)
        end

        while duiObj do
            local pcoords = GetEntityCoords(PlayerPedId())
            local dist = #(coords - pcoords)

            SendDuiMessage(duiObj, json.encode({
                setVolume = true,
                data = GetVolume(dist, range)
            }))

            Citizen.Wait(300)
        end
    end)
end

local function HideScreen()
    CURRENT_SCREEN = nil

    if (duiObj) then
        DestroyDui(duiObj)
        SetScaleformMovieAsNoLongerNeeded(sfHandle)
        duiObj = nil
        sfHandle = nil
    end
end

local function GetClosestScreen()
    local objPool = GetGamePool('CObject')
    local closest = {
        dist = -1
    }

    local pcoords = GetEntityCoords(PlayerPedId())

    for i = 1, #objPool do
        local entity = objPool[i]
        local model = GetEntityModel(entity)
        local data = Config.Models[model]

        if (data) then
            local coords = GetEntityCoords(entity)
            local dist = #(pcoords - coords)

            if (dist < closest.dist or closest.dist < 0) and dist < data.Range then
                closest = {
                    dist = dist,
                    coords = coords,
                    model = model,
                    entity = entity
                }
            end
        end
    end

    return (closest.entity and closest or nil)
end

local function PlayVideo(data)
    if not duiObj then
        return
    end

    while not IsDuiAvailable(duiObj) do
        Wait(10)
    end

    if (getDuiURL() ~= DEFAULT_TV_URL) then
        waitForLoad = true

        setDuiURL(DEFAULT_TV_URL)

        while waitForLoad do
            Wait(10)
        end
    end

    SendDuiMessage(duiObj, json.encode({
        setVideo = true,
        data = data
    }))

    table.insert(lastPlayedVideos, data.url)
end

local function SetChannel(index)
    TriggerServerEvent("tgg-remotetv:event", CURRENT_SCREEN, "ptv_status", {
        type = "play",
        channel = index
    })
end

local function GetChannelList()
    if not Channels then
        return {}
    end

    local channel_list = {}
    local current = 1
    local screen = CURRENT_SCREEN

    local _, status = GetTelevision(screen.coords)
    local channel = nil

    if (status) then
        channel = status.channel
    end

    for index, value in pairs(Channels) do
        table.insert(channel_list, {
            index = index,
            url = value.url
        })

        if channel ~= nil and channel == index then
            current = #channel_list
        end
    end

    local data = {
        channelList = channel_list,
        current = current
    }

    return data
end

local function PlayBrowser(data)
    while not IsDuiAvailable(duiObj) do
        Wait(10)
    end

    setDuiURL(data.url)
end

local function RequestTextureDictionary(dict)
    RequestStreamedTextureDict(dict)

    while not HasStreamedTextureDictLoaded(dict) do
        Wait(0)
    end

    return dict
end

local scale = 1.5
local screenWidth = math.floor(1920 / scale)
local screenHeight = math.floor(1080 / scale)

local shouldDraw = false

local function SetInteractScreen(bool)
    if (not shouldDraw and bool) then
        shouldDraw = bool

        Citizen.CreateThread(function()
            -- Create screen
            local nX = 0
            local nY = 0

            local w, h = screenWidth, screenHeight

            local minX, maxX = ((w - (w / 2)) / 2), (w - (w / 4))
            local totalX = minX - maxX

            local minY, maxY = ((h - (h / 2)) / 2), (h - (h / 4))
            local totalY = minY - maxY

            RequestTextureDictionary('fib_pc')

            -- Update controls while active
            while shouldDraw do
                nX = GetControlNormal(0, 239) * screenWidth
                nY = GetControlNormal(0, 240) * screenHeight
                DisableControlAction(0, 1, true)         -- Disable looking horizontally
                DisableControlAction(0, 2, true)         -- Disable looking vertically
                DisablePlayerFiring(PlayerPedId(), true) -- Disable weapon firing
                DisableControlAction(0, 142, true)       -- Disable aiming
                DisableControlAction(0, 106, true)       -- Disable in-game mouse controls

                -- Update mouse position when changed
                DrawSprite("remotetv_b_dict", "remotetv_b_txd", 0.5, 0.5, 0.5, 0.5, 0.0, 255, 255, 255, 255)

                if nX ~= mX or nY ~= mY then
                    mX = nX;
                    mY = nY

                    local duiX = -screenWidth * ((mX - minX) / totalX)
                    local duiY = -screenHeight * ((mY - minY) / totalY)

                    BlockWeaponWheelThisFrame()

                    if not (mX > 325) then
                        mX = 325
                    end

                    if not (mX < 965) then
                        mX = 965
                    end

                    if not (mY > 185) then
                        mY = 185
                    end

                    if not (mY < 545) then
                        mY = 545
                    end

                    SendDuiMouseMove(duiObj, math.floor(duiX), math.floor(duiY))
                end

                DrawSprite('fib_pc', 'arrow', mX / screenWidth, mY / screenHeight, 0.005, 0.01, 0.0, 255, 255, 255, 255)

                -- Send scroll and click events to dui
                if IsControlPressed(0, 177) then
                    SetInteractScreen(false)
                end -- scroll up

                if IsControlPressed(0, 172) then
                    SendDuiMouseWheel(duiObj, 10, 0)
                end -- scroll up

                if IsControlPressed(0, 173) then
                    SendDuiMouseWheel(duiObj, -10, 0)
                end -- scroll down

                if IsDisabledControlJustPressed(0, 24) then
                    SendDuiMouseDown(duiObj, 'left')
                elseif IsDisabledControlJustReleased(0, 24) then
                    SendDuiMouseUp(duiObj, 'left')
                end

                if IsDisabledControlJustPressed(0, 25) then
                    SendDuiMouseDown(duiObj, "right")
                elseif IsDisabledControlJustReleased(0, 24) then
                    SendDuiMouseUp(duiObj, "right")
                end

                Wait(0)
            end
        end)
    else
        shouldDraw = bool
    end
end

local function TogglePlayVideo()
    if not duiObj then
        return
    end

    local index = GetTelevisionLocal(CURRENT_SCREEN.coords)

    if (index ~= nil) then
        isVideoPaused = not isVideoPaused

        TriggerServerEvent("tgg-remotetv:event", TelevisionsLocal[index], "paused", isVideoPaused)
    end
end

-------------------
-- FUNCTIONS END --
-- **************--

-- ^^^^^^^^^^^^^^--
-- THREADS START --
-------------------

CreateThread(function()
    if not playerLoaded then
        playerLoaded = true

        TriggerServerEvent("tgg-remotetv:request-sync-currently-working-tvs")
    end
end)

Citizen.CreateThread(function()
    Citizen.Wait(3000)

    TriggerServerEvent("tgg-remotetv:requestUpdate")

    while true do
        local wait = 2500
        local data = GetClosestScreen()

        if (data and not duiObj) then
            ShowScreen(data)
        elseif ((not data or #(v3(CURRENT_SCREEN.coords) - v3(data.coords)) > 0.01) and duiObj) then
            HideScreen()
        end

        Citizen.Wait(wait)
    end
end)

-- This will iterate through all the locations and create custom TV objects
Citizen.CreateThread(function()
    if not next(Locations) then
        return
    end

    while true do
        local wait = 2500

        for i = 1, #Locations do
            local data = Locations[i]
            local dist = #(GetEntityCoords(PlayerPedId()) - v3(data.Position))

            if not Locations[i].obj and dist < 20.0 then
                LoadModel(data.Model)
                Locations[i].obj = CreateObject(data.Model, data.Position.x, data.Position.y, data.Position.z)
                SetEntityHeading(Locations[i].obj, data.Position.w)
                FreezeEntityPosition(Locations[i].obj, true)
            elseif Locations[i].obj and dist > 20.0 then
                DeleteEntity(Locations[i].obj)
                Locations[i].obj = nil
            end
        end

        Citizen.Wait(wait)
    end
end)

-----------------
-- THREADS END --
-- ************--

-- ^^^^^^^^^^^^^^^--
-- COMMANDS START --
--------------------

if not Config.UsableItem and Config.Framework == 'Standalone' then
    RegisterCommand('tggtv', function()
        if not RemoteControlOpen then
            EnableRemoteControl(true)
        else
            EnableRemoteControl(false)
        end
    end, false)
end

------------------
-- COMMANDS END --
-- *************--

-- ^^^^^^^^^^^^^^^^^^^^--
-- NUI CALLBACKS START --
-------------------------

RegisterNUICallback('browser-control', function(_, cb)
    SetInteractScreen(true)

    EnableRemoteControl(false)

    cb({})
end)

local currentChannel = 1

RegisterNUICallback('channel-up', function(_, cb)
    local data = GetChannelList()

    local _current = currentChannel

    local nextChannel = (_current + 1) > #data.channelList and 1 or (_current + 1)

    currentChannel = nextChannel

    SetChannel(nextChannel)

    local channelData
    for i, v in pairs(data.channelList) do
        if (v.index == nextChannel) then
            channelData = v
            break
        end
    end

    local provider = string.find(channelData.url, 'youtube') and 'youtube' or 'twitch'
    local channelName = string.match(channelData.url, '/(.*)')

    SendDuiMessage(duiObj, json.encode({
        channelData = {
            provider = provider,
            channelNumber = nextChannel,
            channelName = provider == 'youtube' and '' or channelName
        }
    }))

    cb(nextChannel)
end)

RegisterNUICallback('channel-down', function(_, cb)
    local data = GetChannelList()

    local _current = currentChannel

    local nextChannel = (_current - 1) < 1 and #data.channelList or (_current - 1)

    currentChannel = nextChannel

    SetChannel(nextChannel)

    local channelData
    for i, v in pairs(data.channelList) do
        if (v.index == nextChannel) then
            channelData = v
            break
        end
    end

    local provider = string.find(channelData.url, 'youtube') and 'youtube' or 'twitch'
    local channelName = string.match(channelData.url, '/(.*)')

    SendDuiMessage(duiObj, json.encode({
        channelData = {
            provider = provider,
            channelNumber = nextChannel,
            channelName = provider == 'youtube' and '' or channelName
        }
    }))

    cb(nextChannel)
end)

RegisterNUICallback("page-loaded", function(_, cb)
    waitForLoad = false

    cb({})
end)

RegisterNUICallback('power-btn', function(_, cb)
    TriggerServerEvent("tgg-remotetv:update-currently-working-tvs", CURRENT_SCREEN)

    cb({})
end)

RegisterNUICallback('api-play-video', function(data, cb)
    TriggerServerEvent("tgg-remotetv:event", CURRENT_SCREEN, "ptv_status", {
        type = "play",
        url = data.url
    })

    TriggerServerEvent('tgg-remotetv:update-currently-working-tv-app', CURRENT_SCREEN.coords, data.type)

    cb(data.type)
end)

RegisterNUICallback('api-play-tv', function(_, cb)
    currentApp = 'tv'

    SendDuiMessage(duiObj, json.encode({
        setTv = true
    }))

    SetChannel(1)

    TriggerServerEvent('tgg-remotetv:update-currently-working-tv-app', CURRENT_SCREEN.coords, currentApp)

    cb(currentApp)
end)

RegisterNUICallback('volume-up', function(_, cb)
    local coords = CURRENT_SCREEN.coords
    local newVolume = tonumber(volume) + 0.05

    if newVolume <= 1.01 then
        SetVolume(coords, newVolume)
        cb(newVolume)
    else
        cb(volume)
    end
end)

RegisterNUICallback('volume-down', function(_, cb)
    local coords = CURRENT_SCREEN.coords
    local newVolume = tonumber(volume) - 0.05

    if newVolume >= 0 then
        SetVolume(coords, newVolume)
        cb(newVolume)
    else
        cb(volume)
    end
end)

RegisterNUICallback('close-remote', function(data, cb)
    SetNuiFocus(false, false)

    RemoteControlOpen = false

    if Config.RemoteControlInHand then
        DoRemoteControlAnimation('cellphone_text_out')

        SetTimeout(500, function()
            StopAnimTask(PlayerPedId(), remoteControlAnimLib, remoteControlAnim, 2.5)

            DeleteRemoteControlProp()

            remoteControlAnim = nil
            remoteControlAnimLib = nil
        end)
    end

    cb({})
end)

RegisterNUICallback('home', function(_, cb)
    currentApp = 'home'

    TriggerServerEvent("tgg-remotetv:event", CURRENT_SCREEN, "ptv_status", {
        type = "browser",
        url = DEFAULT_TV_URL
    })

    TriggerServerEvent('tgg-remotetv:update-currently-working-tv-app', CURRENT_SCREEN.coords, currentApp)

    cb(currentApp)
end)

RegisterNUICallback('back', function(_, cb)
    local lastPlayedVideo = nil

    if #lastPlayedVideos - 1 then
        lastPlayedVideo = lastPlayedVideos[#lastPlayedVideos - 1]
    elseif #lastPlayedVideos then
        lastPlayedVideo = lastPlayedVideos[#lastPlayedVideos]
    else
        lastPlayedVideo = DEFAULT_TV_URL
    end

    if lastPlayedVideo then
        TriggerServerEvent("tgg-remotetv:event", CURRENT_SCREEN, "ptv_status", {
            type = "play",
            url = lastPlayedVideo
        })

        -- find if last played video was a youtube video
        local provider = string.find(lastPlayedVideo, 'youtube') and 'youtube' or 'twitch'

        TriggerServerEvent('tgg-remotetv:update-currently-working-tv-app', CURRENT_SCREEN.coords, provider)

        cb(provider)
    else
        cb(nil)
    end
end)

RegisterNUICallback('play', function(_, cb)
    TogglePlayVideo()

    cb({})
end)

RegisterNUICallback('browser', function(data, cb)
    currentApp = 'browser'

    TriggerServerEvent("tgg-remotetv:event", CURRENT_SCREEN, "ptv_status", {
        type = "browser",
        url = data.url
    })

    TriggerServerEvent('tgg-remotetv:update-currently-working-tv-app', CURRENT_SCREEN.coords, currentApp)

    cb(currentApp)
end)

RegisterNUICallback('open-youtube', function(_, cb)
    SendDuiMessage(duiObj, json.encode({
        setYoutube = true
    }))

    cb({})
end)

RegisterNUICallback('open-twitch', function(_, cb)
    SendDuiMessage(duiObj, json.encode({
        setTwitch = true
    }))

    cb({})
end)

RegisterNUICallback('open-browser', function(data, cb)
    SendDuiMessage(duiObj, json.encode({
        setBrowser = true
    }))

    cb({})
end)

-----------------------
-- NUI CALLBACKS END --
-- ******************--

-- ^^^^^^^^^^^^^^^^^--
-- NET EVENTS START --
----------------------

RegisterNetEvent('tgg-remotetv:animation-sync', NewremoteControlProp)

RegisterNetEvent("tgg-remotetv:event", function(data, index, key, value)
    Televisions = data

    local data = Televisions[index]
    local screen = CURRENT_SCREEN

    if (screen and #(v3(screen.coords) - v3(data.coords)) < 0.001) then
        if key == "volume" then
            volume = value

            SetTelevisionLocal(Televisions[index].coords, key, value)

            TriggerServerEvent("tgg-remotetv:update-currently-working-tv-volume", CURRENT_SCREEN.coords, value)

            return
        end

        if key == "paused" then
            SetTelevisionLocal(Televisions[index].coords, key, value)

            if duiObj == nil then
                return
            end

            SendDuiMessage(duiObj, json.encode({
                pauseVideo = true,
                data = value
            }))

            return
        end

        local index, data = GetTelevision(screen.coords)

        if (index) then
            local event = value

            if (event.type == "play") then
                local data = {
                    url = event.url,
                    paused = data.paused or false
                }

                if (event.channel) then
                    data = Channels[event.channel]

                    data.channel = event.channel
                end

                PlayVideo(data)
            elseif (event.type == "browser") then
                PlayBrowser({
                    url = event.url
                })
            end
        end
    end

    SetTelevisionLocal(Televisions[index].coords, "start_time", GetGameTimer())
end)

RegisterNetEvent("tgg-remotetv:broadcast", function(data, index)
    Channels = data

    if getDuiURL() == DEFAULT_URL then
        local screen = CURRENT_SCREEN
        local _, status = GetTelevision(screen.coords)

        if (status and status.channel == index and data[index] == nil) then
            ResetDisplay()

            Citizen.Wait(10)
        end

        SendDuiMessage(duiObj, json.encode({
            showNotification = true,
            channel = index,
            data = data[index]
        }))
    end
end)

RegisterNetEvent("tgg-remotetv:requestUpdate", function(data)
    Televisions = data.Televisions
    Channels = data.Channels
end)

RegisterNetEvent("tgg-remotetv:requestSync", function(coords, data)
    local _, status = GetTelevision(coords)

    if status and status["ptv_status"] then
        local update_time = status.update_time
        local paused = status.paused or false
        local status = status["ptv_status"]

        Citizen.Wait(1000)

        if status.type == "play" then
            if (status.channel and Channels[status.channel]) then
                PlayVideo({
                    url = Channels[status.channel].url,
                    channel = status.channel
                })
            elseif (status.url) then
                local time = math.floor(data.current_time - update_time)
                PlayVideo({
                    url = status.url,
                    time = time,
                    paused = paused
                })
            end
        elseif (status.type == "browser") then
            PlayBrowser({
                url = status.url
            })
        end
    end
end)

RegisterNetEvent('tgg-remotetv:use', function()
    EnableRemoteControl(true)
end)

RegisterNetEvent("tgg-remotetv:sync-currently-working-tvs", function(data)
    CurrentlyWorkingTVsLocal = data
end)

RegisterNetEvent("tgg-remotetv:remove-current-tv", function()
    RemoveTelevisionLocal(CURRENT_SCREEN.coords)

    RemoveTelevision(CURRENT_SCREEN.coords)

    isCurrentScreenOn = false

    ResetDisplay()

    HideScreen()
end)

--------------------
-- NET EVENTS END --
-- ****************--

AddEventHandler('onResourceStop', function(name)
    if name == GetCurrentResourceName() then
        HideScreen()

        for i = 1, #Locations do
            DeleteEntity(Locations[i].obj)
        end
    end
end)
