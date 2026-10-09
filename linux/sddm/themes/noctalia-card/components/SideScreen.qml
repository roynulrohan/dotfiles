import QtQuick
import Qt5Compat.GraphicalEffects
import "util.js" as U

// A side monitor, 1:1 with the Noctalia lock screen's side monitors: the
// clock group from linux/noctalia/lock (gen.py clock_group with side_dy,
// boxes as in the generated lock.toml) over the blurred wallpaper, and
// nothing to click or type into. The video plays on the main monitor only.
Rectangle {
    id: root

    readonly property string assetsDir: config.assetsDir || "/var/lib/sddm-assets"
    readonly property bool ap: config.ap === "true"
    property date now: new Date()

    // Noctalia places a widget by its centre, given for 1920x1080 and
    // scaled per axis to the screen; the box and the text keep their size.
    function sx(cx) {
        return cx * width / 1920;
    }

    function sy(cy) {
        return cy * height / 1080;
    }

    color: "#131313"

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    Image {
        id: background

        anchors.fill: parent
        source: "file://" + root.assetsDir + "/background"
        fillMode: Image.PreserveAspectCrop
        visible: false
    }

    // The lock screen's blur at blur_intensity 1.0 (Noctalia's blur_cache):
    // three rounds of a separable Gaussian, sigma 20 px, taps out to 40 px,
    // edges clamped. GaussianBlur takes at most 32 samples and counts
    // deviation in samples: 32 samples over radius 40 are 2.5 px apart, so
    // sigma 20 px is deviation 8. Each round is cached, so the blur runs once.
    GaussianBlur {
        id: round1

        anchors.fill: parent
        source: background
        radius: 40
        samples: 32
        deviation: 8
        cached: true
        visible: false
    }

    GaussianBlur {
        id: round2

        anchors.fill: parent
        source: round1
        radius: 40
        samples: 32
        deviation: 8
        cached: true
        visible: false
    }

    GaussianBlur {
        anchors.fill: parent
        source: round2
        radius: 40
        samples: 32
        deviation: 8
        cached: true
    }

    // gen.py clock_group(out, 0, side_dy = 235, shadow = True); centres and
    // boxes from params.json "clock".
    LockText {
        cx: root.sx(914.5)
        cy: root.sy(516)
        boxWidth: 220
        boxHeight: 388
        text: Qt.formatTime(root.now, root.ap ? "hh AP" : "hh").split(" ")[0]
        color: config.primary
        family: "GSF Lock Clock"
    }

    LockText {
        cx: root.sx(1042)
        cy: root.sy(478.5)
        boxWidth: 110
        boxHeight: 207
        text: Qt.formatTime(root.now, "mm")
        color: config.secondary
        family: "GSF Lock Clock"
    }

    // The AM/PM chip: a label widget whose background is exactly its box,
    // surface at side_chip_alpha (0.6), radius 16.
    Rectangle {
        visible: root.ap
        x: root.sx(1042) - width / 2
        y: root.sy(568) - height / 2
        width: 76
        height: 66
        radius: 16
        color: U.alpha(config.surface, 0.6)
    }

    LockText {
        visible: root.ap
        cx: root.sx(1042)
        cy: root.sy(568)
        boxWidth: 76
        boxHeight: 84
        text: Qt.formatTime(root.now, "AP")
        color: config.text
        family: "GSF Lock Clock"
    }

    LockText {
        cx: root.sx(960)
        cy: root.sy(648)
        boxWidth: 320
        boxHeight: 37
        text: Qt.formatDate(root.now, "dddd • d MMM").toUpperCase()
        color: config.text
        family: "Google Sans Flex"
        axes: ({
                "wght": 700
            })
    }
}
