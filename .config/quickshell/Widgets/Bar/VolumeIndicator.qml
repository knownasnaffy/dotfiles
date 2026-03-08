import QtQuick
import QtQuick.Layouts

Rectangle {
    Layout.alignment: Qt.AlignBottom
    Layout.preferredWidth: parent.width
    Layout.preferredHeight: container.height
    topRightRadius: 16
    topLeftRadius: 16
    bottomLeftRadius: 4
    bottomRightRadius: 4
    color: "#773b4261"

    ColumnLayout {
        id: container

        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 10
            Layout.bottomMargin: -2
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 18
            text: "󰂲"
            color: "#565f89"

            transform: Translate {
                x: 1
            }

        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
            text: ""
            color: "#7aa2f7"

            transform: Translate {
                x: 1
            }

        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14
            text: "󰃠"
            color: "#e0af68"

            transform: Translate {
                x: 1
            }

        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14
            text: ""
            color: "#565f89"
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 10
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13
            text: ""
            color: "#7aa2f7"

            transform: Translate {
                x: 0.5
            }

        }

    }

}
