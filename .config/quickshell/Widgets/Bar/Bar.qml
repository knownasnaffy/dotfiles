pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Widgets.Bar.SysTray

ShellRoot {
    PanelWindow {
        id: panel

        implicitWidth: 72
        color: "transparent"
        WlrLayershell.namespace: "Nox:bar"
        aboveWindows: true
        exclusionMode: ExclusionMode.Ignore

        anchors {
            left: true
            top: true
            bottom: true
        }

        Rectangle {
            id: mainCont

            bottomRightRadius: 17
            topRightRadius: 17
            color: Qt.rgba(26 / 255, 27 / 255, 38 / 255, 0.9)

            anchors {
                fill: parent
                leftMargin: 0
                topMargin: 17
                bottomMargin: 17
                rightMargin: 16
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

                    ColumnLayout {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: parent.width

                        SysTray {
                        }

                        BatteryIndicator {
                        }
                    }

                }

            }

        }

    }

}
