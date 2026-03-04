pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Wayland

Rectangle {
    Layout.preferredWidth: parent.width
    Layout.preferredHeight: workspacesCont.height
    radius: 16
    color: "#773b4261"
    property list<bool> workspaceOccupied: []

    ColumnLayout {
        id: workspacesCont

        spacing: 8
        width: parent.width

        Repeater {
            model: Hyprland.workspaces.values.length


            Rectangle {
                id: workspaceRect

                required property int index
                property list<HyprlandWorkspace> workspaces: Hyprland.workspaces.values
                property HyprlandWorkspace workspace: workspaces[index]

                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: (index == workspaces.length - 1) ? 10 : 0
                Layout.topMargin: index == 0 ? 10 : 0
                radius: 8
                Layout.preferredWidth: 12
                Layout.preferredHeight: workspace.focused ? windowsContainer.height : 20
                color: workspace.focused ? '#7aa2f7' : '#737aa2'
                clip: true

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (!parent.workspace.focused) {
                            parent.workspace.activate()
                        }
                    }
                }

                ColumnLayout {
                    id: windowsContainer
                    height: workspaceRect.workspace.toplevels.values.length < 2 ? 34 : undefined

                    width: parent.width
                    spacing: -2
                    opacity: workspaceRect.workspace.focused ? 1 : 0

                    Repeater {
                        model: workspaceRect.workspace.toplevels.values.length

                        Text {
                            required property int index
                            property Toplevel topLevel: workspaceRect.workspace.toplevels.values[index]
                            property list<Toplevel> windows: workspaceRect.workspace.toplevels.values

                            Layout.topMargin: index == 0 ? 4 : 0
                            Layout.bottomMargin: (index == windows.length - 1 ) ? 4 : 0
                            Layout.alignment: Qt.AlignHCenter
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 10
                            text: ""
                            color: "#551a1b26" // topLevel.focused ? "#1a1b26": "lkjasd"
                        }

                    }

                    transform: Translate {
                        x: -1
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutCubic
                        }
                    }


                }


                Behavior on color {
                    ColorAnimation {
                        duration: 250
                    }
                }

                Behavior on Layout.preferredHeight {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

    }

}
