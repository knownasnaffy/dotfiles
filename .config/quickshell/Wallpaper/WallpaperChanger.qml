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
            root.panelVisible = !root.panelVisible;
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


            // Wallpaper row
            RowLayout {
                anchors.centerIn: parent
                spacing: 20

                Rectangle {
                    width: 300
                    height: width * 9 / 16
                    color: "#c0caf5"
                    radius: 8
                    Layout.alignment: Qt.AlignVCenter

                    MouseArea {
                        anchors.fill: parent
                    }
                }

                Rectangle {
                    width: 350
                    height: width * 9 / 16
                    color: "#c0caf5"
                    radius: 8
                    Layout.alignment: Qt.AlignVCenter

                    MouseArea {
                        anchors.fill: parent
                    }
                }

                Rectangle {
                    width: 300
                    height: width * 9 / 16
                    color: "#c0caf5"
                    radius: 8
                    Layout.alignment: Qt.AlignVCenter

                    MouseArea {
                        anchors.fill: parent
                    }
                }
            }

            Rectangle {
                width: 40
                height: 40
                color: "#565f89"
                radius: 16
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 16

                MouseArea {
                    anchors.fill: parent
                    onClicked: WallpaperConfig.previous()
                }
            }
            Rectangle {
                width: 40
                height: 40
                color: "#565f89"
                radius: 16
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 16

                MouseArea {
                    anchors.fill: parent
                    onClicked: WallpaperConfig.next()
                }
            }
        }
    }
}
