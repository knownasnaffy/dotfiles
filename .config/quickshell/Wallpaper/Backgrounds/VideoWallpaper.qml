import Qt.labs.platform
import QtMultimedia
import QtQuick

Item {
    id: root
    
    property string videoPath: ""
    
    anchors.fill: parent
    
    MediaPlayer {
        id: player
        
        source: {
            if (root.videoPath.startsWith("~/")) {
                return StandardPaths.writableLocation(StandardPaths.HomeLocation) + root.videoPath.substring(1);
            }
            return root.videoPath;
        }
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
