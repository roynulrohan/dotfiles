pragma ComponentBehavior: Bound
import QtQuick
import "util.js" as U

// Suspend, reboot and shut down. A button SDDM says it can't do stays
// visible but dimmed and does nothing.
Row {
    id: root

    spacing: 12

    component PowerButton: Card {
        id: button

        property string glyph
        property string label
        property bool allowed
        signal activated

        width: (root.width - 2 * root.spacing) / 3
        height: root.height
        opacity: allowed ? 1 : 0.4
        color: allowed && hover.hovered ? U.alpha(config.text, 0.12) : U.alpha(config.text, 0.06)

        Column {
            anchors.centerIn: parent
            spacing: 4

            Icon {
                anchors.horizontalCenter: parent.horizontalCenter
                text: button.glyph
                size: 34
                color: config.primary
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: button.label
                color: config.text
                font.family: "Google Sans Flex"
                font.pixelSize: 15
                font.weight: Font.Medium
            }
        }

        HoverHandler {
            id: hover

            enabled: button.allowed
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            enabled: button.allowed
            onTapped: button.activated()
        }
    }

    PowerButton {
        glyph: "bedtime"
        label: "Suspend"
        allowed: sddm.canSuspend
        onActivated: sddm.suspend()
    }

    PowerButton {
        glyph: "restart_alt"
        label: "Reboot"
        allowed: sddm.canReboot
        onActivated: sddm.reboot()
    }

    PowerButton {
        glyph: "power_settings_new"
        label: "Shut down"
        allowed: sddm.canPowerOff
        onActivated: sddm.powerOff()
    }
}
