const resourceName = window.GetParentResourceName ? window.GetParentResourceName() : 'nui-frame-app';

const apps = ['youtube', 'twitch', 'browser', 'tv', 'home'];
let currentApp = 'home';

let channelTimeout = null;
let player;
let playerData;

$(document).ready(function () {
    $.post(`https://${resourceName}/page-loaded`, JSON.stringify({}));
});

function GetUrlId(link) {
    if (link == null) return;

    const url = link.toString();
    const regExp = /^.*(youtu\.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/;
    const match = url.match(regExp);

    if (match && match[2].length == 11) {
        return { type: "youtube", id: match[2] };
    } else if (match && url.includes('twitch')) {
        if (match[2]?.includes("videos")) {
            const videoId = match[2].split('videos/')[1]
            return { type: "twitch", id: videoId, videoType: 'video' };
        } else if (url.split('twitch.tv/').length > 1) return { type: "twitch", id: url.split('twitch.tv/')[1], videoType: 'stream' };
    }
}

function PlayTwitchVideo(data) {
    const options = {
        width: "100%",
        height: "100%",
        volume: 1.0,
        layout: "video",
        theme: 'dark'
    };

    if (data.videoType == 'stream') options.channel = data.id;
    else if (data.videoType == 'video') options.video = data.id;

    player = new Twitch.Embed("video-embed", options);

    player.addEventListener(Twitch.Embed.VIDEO_READY, function () {
        player.setMuted(false);
    });
}

function PlayYoutubeVideo(video_data, data, paused) {
    player = new YT.Player('video-embed', {
        height: '100%',
        width: '100%',
        videoId: data.id,
        playerVars: {
            'playsinline': 1,
        },
        events: {
            'onReady': function (event) {
                event.target.seekTo(video_data.time)

                if (paused) event.target.pauseVideo()
                else {
                    event.target.playVideo();
                }
            },
            'onStateChange': function (event) {
                if (event.data == YT.PlayerState.PLAYING) event.target.unMute();
            }
        }
    });
}

function SetVideo(video_data) {
    const url = video_data.url;
    const paused = video_data.paused;

    const data = GetUrlId(url)

    playerData = data

    if (player) {
        player.destroy()
        player = null;
    }

    if (data) {
        if (data.type == "youtube") {
            PlayYoutubeVideo(video_data, data, paused)
        } else if (data.type == "twitch") {
            PlayTwitchVideo(data)
        }

        $("#tv-container").hide()
    }
}

function SetVolume(volume) {
    if (player && playerData && player.setVolume) {
        if (playerData.type == "youtube") {
            player.unMute();
            player.setVolume(volume);
        } else if (playerData.type == "twitch") {
            player.setMuted(false);
            player.setVolume(volume / 100.0);
        }
    }
}

function PauseVideo(state) {
    if (player && playerData) {
        if (playerData.type == "youtube") {
            if (state) {
                player.pauseVideo()
            } else {
                player.playVideo()
            }
        }
    }
}

function ShowApp(show) {
    apps.forEach(app => {
        if (app === show) $(`#${show}-screen`).css('display', 'flex');
        else $(`#${app}-screen`).hide();
    })
}

function UpdateChannel(data) {
    if (channelTimeout) clearTimeout(channelTimeout);

    $('#channel-number').text(data.channelNumber);

    if (data.provider == 'youtube') {
        $('#channel-name').text('');
        $('#provider-yt').show();
        $('#provider-tw').hide();
    } else {
        $('#channel-name').text(data.channelName);
        $('#provider-tw').show();
        $('#provider-yt').hide();
    }

    $('#channel-info-container').css('top', '0');

    channelTimeout = setTimeout(function () {
        $('#channel-info-container').css('top', '-110px')
    }, 3000);
}

window.addEventListener("message", function (event) {
    if (event.data.setVideo) {
        SetVideo(event.data.data)
    } else if (event.data.setVolume) {
        SetVolume(event.data.data)
    } else if (event.data.pauseVideo) {
        PauseVideo(event.data.data)
    } else if (event.data.setYoutube) {
        currentApp = 'youtube'

        ShowApp(currentApp)
    } else if (event.data.setTwitch) {
        currentApp = 'twitch'

        ShowApp(currentApp)
    } else if (event.data.setBrowser) {
        currentApp = 'browser'

        ShowApp(currentApp)
    } else if (event.data.setTv) {
        currentApp = 'tv'

        ShowApp(currentApp)
    } else if (event.data.channelData) {
        UpdateChannel(event.data.channelData)
    }
});

$(document).ready(function () {
    clockUpdate();
    setInterval(clockUpdate, 20000);
})

function clockUpdate() {
    const date = new Date();

    function addZero(x) {
        if (x < 10) {
            return '0' + x;
        } else {
            return x;
        }
    }

    function twelveHour(x) {
        if (x > 24) {
            return x - 24;
        } else if (x == 0) {
            return 12;
        } else {
            return x;
        }
    }

    const h = addZero(twelveHour(date.getHours()));
    const m = addZero(date.getMinutes());

    $('.digital-clock').text(h + ':' + m)
}