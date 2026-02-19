import Qt.labs.platform
import QtMultimedia
import QtQuick

Item {
    id: root

    property string home: StandardPaths.writableLocation(StandardPaths.HomeLocation)

    anchors.fill: parent

    MediaPlayer {
        id: player

        source: "file:///home/barinr/Downloads/mwqn8ouvieob1.gif"
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
