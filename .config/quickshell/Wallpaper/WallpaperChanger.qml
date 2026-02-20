import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Wallpaper

ShellRoot {
    id: root
    property bool panelVisible: false

    IpcHandler {
        target: "wallpaper-changer"

        function toggle(): void {
            // console.log("Toggle called, current state:", panelVisible);
            root.panelVisible = !root.panelVisible;
            // console.log("New state:", panelVisible);
        }
    }

    PanelWindow {
        visible: root.panelVisible
        implicitWidth: 600
        implicitHeight: 300
        color: "transparent"
        focusable: true
        WlrLayershell.namespace: "powermenu"

        Rectangle {
            anchors.fill: parent
            color: "#aa1b1e2d"
            radius: 12

            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Escape || event.key === Qt.Key_Q) {
                    root.panelVisible = false
                }

                if (event.key === Qt.Key_J) {
                    WallpaperConfig.previous()
                }

                if (event.key === Qt.Key_Semicolon) {
                    WallpaperConfig.next()
                }

                if (event.key === Qt.Key_R) {
                    WallpaperConfig.random()
                }
            }

            focus: true


            RowLayout {
                anchors.centerIn: parent
                spacing: 20

                Rectangle {
                    width: 200
                    height: width * 9 / 16
                    color: "#c0caf5"
                    radius: 8
                    Layout.alignment: Qt.AlignVCenter

                    MouseArea {
                        anchors.fill: parent
                        onClicked: WallpaperConfig.random()
                    }
                }
            }

            Rectangle {
                width: 40
                height: 40
                color: "#c0caf5"
                radius: 8
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left

                MouseArea {
                    anchors.fill: parent
                    onClicked: WallpaperConfig.previous()
                }
            }
            Rectangle {
                width: 40
                height: 40
                color: "#c0caf5"
                radius: 8
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right

                MouseArea {
                    anchors.fill: parent
                    onClicked: WallpaperConfig.next()
                }
            }
        }
    }
}
