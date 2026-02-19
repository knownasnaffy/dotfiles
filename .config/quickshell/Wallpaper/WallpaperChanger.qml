import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
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

        Rectangle {
            anchors.fill: parent
            color: "#1b1e2d"
            radius: 12

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
