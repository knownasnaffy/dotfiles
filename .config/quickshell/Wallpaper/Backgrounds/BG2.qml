import Qt.labs.platform
import QtQuick

Item {
    id: root

    property string wallpapersPath: StandardPaths.writableLocation(StandardPaths.HomeLocation) + '/Pictures/Wallpapers'

    anchors.fill: parent

    Image {
        anchors.fill: parent
        source: root.wallpapersPath + "/bg02.jpeg"
        fillMode: Image.PreserveAspectFit
        z: 0
    }

    Text {
        id: clock

        z: 1
        text: Qt.formatTime(new Date(), "HH:mm")
        color: "#322c29"
        font.family: "Inter"
        font.pixelSize: 32
        font.weight: Font.ExtraBold
        // POSITION (percent-based)
        x: 450
        y: 480

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: clock.text = Qt.formatTime(new Date(), "HH:mm")
        }

    }

}
