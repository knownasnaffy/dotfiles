import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Widgets.Bar

ShellRoot {
    PanelWindow {
        id: panel

        implicitWidth: 48
        color: "transparent"
        WlrLayershell.namespace: "Nox:bar"

        anchors {
            left: true
            top: true
            bottom: true
        }

        Rectangle {
            id: mainCont

            bottomRightRadius: 13
            topRightRadius: 13
            color: Qt.rgba(26 / 255, 27 / 255, 38 / 255, 0.9)

            anchors {
                fill: parent
                leftMargin: 0
                topMargin: 16
                bottomMargin: 16
            }

            ColumnLayout {
                anchors {
                    fill: parent
                    topMargin: 8
                    rightMargin: 10
                    leftMargin: 8
                    bottomMargin: 8
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
                    Layout.preferredWidth: parent.width
                    spacing: 10

                    DateTime {
                    }

                    WorkspaceIndicator {
                    }

                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
                    Layout.preferredWidth: parent.width
                    spacing: 10

                    VolumeIndicator {
                    }

                    BatteryIndicator {
                    }

                }

            }

        }

    }

}
