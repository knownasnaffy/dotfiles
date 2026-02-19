import Qt.labs.platform
import QtMultimedia
import QtQuick

Item {
    id: root

    property string wallpapersPath: StandardPaths.writableLocation(StandardPaths.HomeLocation) + '/Pictures/Wallpapers'

    anchors.fill: parent

    MediaPlayer {
        id: player

        source: root.wallpapersPath + "/bg03.gif"
        loops: MediaPlayer.Infinite
        autoPlay: true
        videoOutput: videoOutput
    }

    VideoOutput {
        id: videoOutput

        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectFit
    }

}
