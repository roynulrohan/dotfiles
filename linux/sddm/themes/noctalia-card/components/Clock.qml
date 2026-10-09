import QtQuick
import "util.js" as U

// The lock screen's clock: hours in primary, minutes in secondary beside them,
// and with a 12-hour clock an AM/PM chip under the minutes. Google Sans Flex
// at width 30 and weight 500, the instance the lock screen calls
// "GSF Lock Clock". Adapted from upstream's MainClock.qml.
Item {
    id: root

    property bool ap
    property real hourPx: 230
    property date currentTime: new Date()
    readonly property real minutePx: ap ? hourPx * 0.543 : hourPx
    readonly property real apPx: hourPx * 0.214
    readonly property var fontAxes: ({
            "wght": 500,
            "wdth": 30,
            "ROND": 25,
            "opsz": hourPx
        })

    // Distance from the text item's top to the top of its glyphs.
    function topOff(metrics) {
        return metrics.tightBoundingRect.y - metrics.boundingRect.y;
    }

    implicitWidth: hourText.implicitWidth + 8 + minuteMetrics.tightBoundingRect.x + minuteMetrics.tightBoundingRect.width
    implicitHeight: hourMetrics.tightBoundingRect.height

    Text {
        id: hourText

        y: -root.topOff(hourMetrics)
        renderType: Text.QtRendering
        font.family: "Google Sans Flex"
        font.variableAxes: root.fontAxes
        font.pixelSize: root.hourPx
        color: config.primary
        text: Qt.formatTime(root.currentTime, root.ap ? "hh AP" : "hh").split(" ")[0]

        TextMetrics {
            id: hourMetrics

            text: hourText.text
            font: hourText.font
        }
    }

    Text {
        id: minuteText

        x: hourText.implicitWidth + 8
        y: -root.topOff(minuteMetrics)
        renderType: Text.QtRendering
        font.family: "Google Sans Flex"
        font.variableAxes: root.fontAxes
        font.pixelSize: root.minutePx
        color: config.secondary
        text: Qt.formatTime(root.currentTime, "mm")

        TextMetrics {
            id: minuteMetrics

            text: minuteText.text
            font: minuteText.font
        }
    }

    Rectangle {
        visible: root.ap
        x: minuteText.x + minuteMetrics.tightBoundingRect.x
        y: root.implicitHeight - height
        width: minuteMetrics.tightBoundingRect.width
        height: apMetrics.tightBoundingRect.height + root.hourPx * 0.14
        radius: 16
        color: U.alpha(config.text, 0.1)

        Text {
            id: apText

            anchors.centerIn: parent
            width: apMetrics.tightBoundingRect.width
            height: apMetrics.tightBoundingRect.height
            transform: Translate {
                x: -apMetrics.tightBoundingRect.x
                y: -root.topOff(apMetrics)
            }
            renderType: Text.QtRendering
            font.family: "Google Sans Flex"
            font.variableAxes: root.fontAxes
            font.pixelSize: root.apPx
            color: config.text
            text: Qt.formatTime(root.currentTime, "AP")

            TextMetrics {
                id: apMetrics

                text: apText.text
                font: apText.font
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.currentTime = new Date()
    }
}
