import QtQuick
import QtQuick.Layouts

ColumnLayout {
    Layout.alignment: Qt.AlignHCenter
    Layout.preferredWidth: parent.width

    // Arch logo
    Rectangle {
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: 36
        topRightRadius: 16
        topLeftRadius: 16
        bottomRightRadius: 4
        bottomLeftRadius: 4
        color: "#773b4261"

        Text {
            anchors.centerIn: parent
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 18
            text: "󰣇"
            color: "#7aa2f7"
        }

    }

    // Time
    Rectangle {
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: time.height
        topRightRadius: 4
        topLeftRadius: 4
        bottomRightRadius: 4
        bottomLeftRadius: 4
        color: "#773b4261"

        ColumnLayout {
            id: time

            spacing: 2
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                id: hourStr

                Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
                Layout.topMargin: 6
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
                text: Qt.formatTime(new Date(), "HH")
                color: "#c0caf5"
            }

            Text {
                id: minStr

                Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
                Layout.bottomMargin: 6
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
                text: Qt.formatTime(new Date(), "mm")
                color: "#7aa2f7"
            }

            transform: Translate {
                x: 1
            }

        }

    }

    // Date
    Rectangle {
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: date.height
        topRightRadius: 4
        topLeftRadius: 4
        bottomRightRadius: 16
        bottomLeftRadius: 16
        color: "#773b4261"

        ColumnLayout {
            id: date

            spacing: 2
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                id: dayStr

                Layout.topMargin: 6
                Layout.alignment: Qt.AlignHCenter
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
                text: Qt.formatDate(new Date(), "dddd").toString().toUpperCase().slice(0, 2)
                color: "#c0caf5"
            }

            Text {
                id: dateStr

                Layout.bottomMargin: 8
                Layout.alignment: Qt.AlignHCenter
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
                text: Qt.formatDate(new Date(), "dd")
                color: "#7aa2f7"
            }

            transform: Translate {
                x: 1
            }

        }

    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            hourStr.text = Qt.formatTime(new Date(), "HH");
            minStr.text = Qt.formatTime(new Date(), "mm");
            dayStr.text = Qt.formatDate(new Date(), "dddd").toString().toUpperCase().slice(0, 2);
            dateStr.text = Qt.formatDate(new Date(), "dd");
        }
    }

}
