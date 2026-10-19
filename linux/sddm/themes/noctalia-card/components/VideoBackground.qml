import QtMultimedia
import QtQuick

Item {
    id: root

    // The synced assets folder. The probe starts when it is set.
    property string dir
    property bool isActive: false
    readonly property var activeVideoItem: isActive ? videoSurface : null
    readonly property var candidates: ["mp4", "webm", "mkv", "mov", "m4v", "avi"]
    property int probeIndex: 0

    function probeNext() {
        if (probeIndex >= candidates.length)
            return;

        var ext = candidates[probeIndex];
        probeIndex += 1;
        player.source = "file://" + root.dir + "/background." + ext;
    }

    onDirChanged: {
        if (config.backgroundVideoEnabled !== "false")
            probeNext();
    }

    MediaPlayer {
        id: player

        videoOutput: videoSurface
        loops: MediaPlayer.Infinite
        // When a file is missing or corrupt, try the next extension. If none
        // loads, the still stays visible.
        onErrorOccurred: function (error, errorString) {
            if (root.isActive)
                return;

            root.probeNext();
        }
        onMediaStatusChanged: {
            if (root.isActive)
                return;

            if (mediaStatus === MediaPlayer.LoadedMedia) {
                if (player.hasVideo) {
                    root.isActive = true;
                    player.play();
                } else {
                    root.probeNext();
                }
            }
        }
    }

    VideoOutput {
        id: videoSurface

        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectCrop
        visible: root.isActive
    }
}
