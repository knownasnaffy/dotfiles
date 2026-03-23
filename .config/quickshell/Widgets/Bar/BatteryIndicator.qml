import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Services.UPower
import Quickshell.Widgets

ClippingRectangle {
    id: root

    Layout.alignment: Qt.AlignBottom
    Layout.preferredWidth: parent.width
    Layout.preferredHeight: 40
    topLeftRadius: 6
    topRightRadius: 6
    bottomLeftRadius: 16
    bottomRightRadius: 16
    color: "#773b4261"

    Text {
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 16
        text: ""
        color: "#c0caf5"

        anchors {
            bottom: parent.bottom
            bottomMargin: 4
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
            property real warningThreshold: 0.3
            property real errorThreshold: 0.2
            property real lockdownThreshold: 0.12
            property real batteryPercentage: UPower.displayDevice.percentage
            property real previousBatteryPercentage: 0
            property int batteryChargeLimit: 80

            onBatteryPercentageChanged: {
                if (batteryPercentage <= warningThreshold && previousBatteryPercentage > warningThreshold) {
                    console.log("Launching Warning Popup for Battery");
                    proc.command = ["sh", "-c", `$HOME/.local/bin/battery-notify warning ${warningThreshold * 100}`];
                    proc.running = true;
                } else if (batteryPercentage <= errorThreshold && previousBatteryPercentage > errorThreshold) {
                    console.log("Launching Error Popup for Battery");
                    proc.command = ["sh", "-c", `$HOME/.local/bin/battery-notify critical ${errorThreshold * 100}`];
                    proc.running = true;
                } else if (batteryPercentage <= lockdownThreshold && previousBatteryPercentage > lockdownThreshold) {
                    console.log("Launching Lockdown Popup for Battery");
                    proc.command = ["sh", "-c", "qs ipc call battery open"];
                    proc.running = true;
                } else if (previousBatteryPercentage <= lockdownThreshold && UPower.displayDevice.state == UPowerDeviceState.Charging) {
                    console.log("Launching Lockdown Popup for Battery");
                    proc.command = ["sh", "-c", "qs ipc call battery close"];
                    proc.running = true;
                }
                previousBatteryPercentage = batteryPercentage;
                console.log("Battery changed", batteryPercentage);
            }

            Layout.alignment: Qt.AlignBottom
            Layout.preferredWidth: root.width
            Layout.preferredHeight: root.height * (batteryPercentage * 100 / batteryChargeLimit)
            color: {
                if (UPower.displayDevice.state == UPowerDeviceState.Charging)
                    return "#9ece6a";

                if (UPower.displayDevice.state == UPowerDeviceState.FullyCharged || UPower.displayDevice.percentage >= 0.8)
                    return "#bb9af7";

                if (UPower.displayDevice.percentage < 0.2)
                    return "#db4b4b";

                if (UPower.displayDevice.percentage < 0.4)
                    return "#e0af68";

                return "#7aa2f7";
            }
            clip: true

            Process {
                id: proc

                running: false
            }

            Text {
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 16
                text: ""
                color: "#1a1b26"

                anchors {
                    bottom: parent.bottom
                    bottomMargin: 4
                    horizontalCenter: parent.horizontalCenter
                }

                transform: Translate {
                    x: 1
                }
            }
        }
    }
}
