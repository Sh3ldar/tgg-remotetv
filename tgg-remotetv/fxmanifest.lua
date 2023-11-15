fx_version "cerulean"

game "gta5"

author "TeamsGG Development"

version "3.0.3"

ui_page "html/remote.html"

files {
    "html/remote.html",
    "html/index.html",
    "html/styles/remote.css",
    "html/styles/tv.css",
    "html/scripts/remote.js",
    "html/scripts/tv.js",
    'html/img/remotecontrol.png',
    'html/img/remotecontrol-holo.png',
    'html/img/yt-logo.png',
    'html/img/browser-logo.png',
    'html/img/twitch-logo.png',
    'html/img/tv-logo.png',
    -- TV Home page backgrounds.
    'html/img/bg/bg1.png',
    'html/img/bg/bg2.png',
    'html/img/bg/bg3.png',
    'html/img/bg/bg4.png',
    'html/img/bg/bg5.png',
    -- TV Home page backgrounds.
    'html/img/volume-mute.png',
    'html/img/volume-up.png',
    'html/img/twitch.png',
    'html/img/youtube.png',
    'html/img/browser.png',
    'html/img/channels.png',
    'html/img/RobotoMonoBold.ttf',
}

shared_scripts {
    "config.lua",
    "shared/*.lua"
}

client_scripts {
    "client/*.lua",
}

server_scripts {
    "server/frameworks/*.lua",
    "server/*.lua"
}

escrow_ignore {
    'config.lua'
}

lua54 'yes'

dependency "generic_texture_renderer_gfx"