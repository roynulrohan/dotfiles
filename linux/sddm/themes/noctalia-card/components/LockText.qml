import QtQuick

// One text widget of the Noctalia lock screen, drawn the way Noctalia 5.2.1
// draws a "clock" widget (desktop_widget.cpp, desktop_clock_widget.cpp,
// label.cpp): Bold text from a 56 px base, scaled uniformly so that the line
// height and the advance of the text with every digit replaced by the widest
// one fit the box; centred on the box, with the baseline at the box centre
// plus half a cap height; a hard shadow; clipped to the box. The box is given
// in screen pixels and is never scaled.
Item {
    id: root

    property real cx
    property real cy
    property real boxWidth
    property real boxHeight
    property string text
    property color color
    property string family
    property var axes: ({})
    property bool shadow: true

    readonly property real basePx: 56
    // Pango's line height for both Google Sans Flex fonts: win ascent plus
    // descent, (2452 + 999) / 2000 em.
    readonly property real lineRatio: 3451 / 2000
    // Noctalia measures the cap height on "H" in the shell font, not in the
    // widget's font: JetBrainsMono Nerd Font Bold, 730 / 1000 em.
    readonly property real capRatio: 0.73
    property string widestDigit: "0"
    readonly property real fit: Math.min(boxWidth / Math.max(1, sampleMetrics.advanceWidth), boxHeight / Math.round(lineRatio * basePx))
    readonly property real px: basePx * fit
    readonly property real baselineY: boxHeight / 2 + capRatio * px / 2

    x: cx - boxWidth / 2
    y: cy - boxHeight / 2
    width: boxWidth
    height: boxHeight
    clip: true
    Component.onCompleted: {
        let most = -1;
        for (let d = 0; d <= 9; d++) {
            digitMetrics.text = String(d);
            if (digitMetrics.advanceWidth > most) {
                most = digitMetrics.advanceWidth;
                widestDigit = String(d);
            }
        }
    }

    TextMetrics {
        id: digitMetrics

        font.family: root.family
        font.weight: Font.Bold
        font.variableAxes: root.axes
        font.pixelSize: root.basePx
    }

    TextMetrics {
        id: sampleMetrics

        font: digitMetrics.font
        text: root.text.replace(/[0-9]/g, root.widestDigit)
    }

    component Line: Text {
        width: root.boxWidth
        y: root.baselineY - baselineOffset
        horizontalAlignment: Text.AlignHCenter
        renderType: Text.NativeRendering
        text: root.text
        font.family: root.family
        font.weight: Font.Bold
        font.variableAxes: root.axes
        font.pixelSize: root.px
    }

    // Noctalia's shadow: the same text in the palette's shadow colour (black)
    // at 0.6, 1.5 px times the fit scale down and to the right, not blurred.
    Line {
        visible: root.shadow
        x: 1.5 * root.fit
        y: root.baselineY - baselineOffset + 1.5 * root.fit
        color: Qt.rgba(0, 0, 0, 0.6)
    }

    Line {
        color: root.color
    }
}
