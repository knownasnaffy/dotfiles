import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import Quickshell.Widgets

ClippingRectangle {
    id: root

    Layout.alignment: Qt.AlignBottom
    Layout.preferredWidth: parent.width
    Layout.preferredHeight: 48
    radius: 16
    color: "#773b4261"

    Text {
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 16
        text: ""
        color: "#c0caf5"

        anchors {
            bottom: parent.bottom
            bottomMargin: 2
            horizontalCenter: parent.horizontalCenter
        }

        transform: Translate {
            x: 1
        }

    }

    ColumnLayout {
        anchors.bottom: parent.bottom
        implicitHeight: parent.height
        implicitWidth: root.width

        Rectangle {
            Layout.alignment: Qt.AlignBottom
            Layout.preferredWidth: root.width
            Layout.preferredHeight: root.height * UPower.displayDevice.percentage
            color: {
                if (UPower.displayDevice.state.toString() == UPowerDeviceState.Charging)
                    return "#9ece6a";

                if (UPower.displayDevice.state.toString() == UPowerDeviceState.FullyCharged)
                    return "#bb9af7";

                if (UPower.displayDevice.percentage < 0.2)
                    return "#db4b4b";

                if (UPower.displayDevice.percentage < 0.4)
                    return "#e0af68";

                return "#7aa2f7";
            }
            clip: true

            Text {
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 16
                text: ""
                color: "#1a1b26"

                anchors {
                    bottom: parent.bottom
                    bottomMargin: 2
                    horizontalCenter: parent.horizontalCenter
                }

                transform: Translate {
                    x: 1
                }

            }

        }

    }

}
