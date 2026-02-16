import QtQuick
import Quickshell
import Quickshell.Io
// import Quickshell.Wayland

ShellRoot {
    id: root
    property bool panelVisible: false

    IpcHandler {
        target: "menu"

        function toggle(): void {
            // console.log("Toggle called, current state:", panelVisible);
            root.panelVisible = !root.panelVisible;
            // console.log("New state:", panelVisible);
        }
    }

    PanelWindow {
        visible: root.panelVisible
        implicitWidth: 400
        implicitHeight: 300
        color: "transparent"
    focusable: true

        Rectangle {
            anchors.fill: parent
            color: "#1b1e2d"
            radius: 12

            Text {
                anchors.centerIn: parent
                text: "Menu Panel"
                color: "#c0caf5"
                font.pixelSize: 24
            }
        }
    }
}
