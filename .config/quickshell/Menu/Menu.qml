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

    Behavior on mainWidth {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    IpcHandler {
        function toggle(): void {
            if (root.panelVisible) {
                root.panelVisible = false;
                hideTimer.running = true;
            } else {
                mainPanel.visible = true;
                showTimer.running = true;
            }
        }

        target: "menu"
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

            anchors {
                bottom: parent.bottom
                bottomMargin: 16
                left: parent.left
                leftMargin: 70
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
