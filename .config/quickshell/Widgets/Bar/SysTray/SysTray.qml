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

        Wifi {}

        Brightness {}

        Volume {}
    }
}
