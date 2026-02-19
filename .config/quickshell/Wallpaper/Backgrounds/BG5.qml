import Qt.labs.platform
import QtQuick

Item {
    id: root

    property string wallpapersPath: StandardPaths.writableLocation(StandardPaths.HomeLocation) + '/Pictures/Wallpapers'

    anchors.fill: parent

    Image {
        anchors.fill: parent
        source: root.wallpapersPath + "/bg05.png"
        fillMode: Image.PreserveAspectFit
        z: 0
    }

}
