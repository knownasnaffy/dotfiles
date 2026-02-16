import QtQuick
import "root:/Wallpaper/AudioVisualizer" as AV

Item {
    property bool visualizerEnabled: hyprGapController.gapsIncreased

    anchors.fill: parent

    AV.CavaSource {
        id: cava

        onUpdated: {
            left.requestPaint();
            right.requestPaint();
        }
    }

    AV.HyprGapController {
        id: hyprGapController

        silent: cava.isSilent
    }

    AV.MountainWave {
        id: left

        data: cava.data
        shadowData: cava.shadowData
        anchors.fill: parent
        anchors.rightMargin: 40
        anchors.leftMargin: 40
        anchors.topMargin: parent.height - 64
        anchors.bottomMargin: 38
    }

}
