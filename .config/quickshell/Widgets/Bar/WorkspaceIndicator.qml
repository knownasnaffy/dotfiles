import QtQuick
import QtQuick.Layouts

Rectangle {
    Layout.preferredWidth: parent.width
    Layout.preferredHeight: workspaces.height
    radius: 16
    color: "#773b4261"
    property list<bool> workspaceOccupied: []

    ColumnLayout {
        id: workspaces

        spacing: 8
        width: parent.width

        Rectangle {
            Layout.topMargin: 10
            Layout.alignment: Qt.AlignHCenter
            radius: 8
            width: 12
            height: 20
            color: '#737aa2'
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            radius: 8
            width: 14
            height: ch1.height
            color: '#7aa2f7'

            ColumnLayout {
                id: ch1

                width: parent.width
                spacing: -2

                Text {
                    Layout.topMargin: 4
                    Layout.alignment: Qt.AlignHCenter
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 10
                    text: ""
                    color: "#881a1b26"
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 10
                    text: ""
                    color: "#881a1b26"
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 10
                    text: ""
                    color: "#1a1b26"
                }

                Text {
                    Layout.bottomMargin: 4
                    Layout.alignment: Qt.AlignHCenter
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 10
                    text: ""
                    color: "#881a1b26"
                }

                transform: Translate {
                    x: -1
                }

            }

        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            radius: 8
            width: 12
            height: 20
            color: '#737aa2'
        }

        Rectangle {
            Layout.bottomMargin: 10
            Layout.alignment: Qt.AlignHCenter
            radius: 8
            width: 12
            height: 20
            color: '#737aa2'
        }

    }

}
