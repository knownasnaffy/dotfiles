import QtQuick
import QtQuick.Layouts

Rectangle {
    Layout.alignment: Qt.AlignBottom
    Layout.preferredWidth: parent.width
    Layout.preferredHeight: container.height
    topRightRadius: 16
    topLeftRadius: 16
    bottomLeftRadius: 6
    bottomRightRadius: 6
    color: "#773b4261"

    ColumnLayout {
        id: container

        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 12

        Bluetooth {}

        Text {
            Layout.alignment: Qt.AlignHCenter
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14
            text: ""
            color: "#7aa2f7"

            transform: Translate {
                x: 1.5
            }
        }

        Brightness {}

        Volume {}
    }
}
