import QtQuick
import "util.js" as U

// An inner card on the main card: the lock screen's container colour
// (on_surface at a low alpha) and its one radius.
Rectangle {
    radius: 28
    color: U.alpha(config.text, 0.06)
}
