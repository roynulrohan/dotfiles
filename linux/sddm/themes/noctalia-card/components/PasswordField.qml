import QtQuick
import QtQuick.Controls
import "util.js" as U

// The password pill: a lock glyph, the field, and a round submit button.
// Enter or the button submits. Escape goes back to page 1. Up and Down change
// the session, and Left and Right change the user while the field is empty.
Item {
    id: root

    property bool loading: false
    property alias text: field.text

    signal submitted(string password)
    signal escaped
    signal sessionStep(int step)
    signal userStep(int step)

    function focusField() {
        field.forceActiveFocus();
    }

    function clear() {
        field.text = "";
    }

    function shake() {
        shakeAnim.restart();
    }

    onLoadingChanged: {
        if (!loading)
            buttonIcon.rotation = 0;
    }

    function submit() {
        if (!root.loading)
            root.submitted(field.text);
    }

    implicitWidth: 360
    implicitHeight: 56

    Rectangle {
        id: pill

        width: parent.width
        height: parent.height
        radius: height / 2
        color: config.surfaceContainerHigh
        border.width: field.activeFocus ? 2 : 0
        border.color: U.alpha(config.primary, 0.6)

        Icon {
            id: lock

            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            text: "lock"
            size: 22
            color: config.outline
        }

        TextField {
            id: field

            anchors.left: lock.right
            anchors.leftMargin: 10
            anchors.right: button.left
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            enabled: !root.loading
            echoMode: TextInput.Password
            passwordCharacter: "•"
            placeholderText: "Password"
            placeholderTextColor: config.outline
            color: config.text
            selectionColor: U.alpha(config.primary, 0.4)
            font.family: "Google Sans Flex"
            font.pixelSize: 18
            font.letterSpacing: field.text.length > 0 ? 2 : 0
            background: null
            onAccepted: root.submit()
            Keys.onEscapePressed: root.escaped()
            Keys.onUpPressed: root.sessionStep(-1)
            Keys.onDownPressed: root.sessionStep(1)
            Keys.onLeftPressed: event => {
                if (field.text.length === 0)
                    root.userStep(-1);
                else
                    event.accepted = false;
            }
            Keys.onRightPressed: event => {
                if (field.text.length === 0)
                    root.userStep(1);
                else
                    event.accepted = false;
            }
        }

        Rectangle {
            id: button

            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            width: 40
            height: 40
            radius: 20
            color: config.primary

            Icon {
                id: buttonIcon

                anchors.centerIn: parent
                text: root.loading ? "progress_activity" : "arrow_forward"
                size: 24
                color: config.onPrimary

                RotationAnimation on rotation {
                    running: root.loading
                    from: 0
                    to: 360
                    duration: 900
                    loops: Animation.Infinite
                }
            }

            HoverHandler {
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                onTapped: root.submit()
            }
        }

        SequentialAnimation {
            id: shakeAnim

            loops: 2

            NumberAnimation {
                target: pill
                property: "x"
                to: -10
                duration: 50
            }

            NumberAnimation {
                target: pill
                property: "x"
                to: 10
                duration: 100
            }

            NumberAnimation {
                target: pill
                property: "x"
                to: 0
                duration: 50
            }
        }
    }
}
