pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell

PanelWindow {
    id: root

    property color mColor: "#505050"
    property int cornerHeight: 16
    property int cornerWidth: cornerHeight
    property real animatedWidth: mainSizeDecider.implicitWidth
    property real animatedHeight: mainSizeDecider.implicitHeight
    required property real bottomOffset
    required property Component customContent

    implicitWidth: 480
    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true
    mask: myRegion
    color: "transparent"
    contentItem.layer.enabled: true

    anchors {
        left: true
        top: true
        right: true
        bottom: true
    }

    ListModel {
        id: notifModel

        ListElement {
            title: "Notification Title"
            body: "Some long form content"
            icon: ""
            btn1: "Open in App"
        }

        ListElement {
            title: "Another one"
            body: "This is dynamic now"
            icon: ""
            priority: 'critical'
        }

    }

    Region {
        id: myRegion

        item: customColumn
    }

    WallpaperImage {
    }

    Item {
        id: mask

        visible: false
        layer.enabled: true
        anchors.fill: parent

        ColumnLayout {
            id: customColumn

            spacing: 0
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: root.bottomOffset // 47 for normal, 66 for when audio visualizer is in effect

            RowLayout {
                spacing: 0
                Layout.alignment: Qt.AlignRight | Qt.AlignBottom

                Shape {
                    id: invertedShape

                    property int currentCorner: 3

                    opacity: root.animatedHeight > 20 ? 1 : 0
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
                    id: backdrop

                    topLeftRadius: 12
                    topRightRadius: 12
                    Layout.preferredWidth: root.animatedWidth > 20 ? root.animatedWidth + 12 : 0
                    Layout.preferredHeight: root.animatedHeight > 0 ? root.animatedHeight + 8 : 0
                }

                Shape {
                    property int currentCorner: 3

                    opacity: root.animatedHeight > 20 ? 1 : 0
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
                        angle: 2 * -90
                    }

                }

            }

        }

    }

    ColumnLayout {
        id: customColumn1

        spacing: 0
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: root.bottomOffset + 2 // 49 for normal, 68 for when audio visualizer is in effect

        RowLayout {
            spacing: 0
            Layout.alignment: Qt.AlignRight | Qt.AlignBottom

            Rectangle {
                id: bg

                radius: 12
                color: "#ee1a1b26"
                clip: true
                Layout.preferredWidth: root.animatedWidth
                Layout.preferredHeight: root.animatedHeight

                Rectangle {
                    id: lkj

                    anchors.fill: parent
                    width: root.animatedWidth
                    color: "transparent"
                    radius: 12

                    // Elements go here
                    ColumnLayout {
                        id: mainSizeDecider

                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 6

                        Loader {
                            sourceComponent: root.customContent
                        }

                    }

                }

            }

        }

    }

    Behavior on animatedHeight {
        NumberAnimation {
            duration: 220
            easing.type: Easing.OutCubic
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
