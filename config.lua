Config = {}

-- A framework is required when you want to use the remote control as usable item in your inventory.
-- Otherwise you can use the resource as standalone.
-- Config.Framework = 'QB'
-- Config.Framework = 'ESX'

-- If you want to use the resource as standalone you must keep `Config.UsableItem` to *false* and follow the instructions below.
Config.Framework = 'Standalone'

-- In case you have different framework core name you can put it here.
Config.FrameworkCore = 'qb-core' -- es_extended

-- **IMPORTANT** -- If you want to use the item as usable you need to provide `Config.Framework` = 'ESX' or 'QB'
-- If the usable item is false you need to provide the (`Config.CommandDescription`, `Config.Keybind`) to open the TV menu.
-- If the usable item is true the `Keybind` won't work and you must have an item in your inventory with the name 'remotecontrol' to open the TV menu.
-- And the `Config.Framework` should be 'ESX' or 'QB'.
Config.UsableItem = false

Config.CommandDescription = 'Open the remote control menu.' -- The command description.
Config.Keybind = 'F2'                                       -- The keybind to open the TV menu.

Config.DistanceToTv = 10.0                                  -- How far you can be from the TV to interact with it(suggested default is - 10.0).

-- If you want to use the remote control prop animation in hand.
-- Make sure that you have started the resource with the remote control prop(tgg-remotecontrol-prop) otherwise it will not work.
Config.RemoteControlInHand = true

-- These channels are available when you click the `TV` button on the remote.
-- You can add more channels by following the example below.
-- YouTube - 'youtube.com/watch?v={videoId}'
-- Twitch - 'twitch.tv/{channelName}'
Config.Channels = {
    { name = "UPROXXMusic", url = "youtube.com/watch?v=05689ErDUdM" },
    { name = "NATGEO",      url = "youtube.com/watch?v=6zGV59Ldp3s" },
    { name = "esl_csgo",    url = "twitch.tv/esl_csgo" },
}

Config.CheckForUpdates = true -- If you want to check for updates on start up set this to true.

-- These are the models of the TVs that the remote will be available.
-- You can add more TVs by following the example below.
Config.Models = {
    [`des_tvsmash_start`] = {
        DefaultVolume = 0.5,
        Range = 20.0,
        Target = "tvscreen",
        Scale = 0.085,
        Offset = vector3(-1.02, -0.055, 1.04)
    },
    [`prop_flatscreen_overlay`] = {
        DefaultVolume = 0.5,
        Range = 20.0,
        Target = "tvscreen",
        Scale = 0.085,
        Offset = vector3(-1.02, -0.055, 1.04)
    },
    [`prop_laptop_lester2`] = {
        DefaultVolume = 0.5,
        Range = 20.0,
        Target = "tvscreen",
        Scale = 0.085,
        Offset = vector3(-1.02, -0.055, 1.04)
    },
    [`prop_monitor_02`] = {
        DefaultVolume = 0.5,
        Range = 20.0,
        Target = "tvscreen",
        Scale = 0.085,
        Offset = vector3(-1.02, -0.055, 1.04)
    },
    [`prop_trev_tv_01`] = {
        DefaultVolume = 0.5,
        Range = 20.0,
        Target = "tvscreen",
        Scale = 0.085,
        Offset = vector3(-1.02, -0.055, 1.04)
    },
    [`prop_tv_02`] = {
        DefaultVolume = 0.5,
        Range = 20.0,
        Target = "tvscreen",
        Scale = 0.085,
        Offset = vector3(-1.02, -0.055, 1.04)
    },
    [`prop_tv_03_overlay`] = {
        DefaultVolume = 0.5,
        Range = 20.0,
        Target = "tvscreen",
        Scale = 0.085,
        Offset = vector3(-1.02, -0.055, 1.04)
    },
    [`prop_tv_06`] = {
        DefaultVolume = 0.5,
        Range = 20.0,
        Target = "tvscreen",
        Scale = 0.085,
        Offset = vector3(-1.02, -0.055, 1.04)
    },
    [`prop_tv_flat_01`] = {
        DefaultVolume = 0.5,
        Range = 20.0,
        Target = "tvscreen",
        Scale = 0.085,
        Offset = vector3(-1.02, -0.055, 1.04)
    },
    [`prop_tv_flat_01_screen`] = {
        DefaultVolume = 0.5,
        Range = 20.0,
        Target = "tvscreen",
        Scale = 0.085,
        Offset = vector3(-1.02, -0.055, 1.04)
    },
    [`prop_tv_flat_02b`] = {
        DefaultVolume = 0.5,
        Range = 20.0,
        Target = "tvscreen",
        Scale = 0.085,
        Offset = vector3(-1.02, -0.055, 1.04)
    },
    [`prop_tv_flat_03`] = {
        DefaultVolume = 0.5,
        Range = 20.0,
        Target = "tvscreen",
        Scale = 0.085,
        Offset = vector3(-1.02, -0.055, 1.04)
    },
    [`prop_tv_flat_03b`] = {
        DefaultVolume = 0.5,
        Range = 20.0,
        Target = "tvscreen",
        Scale = 0.085,
        Offset = vector3(-1.02, -0.055, 1.04)
    },
    [`prop_tv_flat_michael`] = {
        DefaultVolume = 0.5,
        Range = 20.0,
        Target = "tvscreen",
        Scale = 0.085,
        Offset = vector3(-1.02, -0.055, 1.04)
    },
    [`prop_monitor_w_large`] = {
        DefaultVolume = 0.5,
        Range = 20.0,
        Target = "tvscreen",
        Scale = 0.085,
        Offset = vector3(-1.02, -0.055, 1.04)
    },
    [`prop_tv_03`] = {
        DefaultVolume = 0.5,
        Range = 20.0,
        Target = "tvscreen",
        Scale = 0.085,
        Offset = vector3(-1.02, -0.055, 1.04)
    },
    [`prop_tv_flat_02`] = {
        DefaultVolume = 0.5,
        Range = 20.0,
        Target = "tvscreen",
        Scale = 0.085,
        Offset = vector3(-1.02, -0.055, 1.04)
    },
    [`vw_prop_vw_cinema_tv_01`] = {
        DefaultVolume = 0.5,
        Range = 20.0,
        Target = "tvscreen",
        Scale = 0.085,
        Offset = vector3(-1.02, -0.055, 1.04)
    },
}

-- If you want to add a TV on custom location just add new obj with the prop name(should be one of the models above, you can add custom as well) and coords(vector4 format)
Config.Locations = {
    -- { -- Michael's house garage
    --     Model = `prop_tv_flat_michael`,
    --     Position = vector4(-809.10, 185.25, 72.50, 200),
    -- }
}
