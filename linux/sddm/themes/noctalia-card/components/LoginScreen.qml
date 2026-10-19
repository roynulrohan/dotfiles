pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import "util.js" as U

// The main monitor's login. Page 1 (Greeting.qml) greets the selected user.
// Any key or a click opens page 2, the login card modelled on our Noctalia
// lock screen: 1500x840, weather and calendar left; clock, date, avatar,
// name and password centre; GIF, session and power right. Escape goes back.
// User files (wallpaper, video, faces, GIF, location) come from assetsDir,
// which a sync fills. Colours come from theme.conf and theme.conf.user.
Rectangle {
    id: root

    readonly property bool ap: config.ap === "true"
    readonly property string assetsDir: config.assetsDir || "/var/lib/sddm-assets"
    readonly property url backgroundSource: "file://" + assetsDir + "/background"
    property bool firstInput: config.enableWelcomeMessage !== "false"
    property bool loading: false
    property bool failed: false
    property int userIndex: Math.max(0, userModel.lastIndex)
    readonly property var user: users.count > 0 ? users.objectAt(userIndex) : null
    readonly property string userName: user ? user.name : ""
    readonly property var videoItem: videoLoader.item ? (videoLoader.item as VideoBackground).activeVideoItem : null

    function stepUser(delta) {
        if (users.count > 1)
            userIndex = (userIndex + delta + users.count) % users.count;
        failed = false;
    }

    function tryLogin(password) {
        failed = false;
        loading = true;
        sddm.login(root.userName, password, sessionCard.currentIndex);
    }

    width: 1920
    height: 1080
    color: "#131313"
    onFirstInputChanged: {
        if (firstInput) {
            password.clear();
            failed = false;
            pageOneKeys.forceActiveFocus();
        } else {
            password.focusField();
        }
    }

    // userModel as a list, so the selected user's name and face can be read.
    Instantiator {
        id: users

        model: userModel

        delegate: QtObject {
            required property string name
            required property string icon
        }
    }

    Connections {
        function onLoginFailed() {
            root.loading = false;
            root.failed = true;
            password.clear();
            password.shake();
        }

        function onLoginSucceeded() {
            root.loading = false;
        }

        target: sddm
    }

    AnimatedImage {
        id: background

        anchors.fill: parent
        source: root.backgroundSource
        fillMode: Image.PreserveAspectCrop

        Loader {
            id: videoLoader

            anchors.fill: parent
            source: "VideoBackground.qml"
            onLoaded: (item as VideoBackground).dir = root.assetsDir
        }

        Rectangle {
            anchors.fill: parent
            color: "#000000"
            opacity: root.firstInput ? 0 : 0.4

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.InOutCubic
                }
            }
        }
    }

    MultiEffect {
        source: background
        anchors.fill: background
        blurEnabled: true
        blur: root.firstInput ? 0 : 1
        blurMax: 64
        blurMultiplier: 1
        autoPaddingEnabled: false

        Behavior on blur {
            NumberAnimation {
                duration: 400
                easing.type: Easing.InOutCubic
            }
        }
    }

    // Page 1 takes any key. Page 2's keys go to the password field.
    Item {
        id: pageOneKeys

        focus: true
        Keys.onPressed: event => {
            if (root.firstInput && event.key !== Qt.Key_Escape)
                root.firstInput = false;
            event.accepted = true;
        }
    }

    TapHandler {
        enabled: root.firstInput
        onTapped: root.firstInput = false
    }

    Greeting {
        anchors.centerIn: parent
        firstInput: root.firstInput
        rootHeight: root.height
        rootWidth: root.width
        username: root.userName
        ap: root.ap
        backgroundSource: root.backgroundSource
        blurAmount: parseFloat(config.welcomeBgBlurAmount) || 1
        blurEnabled: config.welcomeBgBlur === "true"
        videoSourceItem: root.videoItem
    }

    // Page 2, laid out at 1920x1080 and scaled to the screen.
    Item {
        width: 1920
        height: 1080
        anchors.centerIn: parent
        scale: Math.min(root.width / 1920, root.height / 1080)

        Item {
            id: mainCard

            x: 210
            y: 120
            width: 1500
            height: 840
            scale: root.firstInput ? 0.5 : 1
            opacity: root.firstInput ? 0 : 1
            enabled: !root.firstInput

            Behavior on scale {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutBack
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutBack
                }
            }

            BlurWrapper {
                anchors.centerIn: parent
                targetWidth: mainCard.width
                targetHeight: mainCard.height
                animDuration: 0
                radius: 32
                blurAmount: parseFloat(config.mainCardBlurAmount) || 1
                visibleState: !root.firstInput
                source: root.backgroundSource
                videoSourceItem: root.videoItem
            }

            // Left column: weather, then the month.
            WeatherCard {
                x: 32
                y: 32
                width: 453
                height: 356
                assetsDir: root.assetsDir
            }

            CalendarCard {
                x: 32
                y: 400
                width: 453
                height: 408
            }

            // Centre column (x 525..975): clock, date, avatar, name, password.
            // The lock screen's main clock group, gen.py clock_group(M, 0,
            // center_dy, False), in the same 1920x1080 space as the lock's
            // card, which also sits at 210,120.
            ClockGroup {
                x: -mainCard.x
                y: -mainCard.y
                width: 1920
                height: 1080
                dy: -21
                shadow: false
                chipColor: U.alpha(config.text, 0.1)
            }

            UserAvatar {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 328
                width: 315
                height: 315
                userName: root.userName
                faceSource: root.user ? root.user.icon : ""
                assetsDir: root.assetsDir
                userCount: users.count
                onPrevious: root.stepUser(-1)
                onNext: root.stepUser(1)
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 603
                text: root.userName
                color: config.text
                font.family: "Google Sans Flex"
                font.pixelSize: 24
                font.weight: Font.Bold
            }

            PasswordField {
                id: password

                anchors.horizontalCenter: parent.horizontalCenter
                y: 657
                loading: root.loading
                onSubmitted: text => root.tryLogin(text)
                onEscaped: root.firstInput = true
                onSessionStep: step => sessionCard.step(step)
                onUserStep: step => root.stepUser(step)
                onTextChanged: {
                    if (text.length > 0)
                        root.failed = false;
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 728
                text: root.failed ? "Wrong password" : keyboard.capsLock ? "Caps Lock is on" : ""
                color: root.failed ? config.error : config.tertiary
                font.family: "Google Sans Flex"
                font.pixelSize: 16
                font.weight: Font.Medium
            }

            // Right column: GIF, session, power.
            Card {
                x: 1015
                y: 32
                width: 453
                height: 340

                // The GIF already has the card's size and rounded corners
                // (reroll.py renders it for the lock screen).
                AnimatedImage {
                    anchors.fill: parent
                    source: "file://" + root.assetsDir + "/current.gif"
                    fillMode: Image.PreserveAspectCrop
                    playing: !root.firstInput
                }
            }

            // Session card next to the power row: everything about how to
            // start the session sits together.
            SessionCard {
                id: sessionCard

                x: 1015
                y: 384
                width: 453
                height: 300
            }

            PowerRow {
                x: 1015
                y: 696
                width: 453
                height: 112
            }
        }
    }
}
