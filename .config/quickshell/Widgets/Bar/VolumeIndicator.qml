import QtQuick
import QtQuick.Layouts

ColumnLayout {
    Layout.alignment: Qt.AlignHCenter
    Layout.preferredWidth: parent.width

    Rectangle {
        Layout.alignment: Qt.AlignBottom
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: 48
        topRightRadius: 16
        topLeftRadius: 16
        bottomLeftRadius: 4
        bottomRightRadius: 4
        color: "#773b4261"

        Text {
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 16
            text: ""
            color: "#c0caf5"

            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                bottomMargin: 2
            }

            transform: Translate {
                x: 1
            }

        }

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 28
            bottomLeftRadius: parent.bottomLeftRadius
            bottomRightRadius: parent.bottomLeftRadius
            color: "#bb9af7"
            clip: true

            Text {
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 16
                text: ""
                color: "#1a1b26"

                anchors {
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                    bottomMargin: 2
                }

            }

        }

    }

    Rectangle {
        Layout.alignment: Qt.AlignBottom
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: 48
        topLeftRadius: 4
        topRightRadius: 4
        bottomLeftRadius: 16
        bottomRightRadius: 16
        color: "#773b4261"

        Text {
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14
            text: ""
            color: "#c0caf5"

            anchors {
                top: parent.top
                topMargin: 4
                horizontalCenter: parent.horizontalCenter
            }

            transform: Translate {
                x: 1
            }

        }

        Rectangle {
            anchors.top: parent.top
            width: parent.width
            height: 28
            topRightRadius: parent.topRightRadius
            topLeftRadius: parent.topLeftRadius
            color: "#7aa2f7"
            clip: true

            Text {
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 14
                text: ""
                color: "#1a1b26"

                anchors {
                    top: parent.top
                    topMargin: 4
                    horizontalCenter: parent.horizontalCenter
                }

                transform: Translate {
                    x: 1
                }

            }

        }

    }

}
