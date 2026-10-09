pragma ComponentBehavior: Bound
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Effects

// Page 1: "Good <part of day> <user>" with the date and time, on a frosted
// card over the wallpaper. The card shrinks away when page 2 opens.
Item {
    id: root

    property bool firstInput
    property bool blurEnabled
    property real blurAmount
    property int rootHeight
    property int rootWidth
    property string username
    property bool ap
    property var videoSourceItem: null
    property date now: new Date()
    // Google Sans Flex, rounded and slightly wide for the greeting.
    readonly property var greetingAxes: ({
            "wght": 600,
            "wdth": 105,
            "ROND": 100,
            "opsz": 144
        })
    readonly property string partOfDay: {
        const h = now.getHours();
        if (h < 5 || h >= 22)
            return "Good night";
        if (h < 12)
            return "Good morning";
        if (h < 17)
            return "Good afternoon";
        return "Good evening";
    }
    readonly property string dateLine: (Qt.formatDateTime(now, "dddd • d MMM") + " • " + Qt.formatDateTime(now, ap ? "h:mm AP" : "HH:mm")).toUpperCase()

    function rgba(hex, alpha) {
        return Qt.rgba(parseInt(hex.substring(1, 3), 16) / 255, parseInt(hex.substring(3, 5), 16) / 255, parseInt(hex.substring(5, 7), 16) / 255, alpha);
    }

    Timer {
        interval: 1000
        running: root.firstInput
        repeat: true
        triggeredOnStart: true
        onTriggered: root.now = new Date()
    }

    FontLoader {
        id: googleSansFlex

        source: "../assets/google-sans-flex/GoogleSansFlex.ttf"
    }

    // The frosted card: the wallpaper (or video) behind the text, blurred,
    // tinted with the surface colour and cut to a rounded rectangle.
    Rectangle {
        id: frost

        width: root.firstInput ? content.width + 96 : content.width / 10
        height: root.firstInput ? content.height + 80 : content.height / 10
        anchors.centerIn: parent
        radius: 32
        color: "transparent"
        clip: true
        opacity: root.firstInput ? 1 : 0
        layer.enabled: true

        AnimatedImage {
            id: backgroundBlur

            anchors.centerIn: parent
            width: root.rootWidth
            height: root.rootHeight
            source: "../assets/background"
            fillMode: Image.PreserveAspectCrop

            ShaderEffectSource {
                anchors.fill: parent
                sourceItem: root.videoSourceItem
                visible: root.videoSourceItem !== null
            }
        }

        MultiEffect {
            blurEnabled: root.blurEnabled
            source: backgroundBlur
            blur: root.blurAmount
            autoPaddingEnabled: false
            blurMultiplier: 1
            blurMax: 64
            anchors.fill: backgroundBlur
        }

        Rectangle {
            anchors.fill: backgroundBlur
            color: root.rgba(config.surface || config.background, parseFloat(config.welcomeColorOpacity) || 0.6)
        }

        Behavior on width {
            NumberAnimation {
                duration: 600
                easing.type: Easing.OutBack
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 600
                easing.type: Easing.OutBack
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 300
            }
        }

        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: frost.width
                height: frost.height
                radius: frost.radius
            }
        }
    }

    Column {
        id: content

        // The greeting's line height adds space above its letters; shift up
        // so the visible margins above and below match.
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -8
        spacing: 14
        opacity: root.firstInput ? 1 : 0

        // The greeting and the name on two lines, the same size.
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: -6

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                renderType: Text.QtRendering
                text: root.partOfDay
                color: config.text
                font.pixelSize: 86
                font.family: googleSansFlex.name
                font.variableAxes: root.greetingAxes
                font.features: ({
                        "liga": 0
                    })
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                renderType: Text.QtRendering
                text: root.username
                color: config.primary
                font.pixelSize: 86
                font.family: googleSansFlex.name
                font.variableAxes: root.greetingAxes
                font.features: ({
                        "liga": 0
                    })
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            renderType: Text.QtRendering
            text: root.dateLine
            color: config.text
            opacity: 0.75
            font.pixelSize: 22
            font.family: googleSansFlex.name
            font.weight: Font.Bold
            font.letterSpacing: 2
        }

        Item {
            width: 1
            height: 6
        }

        // Inside the card: on a bright wallpaper the hint would be unreadable.
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            renderType: Text.QtRendering
            text: "Press any key or click to sign in"
            color: config.outline
            font.pixelSize: 17
            font.family: googleSansFlex.name
            font.weight: Font.Medium

            SequentialAnimation on opacity {
                running: root.firstInput
                loops: Animation.Infinite

                NumberAnimation {
                    to: 0.45
                    duration: 1400
                    easing.type: Easing.InOutSine
                }

                NumberAnimation {
                    to: 1
                    duration: 1400
                    easing.type: Easing.InOutSine
                }
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 250
            }
        }
    }

    PropertyAnimation {
        target: content
        property: "scale"
        from: 0.1
        to: 1
        duration: 600
        easing.type: Easing.OutBack
        running: root.firstInput
    }
}
