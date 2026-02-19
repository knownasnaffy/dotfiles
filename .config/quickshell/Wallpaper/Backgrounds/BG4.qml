import Qt.labs.platform
import QtQuick

Item {
    id: root

    property string home: StandardPaths.writableLocation(StandardPaths.HomeLocation)

    anchors.fill: parent

    Image {
        anchors.fill: parent
        source: root.home + "/Pictures/bg4.jpg"
        fillMode: Image.PreserveAspectFit
        z: 0
    }

}
