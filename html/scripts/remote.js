const resourceName = window.GetParentResourceName ? window.GetParentResourceName() : 'nui-frame-app';

const apps = ['youtube', 'twitch', 'browser', 'tv', 'home'];
let currentApp = 'home';
let urlType = '';

let preventSpamPowerOn = false;
let isCurrentScreenOn = false
let IsOpen = false;

function GetUrlId(link) {
    if (link == null) return;

    const url = link.toString();
    const regExp = /^.*(youtu\.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/;
    const match = url.match(regExp);

    if (match && match[2].length == 11) {
        return { type: "youtube", id: match[2] };
    } else if (url.split("twitch.tv/").length > 1) {
        return { type: "twitch", id: url.split("twitch.tv/")[1] };
    } else {
        return { type: "browser", id: url };
    }
}

function SlideUp() {
    $(".remotecontrol-container").fadeIn("slow", function () {
        $(".remotecontrol-container").css("display", "block");
    })
}

function SlideDown() {
    $(".remotecontrol-container").fadeOut("slow", function () {
        $(".remotecontrol-container").css("display", "none");
    })

    HoloHide();
}

function HoloHide() {
    $(".holodisplay-container").fadeOut("slow", function () {
        $(".holodisplay-container").css("display", "none");
    })
}

function HoloShow() {
    $(".holodisplay-container").fadeIn("slow", function () {
        $(".holodisplay-container").css("display", "block");

        $("#video-id-input").focus();
    })
}

function PowerOn() {
    $(".onoff-indicator").css("background-color", 'green')
}

function PowerOff() {
    $(".onoff-indicator").css("background-color", 'red')
}

function GetInputValue() {
    return $("#video-id-input").val()
}

function ClearInputvalue() {
    $("#video-id-input").val('')
}

function IsHoloVisible() {
    return $(".holodisplay-container").css('display') == 'block'
}

function PlayVideo() {
    let url = GetInputValue();

    if (!url) return;

    let data = GetUrlId(url);
    if (urlType !== 'browser' && data.type !== urlType) return;

    if (urlType == 'browser') {
        PlayBrowser();
    } else if (urlType == 'youtube' || urlType == 'twitch') {
        $.post(`https://${resourceName}/api-play-video`, JSON.stringify({
            url: url,
            type: data.type
        })).then((res) => {
            if (res) currentApp = res
        });
    }

    ClearInputvalue()

    if ($(".holodisplay-container").css('display') != 'none') {
        HoloHide()
    }
}

function PlayBrowser() {
    $.post(`https://${resourceName}/browser`, JSON.stringify({
        url: GetInputValue()
    })).then((res) => {
        if (res) currentApp = res
    });
}

$(document).on('click', '#power-btn', function (e) {
    e.preventDefault();

    if (preventSpamPowerOn) return;
    preventSpamPowerOn = true;

    isCurrentScreenOn = !isCurrentScreenOn

    if (isCurrentScreenOn) PowerOn()
    else PowerOff()

    $.post(`https://${resourceName}/power-btn`, JSON.stringify({}));

    setTimeout(function () {
        preventSpamPowerOn = false;
    }, 3000);
});

$(document).on('click', '#tv-switch', function (e) {
    e.preventDefault();

    if (isCurrentScreenOn && currentApp !== 'tv') {
        $.post(`https://${resourceName}/api-play-tv`).then((res) => {
            if (res) currentApp = res
        });

        const holoVisible = IsHoloVisible();
        if (holoVisible) HoloHide();
    }
});

$(document).on('click', '#browser-mouse', function (e) {
    e.preventDefault();

    if (isCurrentScreenOn && currentApp == 'browser') {
        SlideDown()

    }
    $.post(`https://${resourceName}/browser-control`, JSON.stringify({}));
});

$(document).on('click', '#ok-btn', function (e) {
    e.preventDefault();

    if (!isCurrentScreenOn) return;

    PlayVideo();
});

let volumeTimeout = null;

$(document).on('click', '#volume-up', function (e) {
    e.preventDefault();

    if (isCurrentScreenOn) {
        if (volumeTimeout) clearTimeout(volumeTimeout);

        $.post(`https://${resourceName}/volume-up`, JSON.stringify({})).then((_currentVolume) => {
            let currentVolume = _currentVolume;

            $('#rod-content').css('height', `${currentVolume * 100}%`)

            $('#volume-indicator').css('left', '-30px')

            let volumeHeight = currentVolume * 100;

            $('#rod-content').css('height', `${volumeHeight}%`)

            if (currentVolume > 0) {
                $('#v-mute').hide();
                $('#v-sound').show();
            }
        });

        volumeTimeout = setTimeout(function () {
            $('#volume-indicator').css('left', '5px')
        }, 2000);
    }
});

$(document).on('click', '#volume-down', function (e) {
    e.preventDefault();

    if (isCurrentScreenOn) {
        if (volumeTimeout) clearTimeout(volumeTimeout);

        $.post(`https://${resourceName}/volume-down`, JSON.stringify({})).then((_currentVolume) => {
            let currentVolume = _currentVolume;

            $('#rod-content').css('height', `${currentVolume * 100}%`)

            $('#volume-indicator').css('left', '-30px')

            let volumeHeight = currentVolume * 100;
            $('#rod-content').css('height', `${volumeHeight}%`)

            if (currentVolume <= 0) {
                $('#v-mute').show();
                $('#v-sound').hide();
            }
        });

        volumeTimeout = setTimeout(function () {
            $('#volume-indicator').css('left', '5px')
        }, 2000);
    }
});

$(document).on('click', '#channel-up', function (e) {
    e.preventDefault();

    if (isCurrentScreenOn && currentApp == 'tv') {
        $.post(`https://${resourceName}/channel-up`)
    }
});

$(document).on('click', '#channel-down', function (e) {
    e.preventDefault();

    if (isCurrentScreenOn && currentApp == 'tv') {
        $.post(`https://${resourceName}/channel-down`);
    }
});

$(document).on('click', '#home-btn', function (e) {
    e.preventDefault();

    if (isCurrentScreenOn && currentApp != 'home') {
        urlType = 'home'

        $.post(`https://${resourceName}/home`).then((res) => {
            if (res) currentApp = res
        });

        const holoVisible = IsHoloVisible();
        if (holoVisible) HoloHide();
    }
});

$(document).on('click', '#back-btn', function (e) {
    e.preventDefault();

    if (isCurrentScreenOn) {
        $.post(`https://${resourceName}/back`).then((res) => {
            if (res) currentApp = res
        });

        const holoVisible = IsHoloVisible();
        if (!holoVisible) HoloHide();
    }
});

$(document).on('click', '#play-btn', function (e) {
    e.preventDefault();

    if (isCurrentScreenOn && currentApp == 'youtube') {
        $.post(`https://${resourceName}/play`);
    }

    const holoVisible = IsHoloVisible();
    if (holoVisible) HoloHide();
});

$(document).on('click', '#yt-btn', function (e) {
    e.preventDefault();

    if (isCurrentScreenOn) {
        if (urlType !== 'youtube') ClearInputvalue();

        const holoVisible = IsHoloVisible();
        if (!holoVisible) HoloShow();

        urlType = 'youtube'

        $.post(`https://${resourceName}/open-youtube`);
    }
});

$(document).on('click', '#twitch-btn', function (e) {
    e.preventDefault();

    if (isCurrentScreenOn) {
        if (urlType !== 'twitch') ClearInputvalue();

        const holoVisible = IsHoloVisible();
        if (!holoVisible) HoloShow();

        urlType = 'twitch'

        $.post(`https://${resourceName}/open-twitch`);
    }
});

$(document).on('click', '#browser-btn', function (e) {
    e.preventDefault();

    if (isCurrentScreenOn) {
        if (urlType !== 'browser') ClearInputvalue();

        const holoVisible = IsHoloVisible();
        if (!holoVisible) HoloShow();

        urlType = 'browser'

        $.post(`https://${resourceName}/open-browser`)
    }
});

$(function () {
    window.addEventListener('message', function (event) {
        if (event.data.type == "open") {
            isCurrentScreenOn = event.data.isOn;
            if (isCurrentScreenOn) PowerOn();
            else PowerOff();

            currentApp = event.data.currentApp;

            SlideUp()

            IsOpen = true;
        } else if (event.data.type == "close") {
            SlideDown();

            PowerOff();

            IsOpen = false;
        } else if (event.data.currentApp) {
            currentApp = event.data.currentApp;
        }

        document.onkeyup = function (data) {
            if (data.key == 'Escape' && IsOpen) { // Escape key
                $.post(`https://${resourceName}/close-remote`, JSON.stringify({}));

                SlideDown();

                IsOpen = false;
            } else if (data.key == 'Enter') { // Enter key 
                if (!isCurrentScreenOn) return;

                PlayVideo();
            }
        };
    })
});

