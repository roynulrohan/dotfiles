import QtQuick
import QtQuick.Window
import "components"

// Noctalia Card. SDDM opens one window per screen and loads this file in
// each. The window on X's primary screen (Xsetup makes the main monitor
// primary) gets the login (components/LoginScreen.qml); every other window
// gets the lock screen's side view (components/SideScreen.qml).
Item {
    id: root

    // SDDM's primaryScreen is set when the window opens and never changes.
    // While the window is being created, Screen still reports the primary
    // screen, so it can't decide this at start. When the screen list changes
    // (a monitor goes away), compare with the new primary: Qt keeps it first
    // in the list.
    property bool isMain: primaryScreen

    // Keys go to the active window, and with no window manager Qt activates
    // windows as they are shown or clicked. Side windows refuse focus; the
    // main window takes it back from them (but not from other programs, so a
    // test-mode preview doesn't fight the desktop).
    function updateFocusPolicy() {
        const w = Window.window;
        if (w)
            w.flags = isMain ? w.flags & ~Qt.WindowDoesNotAcceptFocus : w.flags | Qt.WindowDoesNotAcceptFocus;
    }

    function reclaimFocus() {
        if (isMain && Window.window && !Window.active && Qt.application.state === Qt.ApplicationActive)
            Window.window.requestActivate();
    }

    onIsMainChanged: {
        updateFocusPolicy();
        reclaimFocus();
    }
    Window.onWindowChanged: updateFocusPolicy()
    Window.onActiveChanged: Qt.callLater(reclaimFocus)
    width: 1920
    height: 1080

    Connections {
        function onScreensChanged() {
            const screens = Qt.application.screens;
            root.isMain = screens.length < 2 || root.Screen.name === screens[0].name;
        }

        target: Qt.application
    }

    FontLoader {
        source: "assets/google-sans-flex/GoogleSansFlex.ttf"
    }

    // The lock screen's clock font: Google Sans Flex at width 30, weight 500,
    // renamed (linux/noctalia/fonts).
    FontLoader {
        source: "assets/google-sans-flex/GSFLockClock-Bold.ttf"
    }

    Loader {
        anchors.fill: parent
        focus: true
        source: root.isMain ? "components/LoginScreen.qml" : "components/SideScreen.qml"
    }
}
