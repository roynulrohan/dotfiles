pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import "util.js" as U

// This month's grid with today marked, no events, as on the lock screen.
Card {
    id: root

    property date today: new Date()

    // Move to the new day after midnight.
    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: {
            const now = new Date();
            if (now.getDate() !== root.today.getDate())
                root.today = now;
        }
    }

    Text {
        id: title

        x: 28
        y: 22
        text: Qt.formatDate(root.today, "MMMM yyyy")
        color: config.text
        font.family: "Google Sans Flex"
        font.pixelSize: 20
        font.weight: Font.DemiBold
    }

    DayOfWeekRow {
        id: weekdays

        anchors.top: title.bottom
        anchors.topMargin: 14
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        locale: grid.locale

        delegate: Text {
            required property string shortName

            text: shortName.substring(0, 2)
            horizontalAlignment: Text.AlignHCenter
            color: config.outline
            font.family: "Google Sans Flex"
            font.pixelSize: 13
            font.weight: Font.Bold
        }
    }

    MonthGrid {
        id: grid

        anchors.top: weekdays.bottom
        anchors.topMargin: 6
        anchors.left: weekdays.left
        anchors.right: weekdays.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 18
        month: root.today.getMonth()
        year: root.today.getFullYear()
        locale: Qt.locale()

        delegate: Item {
            id: cell

            required property var model
            readonly property bool isToday: model.today
            readonly property bool inMonth: model.month === grid.month

            Rectangle {
                anchors.centerIn: parent
                width: Math.min(parent.width, parent.height) - 4
                height: width
                radius: width / 2
                color: config.primary
                visible: cell.isToday
            }

            Text {
                anchors.centerIn: parent
                text: cell.model.day
                color: cell.isToday ? config.onPrimary : config.text
                opacity: cell.inMonth ? 1 : 0.3
                font.family: "Google Sans Flex"
                font.pixelSize: 16
                font.weight: cell.isToday ? Font.Bold : Font.Normal
            }
        }
    }
}
