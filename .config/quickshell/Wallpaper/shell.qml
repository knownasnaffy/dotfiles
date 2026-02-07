import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

PanelWindow {
    aboveWindows: false
    focusable: true
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "Nox:wallpaper"
    WlrLayershell.layer: WlrLayer.Background

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    Image {
        anchors.fill: parent
        source: "/home/barinr/Downloads/w11.jpg"
        fillMode: Image.PreserveAspectFit
        z: 0
    }

    Text {
        id: clock

        z: 1
        text: Qt.formatTime(new Date(), "HH:mm")
        color: "#f2f2f2"
        font.family: "Inter"
        font.pixelSize: parent.height * 0.36
        font.weight: Font.Bold
        // POSITION (percent-based)
        x: parent.width * 0.38 - width / 2
        y: parent.height * 0.14

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: clock.text = Qt.formatTime(new Date(), "HH:mm")
        }

    }

    Image {
        anchors.fill: parent
        source: "/home/barinr/Downloads/w13.png"
        fillMode: Image.PreserveAspectFit
        z: 2
    }

}
