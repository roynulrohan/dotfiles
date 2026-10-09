pragma ComponentBehavior: Bound
import QtQuick
import "util.js" as U

// The session list (click a row, or Up and Down in the password field) and
// the Caps Lock and keyboard layout chips. On start it selects the first
// session whose name contains "uwsm", else the one SDDM used last.
Card {
    id: root

    property int currentIndex: 0
    readonly property int count: list.count
    readonly property string currentName: list.currentItem ? list.currentItem.sessionName : ""

    function step(delta) {
        currentIndex = Math.max(0, Math.min(count - 1, currentIndex + delta));
    }

    Text {
        id: title

        x: 24
        y: 20
        text: "SESSION"
        color: config.outline
        font.family: "Google Sans Flex"
        font.pixelSize: 13
        font.weight: Font.Bold
        font.letterSpacing: 1.5
    }

    ListView {
        id: list

        property bool chosen: false

        anchors.top: title.bottom
        anchors.topMargin: 12
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 12
        anchors.bottom: chips.top
        anchors.bottomMargin: 12
        clip: true
        spacing: 4
        model: sessionModel
        currentIndex: root.currentIndex
        boundsBehavior: Flickable.StopAtBounds

        delegate: Rectangle {
            id: row

            required property int index
            required property string name
            readonly property string sessionName: name
            readonly property bool selected: index === root.currentIndex

            width: ListView.view.width
            height: 46
            radius: 23
            color: selected ? U.alpha(config.primary, 0.18) : hover.hovered ? U.alpha(config.text, 0.06) : "transparent"

            Component.onCompleted: {
                if (!list.chosen && name.toLowerCase().indexOf("uwsm") !== -1) {
                    list.chosen = true;
                    root.currentIndex = index;
                }
            }

            Icon {
                id: radio

                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                text: row.selected ? "radio_button_checked" : "radio_button_unchecked"
                size: 22
                color: row.selected ? config.primary : config.outline
            }

            Text {
                anchors.left: radio.right
                anchors.leftMargin: 12
                anchors.right: parent.right
                anchors.rightMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                text: row.name
                elide: Text.ElideRight
                color: row.selected ? config.primary : config.text
                font.family: "Google Sans Flex"
                font.pixelSize: 17
                font.weight: row.selected ? Font.DemiBold : Font.Normal
            }

            HoverHandler {
                id: hover

                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                onTapped: root.currentIndex = row.index
            }
        }
    }

    component Chip: Rectangle {
        id: chip

        property string glyph
        property string label
        property bool active

        width: chipRow.implicitWidth + 28
        height: 36
        radius: 18
        color: active ? config.primary : U.alpha(config.text, 0.08)

        Row {
            id: chipRow

            anchors.centerIn: parent
            spacing: 6

            Icon {
                anchors.verticalCenter: parent.verticalCenter
                text: chip.glyph
                size: 20
                color: chip.active ? config.onPrimary : config.outline
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: chip.label
                color: chip.active ? config.onPrimary : config.text
                font.family: "Google Sans Flex"
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }
        }
    }

    Row {
        id: chips

        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        spacing: 8

        Chip {
            glyph: "keyboard_capslock"
            label: keyboard.capsLock ? "Caps Lock on" : "Caps Lock"
            active: keyboard.capsLock
        }

        Chip {
            readonly property var layout: keyboard.layouts.length > 0 ? keyboard.layouts[keyboard.currentLayout] : null

            glyph: "keyboard"
            label: layout ? layout.shortName.toUpperCase() : "—"
            active: false
        }
    }

    Component.onCompleted: {
        if (!list.chosen)
            currentIndex = Math.max(0, sessionModel.lastIndex);
    }
}
