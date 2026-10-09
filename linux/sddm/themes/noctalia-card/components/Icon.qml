import QtQuick

// A Material Symbols Rounded glyph by name (a system font from
// ttf-material-symbols-variable).
Text {
    property real size: 24
    property bool filled: false

    font.family: "Material Symbols Rounded"
    font.pixelSize: size
    font.variableAxes: ({
            "FILL": filled ? 1 : 0,
            "wght": 500,
            "opsz": Math.min(48, Math.max(20, size))
        })
    renderType: Text.QtRendering
    color: config.text
}
