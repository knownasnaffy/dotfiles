import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root
    property bool panelVisible: false

    IpcHandler {
        target: "powermenu"

        function toggle(): void {
            root.panelVisible = !root.panelVisible;
        }
    }

    Process {
        id: proc
        running: false
    }

    PanelWindow {
        visible: root.panelVisible
        aboveWindows: true
        WlrLayershell.namespace: "powermenu"
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        focusable: true

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        Rectangle {
            property real helpTextOpacity: 0

            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Escape || event.key === Qt.Key_Q) {
                    root.panelVisible = false
                }

                if (event.key === Qt.Key_H) {
                    shutdown.onHelpToggle()
                    restart.onHelpToggle()
                    lock.onHelpToggle()
                    logout.onHelpToggle()
                    backdropKeyHelper.helpTextOpacity = backdropKeyHelper.helpTextOpacity === 0 ? 0.8 : 0
                }

                if (event.key === Qt.Key_S) {
                    shutdown.animateClick()
                }

                if (event.key === Qt.Key_R) {
                    restart.animateClick()
                }

                if (event.key === Qt.Key_L) {
                    lock.animateClick()
                }

                if (event.key === Qt.Key_O) {
                    logout.animateClick()
                }
            }

            focus: true
            anchors.fill: parent
            color: "#aa1b1e2d"

            RowLayout {
                id: backdropKeyHelper
                property real helpTextOpacity: 0
                Behavior on helpTextOpacity {
                    NumberAnimation {
                        duration: 120
                        easing.type: Easing.OutCubic
                    }

                }
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 200

                Text {
                    text: "Q, Esc"
                    font.pixelSize: 24
                    color: "#c0caf5"
                    opacity: backdropKeyHelper.helpTextOpacity
                    scale: backdropKeyHelper.helpTextOpacity
                }
            }
            RowLayout {
                anchors.centerIn: parent
                spacing: 80

                PowerButton {
                    id: shutdown
                    iconString: ""
                    helpString: "S"
                    bgColor: "#f7768e"
                    fgColor: "#1b1e2d"
                    onClicked: {
                        proc.command = ["sh", "-c", "hyprhalt --text 'Shutting down' --post-cmd 'systemctl poweroff'"]
                        proc.running = true
                        root.panelVisible = false
                    }
                }
                PowerButton {
                    id: restart
                    iconString: ""
                    helpString: "R"
                    bgColor: "#e0af68"
                    fgColor: "#1b1e2d"
                    onClicked: {
                        proc.command = ["sh", "-c", "hyprhalt --text 'Rebooting' --post-cmd 'systemctl reboot'"]
                        proc.running = true
                        root.panelVisible = false

                    }
                }
                PowerButton {
                    id: lock
                    iconString: ""
                    helpString: "L"
                    bgColor: "#7aa2f7"
                    fgColor: "#1b1e2d"
                    onClicked: {
                        proc.command = ["sh", "-c", "sleep 0.2; hyprlock"]
                        proc.running = true
                        root.panelVisible = false
                    }
                }
                PowerButton {
                    id: logout
                    iconString: ""
                    helpString: "O"
                    bgColor: "#bb9af7"
                    fgColor: "#1b1e2d"
                    onClicked: {
                        proc.command = ["hyprhalt", "--vt", "2"]
                        proc.running = true
                        root.panelVisible = false
                    }
                }
            }
        }
    }
}
