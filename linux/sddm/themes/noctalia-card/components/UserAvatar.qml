pragma ComponentBehavior: Bound
import Qt5Compat.GraphicalEffects
import QtQuick
import "shapes"
import "shapes/material-shapes.js" as MaterialShapes
import "util.js" as U

// The selected user's face cut to Material's ClamShell shape, as on the lock
// screen, with arrows to switch users when SDDM lists more than one.
Item {
    id: root

    property string userName
    property url faceSource
    property string assetsDir
    property int userCount: 1

    signal previous
    signal next

    // The synced face first, then the one SDDM found for the user.
    readonly property var candidates: [U.asset(assetsDir, "faces/" + userName + ".face.icon"), faceSource]
    property int candidate: 0

    onUserNameChanged: candidate = 0
    onFaceSourceChanged: candidate = 0

    // The mask works only when it is drawn. The face covers it.
    ShapeCanvas {
        id: mask

        anchors.fill: parent
        roundedPolygon: MaterialShapes.getClamShell()
        color: "#000000"
    }

    // Shown when no face loads: the shape in a container colour with the
    // user's initial.
    ShapeCanvas {
        anchors.fill: parent
        roundedPolygon: MaterialShapes.getClamShell()
        color: config.surfaceContainerHigh
        visible: face.status !== Image.Ready

        Text {
            anchors.centerIn: parent
            text: root.userName.charAt(0).toUpperCase()
            color: config.primary
            font.family: "Google Sans Flex"
            font.pixelSize: 110
            font.weight: Font.DemiBold
        }
    }

    Image {
        id: face

        anchors.fill: parent
        source: root.candidate < root.candidates.length ? root.candidates[root.candidate] : ""
        fillMode: Image.PreserveAspectCrop
        mipmap: true
        smooth: true
        asynchronous: true
        visible: status === Image.Ready
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: mask
        }
        onStatusChanged: {
            if (status === Image.Error)
                root.candidate += 1;
        }
    }

    component Arrow: Rectangle {
        id: arrow

        property string glyph
        signal clicked

        width: 44
        height: 44
        radius: 22
        visible: root.userCount > 1
        color: hover.hovered ? U.alpha(config.text, 0.12) : U.alpha(config.text, 0.06)

        Icon {
            anchors.centerIn: parent
            text: arrow.glyph
            size: 28
        }

        HoverHandler {
            id: hover

            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: arrow.clicked()
        }
    }

    Arrow {
        anchors.right: parent.left
        anchors.rightMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        glyph: "chevron_left"
        onClicked: root.previous()
    }

    Arrow {
        anchors.left: parent.right
        anchors.leftMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        glyph: "chevron_right"
        onClicked: root.next()
    }
}
