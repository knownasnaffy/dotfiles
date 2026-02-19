import QtQuick
import qs.Wallpaper.AudioVisualizer

Item {
    property bool visualizerEnabled: hyprGapController.gapsIncreased

    anchors.fill: parent

    CavaSource {
        id: cava

        onUpdated: {
            left.requestPaint();
        }
    }

    HyprGapController {
        id: hyprGapController

        silent: cava.isSilent
    }

    MountainWave {
        id: left

        data: cava.data
        shadowData: cava.shadowData
        anchors.fill: parent
        anchors.rightMargin: 40
        anchors.leftMargin: 40
        anchors.topMargin: parent.height - (hyprGapController.gapsIncreased ? 64 : 44)
        anchors.bottomMargin: 38
    }

}
