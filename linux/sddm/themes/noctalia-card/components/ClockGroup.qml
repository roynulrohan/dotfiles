import QtQuick

// The lock screen's clock group, gen.py clock_group(): hours, minutes, the
// AM/PM chip and text, and the date, with the boxes from params.json
// "clock". Centres are given for 1920x1080 and scaled per axis to this
// item's size, as Noctalia places widgets. Boxes and text keep their size.
// The main monitor uses dy = center_dy (-21) without shadows and the chip in
// on_surface at chip_alpha. Side monitors use dy = side_dy (235) with
// shadows and the chip in surface at side_chip_alpha.
Item {
    id: root

    property real dy
    property bool shadow
    property color chipColor
    readonly property bool ap: config.ap === "true"
    property date now: new Date()

    function sx(cx) {
        return cx * width / 1920;
    }

    function sy(cy) {
        return (cy + dy) * height / 1080;
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    LockText {
        cx: root.sx(914.5)
        cy: root.sy(281)
        boxWidth: 220
        boxHeight: 388
        text: Qt.formatTime(root.now, root.ap ? "hh AP" : "hh").split(" ")[0]
        color: config.primary
        family: "GSF Lock Clock"
        shadow: root.shadow
    }

    LockText {
        cx: root.sx(1042)
        cy: root.sy(243.5)
        boxWidth: 110
        boxHeight: 207
        text: Qt.formatTime(root.now, "mm")
        color: config.secondary
        family: "GSF Lock Clock"
        shadow: root.shadow
    }

    // A label widget whose background is exactly its box, radius 16.
    Rectangle {
        visible: root.ap
        x: root.sx(1042) - width / 2
        y: root.sy(333) - height / 2
        width: 76
        height: 66
        radius: 16
        color: root.chipColor
    }

    LockText {
        visible: root.ap
        cx: root.sx(1042)
        cy: root.sy(333)
        boxWidth: 76
        boxHeight: 84
        text: Qt.formatTime(root.now, "AP")
        color: config.text
        family: "GSF Lock Clock"
        shadow: root.shadow
    }

    LockText {
        cx: root.sx(960)
        cy: root.sy(413)
        boxWidth: 320
        boxHeight: 37
        text: Qt.formatDate(root.now, "dddd • d MMM").toUpperCase()
        color: config.text
        family: "Google Sans Flex"
        axes: ({
                "wght": 700
            })
        shadow: root.shadow
    }
}
