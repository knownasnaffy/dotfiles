pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Io

ShellRoot {
    id: root

    property bool panelVisible: false
    property color mColor: "#505050"
    property real cornerSize: 16
    property int mainHeight: 500
    property int mainWidth: panelVisible ? 700 : 0

    property int clipboardActiveIndex: 0
    property var clipboard: [
        {
            name: "Web Dev",
            id: 100
        },
        {
            name: "Waka Waka",
            id: 101
        },
        {
            name: "Tiranasorus or something idk",
            id: 102
        },
        {
            name: "Glorious purpose",
            id: 103
        },
        {
            name: "Hello world",
            id: 80
        },
        {
            name: "Hyperland config",
            id: 104
        },
        {
            name: "Neovim keymap",
            id: 105
        },
        {
            name: "Tokyo Night palette",
            id: 106
        },
        {
            name: "Ghostty settings",
            id: 107
        },
        {
            name: "Arch install notes",
            id: 108
        },
        {
            name: "Systemd service example",
            id: 109
        },
        {
            name: "Wayland clipboard entry",
            id: 110
        },
        {
            name: "Shell script snippet",
            id: 111
        },
        {
            name: "Rofi launcher config",
            id: 112
        },
        {
            name: "SQL query test",
            id: 113
        },
        {
            name: "Docker compose sample",
            id: 114
        },
        {
            name: "Random debug output",
            id: 115
        },
        {
            name: "Clipboard history item",
            id: 116
        },
        {
            name: "Lorem ipsum text",
            id: 117
        },
        {
            name: "Temporary paste",
            id: 118
        }
    ]

    Behavior on mainWidth {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    IpcHandler {
        id: handler

        function toggle(): void {
            if (root.panelVisible) {
                root.panelVisible = false;
                hideTimer.running = true;
            } else {
                mainPanel.visible = true;
                showTimer.running = true;
            }
        }

        target: "clipboard"
    }

    Timer {
        id: hideTimer
        interval: 300
        running: false
        repeat: false
        onTriggered: {
            mainPanel.visible = false;
        }
    }

    Timer {
        id: showTimer
        interval: 150
        running: false
        repeat: false
        onTriggered: {
            root.panelVisible = true;
        }
    }

    PanelWindow {
        id: mainPanel

        visible: false
        color: "transparent"
        aboveWindows: true
        contentItem.layer.enabled: true
        focusable: true

        anchors {
            left: true
            top: true
            right: true
            bottom: true
        }

        WallpaperImage {}

        Item {
            id: maskCont

            visible: false
            layer.enabled: true
            anchors.fill: parent

            ColumnLayout {
                spacing: 0

                anchors {
                    bottom: parent.bottom
                    bottomMargin: 16
                    leftMargin: 70
                    left: parent.left
                }

                Shape {

                    opacity: root.mainWidth < root.cornerSize ? 0 : 1

                    preferredRendererType: Shape.CurveRenderer
                    asynchronous: true
                    Layout.preferredWidth: root.cornerSize
                    Layout.preferredHeight: root.cornerSize

                    ShapePath {
                        startX: 0
                        startY: 0
                        strokeWidth: -1
                        fillColor: root.mColor

                        PathArc {
                            x: root.cornerSize
                            y: root.cornerSize
                            radiusX: root.cornerSize
                            radiusY: root.cornerSize
                        }

                        PathLine {
                            x: root.cornerSize
                            y: 0
                        }
                    }

                    transform: Rotation {
                        origin.x: 8
                        origin.y: 8
                        angle: 2 * -90
                    }
                }

                RowLayout {
                    // Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
                    spacing: 600

                    Rectangle {
                        id: bgMask

                        Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
                        width: root.mainWidth
                        height: root.mainHeight
                        topRightRadius: 16
                        color: root.mColor
                    }

                    Shape {
                        anchors {
                            left: bgMask.right
                        }
                        Layout.alignment: Qt.AlignBottom
                        preferredRendererType: Shape.CurveRenderer
                        asynchronous: true
                        Layout.preferredWidth: root.cornerSize
                        Layout.preferredHeight: root.cornerSize

                        ShapePath {
                            startX: 0
                            startY: 0
                            strokeWidth: -1
                            fillColor: root.mColor

                            PathArc {
                                x: root.cornerSize
                                y: root.cornerSize
                                radiusX: root.cornerSize
                                radiusY: root.cornerSize
                            }

                            PathLine {
                                x: root.cornerSize
                                y: 0
                            }
                        }

                        transform: Rotation {
                            origin.x: 8
                            origin.y: 8
                            angle: 2 * -90
                        }
                    }
                }
            }
        }

        Rectangle {
            id: contentRect

            width: root.mainWidth - 12
            height: root.mainHeight - 12
            color: "#ee1a1b26"
            radius: 16

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape || event.key === Qt.Key_Q) {
                    handler.toggle();
                }
                if (event.key === Qt.Key_K) {
                    if (root.clipboardActiveIndex != root.clipboard.length)
                        root.clipboardActiveIndex = root.clipboardActiveIndex + 1;
                }
                if (event.key === Qt.Key_L) {
                    if (root.clipboardActiveIndex != 0)
                        root.clipboardActiveIndex = root.clipboardActiveIndex - 1;
                }
            }

            focus: true

            anchors {
                bottom: parent.bottom
                bottomMargin: 16
                left: parent.left
                leftMargin: 70
            }

            Rectangle {
                color: 'transparent'
                anchors {
                    fill: parent
                }
                ColumnLayout {
                    spacing: 4

                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        topMargin: 20
                    }

                    Rectangle {
                        Layout.preferredHeight: 40
                        Layout.preferredWidth: root.mainWidth - 60
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                        Layout.bottomMargin: 12
                        color: "#443b4261"
                        radius: 12
                    }

                    Repeater {
                        model: ScriptModel {
                            values: root.clipboard.filter(entry => entry.name.includes(""))
                        }

                        delegate: Rectangle {
                            required property int index
                            required property var modelData

                            Layout.preferredWidth: root.mainWidth - 60
                            Layout.preferredHeight: 40
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                            Layout.bottomMargin: index == root.clipboardActiveIndex ? 6 : 0
                            Layout.topMargin: index == root.clipboardActiveIndex ? 6 : 0
                            radius: 12
                            color: index == root.clipboardActiveIndex ? "#7aa2f7" : "transparent"

                            Text {
                                anchors {
                                    verticalCenter: parent.verticalCenter
                                    left: parent.left
                                    leftMargin: 16
                                }
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 14
                                text: parent.modelData.name
                                color: parent.index == root.clipboardActiveIndex ? "#1a1b26" : "#c0caf5"
                            }
                        }
                    }
                }
            }
        }

        contentItem.layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: maskCont
            maskSpreadAtMin: 1
            maskThresholdMin: 0.5
        }
    }
}
