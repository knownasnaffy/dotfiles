import QtQuick
import QtQuick.Layouts
import Quickshell.Io

ColumnLayout {
    id: root

    property var wifiData: ({
            state: "disconnected",
            strength: 0
        })

    Layout.alignment: Qt.AlignHCenter
    spacing: 12

    Process {
        running: true
        command: ["sh", "-c", "/home/barinr/.local/bin/ryth status --watch"]

        stdout: SplitParser {
            onRead: line => {
                try {
                    root.wifiData = JSON.parse(line);
                } catch (e) {}
            }
        }
    }

    Text {
        Layout.alignment: Qt.AlignHCenter
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 16
        color: root.wifiData.state === "connected" ? "#7aa2f7" : "#565f89"
        text: {
            if (root.wifiData.state !== "connected")
                return "󰤭";
            const s = root.wifiData.strength;
            if (s >= 75)
                return "󰤨";
            if (s >= 50)
                return "󰤥";
            if (s >= 25)
                return "󰤢";
            return "󰤟";
        }

        transform: Translate {
            x: 1.5
        }
    }
}
