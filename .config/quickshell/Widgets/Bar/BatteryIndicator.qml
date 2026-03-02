import QtQuick
import QtQuick.Layouts

Rectangle {
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
            horizontalCenter: parent.horizontalCenter
        }

        transform: Translate {
            x: 1
        }

    }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 14
        bottomRightRadius: parent.radius
        bottomLeftRadius: parent.radius
        color: "#9ece6a"
        clip: true

        Text {
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 16
            text: ""
            color: "#1a1b26"

            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }

            transform: Translate {
                x: 1
            }

        }

    }

}
