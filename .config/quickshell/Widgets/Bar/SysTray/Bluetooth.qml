import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth

ColumnLayout {
    id: root

    Layout.alignment: Qt.AlignHCenter
    spacing: 12
    Text {
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 10
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 20
        text: Bluetooth.defaultAdapter.enabled ? Bluetooth.defaultAdapter.devices.values.filter(device => device.connected).length > 0 ? "󰂱" : "󰂯" : "󰂲"
        color: Bluetooth.defaultAdapter.enabled ? "#7aa2f7" : "#565f89"

        transform: Translate {
            x: 1
        }
    }
}
