import QtQuick

Item {
    anchors.fill: parent

    CavaSource {
        id: cava

        onUpdated: {
            left.requestPaint();
            right.requestPaint();
        }
    }

    HyprGapController {
        silent: cava.isSilent
    }

    MountainWave {
        id: left

        data: cava.data
        shadowData: cava.shadowData
        anchors.fill: parent
        anchors.rightMargin: parent.width / 2
        anchors.leftMargin: 40
        anchors.topMargin: parent.height - 64
        anchors.bottomMargin: 38
    }

    MountainWave {
        id: right

        data: cava.data
        shadowData: cava.shadowData
        anchors.fill: parent
        anchors.rightMargin: 40
        anchors.leftMargin: parent.width / 2
        anchors.topMargin: parent.height - 64
        anchors.bottomMargin: 38
    }

}
