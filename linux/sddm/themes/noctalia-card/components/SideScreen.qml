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

    color: "#131313"

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

    // gen.py clock_group(out, 0, side_dy, True); the chip in surface at
    // side_chip_alpha (0.6).
    ClockGroup {
        anchors.fill: parent
        dy: 235
        shadow: true
        chipColor: U.alpha(config.surface, 0.6)
    }
}
