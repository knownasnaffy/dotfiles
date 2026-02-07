import QtQuick

Text {
    id: clock

    text: Qt.formatTime(new Date(), "HH:mm")
    color: "#f2f2f2"

    font.family: "Inter"
    font.pixelSize: parent.height * 0.36
    font.weight: Font.Bold

    // POSITION (percent-based)
    x: parent.width  * 0.38  - width / 2
    y: parent.height * 0.14

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: clock.text = Qt.formatTime(new Date(), "HH:mm")
    }
}
