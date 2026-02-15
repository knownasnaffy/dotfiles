pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Hyprland

PanelWindow {
    id: root

    property color mColor: "#505050"
    property int cornerHeight: 16
    property int cornerWidth: cornerHeight
    property real animatedWidth: 380

    implicitWidth: 480
    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true
    mask: myRegion
    color: "transparent"
    contentItem.layer.enabled: true
    HyprlandWindow.visibleMask: myRegion

    anchors {
        left: true
        top: true
        right: true
        bottom: true
    }

    Region {
        id: myRegion

        item: customColumn
    }

    WallpaperImage {}

    Item {
        id: mask

        visible: false
        layer.enabled: true
        anchors.fill: parent

        ColumnLayout {
            id: customColumn

            spacing: 0
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.bottomMargin: 47 // 47 for normal, 66 for when audio visualizer is in effect

            Shape {
                property int currentCorner: 3

                preferredRendererType: Shape.CurveRenderer
                asynchronous: true
                Layout.preferredWidth: root.cornerWidth
                Layout.preferredHeight: root.cornerHeight
                Layout.alignment: Qt.AlignRight | Qt.AlignBottom

                ShapePath {
                    startX: 0
                    startY: 0
                    strokeWidth: -1
                    fillColor: root.mColor

                    PathArc {
                        x: root.cornerWidth
                        y: root.cornerHeight
                        radiusX: root.cornerWidth
                        radiusY: root.cornerHeight
                    }

                    PathLine {
                        x: root.cornerWidth
                        y: 0
                    }

                }

                transform: Rotation {
                    origin.x: root.cornerWidth / 2
                    origin.y: root.cornerHeight / 2
                    angle: 3 * -90
                }

            }

            RowLayout {
                spacing: 0
                Layout.alignment: Qt.AlignRight | Qt.AlignBottom

                Shape {
                    id: invertedShape

                    property int currentCorner: 3

                    preferredRendererType: Shape.CurveRenderer
                    asynchronous: true
                    Layout.preferredWidth: root.cornerWidth
                    Layout.preferredHeight: root.cornerHeight
                    Layout.alignment: Qt.AlignRight | Qt.AlignBottom

                    ShapePath {
                        startX: 0
                        startY: 0
                        strokeWidth: -1
                        fillColor: root.mColor

                        PathArc {
                            x: root.cornerWidth
                            y: root.cornerHeight
                            radiusX: root.cornerWidth
                            radiusY: root.cornerHeight
                        }

                        PathLine {
                            x: root.cornerWidth
                            y: 0
                        }

                    }

                    transform: Rotation {
                        origin.x: root.cornerWidth / 2
                        origin.y: root.cornerHeight / 2
                        angle: 3 * -90
                    }

                }

                Rectangle {
                    property real animatedHeight: 0

                    topLeftRadius: 12
                    Layout.preferredWidth: root.animatedWidth > 20 ? root.animatedWidth + 12 : 0
                    Layout.preferredHeight: animatedHeight > 0 ? animatedHeight + 10 : 0
                    Component.onCompleted: {
                        bgStartupTimer.running = true;
                    }

                    Timer {
                        id: bgStartupTimer

                        interval: 100
                        repeat: false
                        running: false
                        onTriggered: {
                            parent.animatedHeight = containerLayout.implicitHeight;
                        }
                    }

                    Behavior on animatedHeight {
                        NumberAnimation {
                            duration: 220
                            easing.type: Easing.OutCubic
                        }

                    }

                }

            }

        }

    }

    ColumnLayout {
        id: customColumn1

        spacing: 0
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.bottomMargin: 49 // 49 for normal, 68 for when audio visualizer is in effect

        RowLayout {
            spacing: 0
            Layout.alignment: Qt.AlignRight | Qt.AlignBottom

            Rectangle {
                id: bg
                property real animatedHeight: 0

                radius: 12
                color: "#ee1b1e2d"
                Layout.preferredWidth: root.animatedWidth
                Layout.preferredHeight: animatedHeight
                Component.onCompleted: {
                    fgStartupTimer.running = true;
                }

                MultiEffect {
        anchors.fill: bg
        source: bg
        blurEnabled: true
        blur: 0.6        // strength (0–1)
        blurMax: 12      // radius
        opacity: 0.9
    }

                Timer {
                    id: fgStartupTimer

                    interval: 100
                    repeat: false
                    running: false
                    onTriggered: {
                        parent.animatedHeight = containerLayout.implicitHeight;
                    }
                }

                ColumnLayout {
                    id: containerLayout
                    // layoutDirection: Qt.LeftToRight
                    spacing: -12
                    Repeater {
                        model: 1

                        Rectangle {
                            color: "#16161e"
                            radius: 8
                            Layout.minimumWidth: root.animatedWidth - 24
                            Layout.margins: 12
                            height: 100
                        }
                    }

                }

                Behavior on animatedHeight {
                    NumberAnimation {
                        duration: 220
                        easing.type: Easing.OutCubic
                    }

                }

            }

        }

    }

    Timer {
        interval: 3000
        repeat: false
        running: true
        onTriggered: {
            root.animatedWidth = 0;
            quitTimer.running = true;
        }
    }

    Timer {
        id: quitTimer

        interval: 220
        repeat: false
        running: false
        onTriggered: {
            // Qt.quit();
        }
    }

    Behavior on animatedWidth {
        NumberAnimation {
            duration: 220
            easing.type: Easing.OutCubic
        }

    }

    contentItem.layer.effect: MultiEffect {
        maskEnabled: true
        maskSource: mask
        maskSpreadAtMin: 1
        maskThresholdMin: 0.5
    }

}
