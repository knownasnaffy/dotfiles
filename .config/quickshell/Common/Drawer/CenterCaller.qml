pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
    id: root
    property bool panelVisible: false
    required property real bottomOffset

    IpcHandler {
        target: "center"

        function toggle(): void {
            root.panelVisible = !root.panelVisible
        }
    }

    Center {
        bottomOffset: root.bottomOffset
        visible: root.panelVisible
        customContent: Rectangle {
            id: something
            width: 400
            height: 200
            color: "transparent"
        }

    }

}
