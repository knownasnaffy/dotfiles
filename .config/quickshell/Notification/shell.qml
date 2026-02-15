pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets

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
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.bottomMargin: 66 // 47 for normal, 66 for when audio visualizer is in effect

            Shape {
                property int currentCorner: 3

                opacity: root.animatedWidth > 20 ? 1 : 0
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

                    opacity: root.animatedWidth > 20 ? 1 : 0
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
        anchors.bottomMargin: 68 // 49 for normal, 68 for when audio visualizer is in effect

        RowLayout {
            spacing: 0
            Layout.alignment: Qt.AlignRight | Qt.AlignBottom

            Rectangle {
                id: bg

                property real animatedHeight: 0

                radius: 12
                color: "#ee1b1e2d"
                clip: true
                Layout.preferredWidth: root.animatedWidth
                Layout.preferredHeight: animatedHeight
                Component.onCompleted: {
                    fgStartupTimer.running = true;
                }

                MultiEffect {
                    anchors.fill: bg
                    source: bg
                    blurEnabled: true
                    blur: 0.6 // strength (0–1)
                    blurMax: 12 // radius
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

                ListView {
                    id: containerLayout

                    model: notifModel
                    interactive: false
                    clip: true
                    spacing: 12
                    // CRITICAL: make ListView size itself like a layout
                    implicitHeight: contentHeight
                    implicitWidth: bg.width

                    header: Item {
                        height: 12
                    }

                    footer: Item {
                        height: 12
                    }

                    delegate: Rectangle {
                        id: currentNotif

                        required property string title
                        required property string icon
                        required property string body
                        required property string btn1
                        required property string priority
                        property real animatedWidth: root.animatedWidth

                        color: "#16161e"
                        radius: 8
                        width: animatedWidth - 24
                        height: notifRow.implicitHeight
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.margins: 12

                        RowLayout {
                            // width: parent.width

                            id: notifRow

                            spacing: 0

                            Rectangle {
                                color: "#24283b"
                                radius: 30
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                Layout.margins: 12
                                Layout.alignment: Qt.AlignTop
                                Layout.maximumWidth: 40
                                Layout.maximumHeight: 40

                                Text {
                                    text: currentNotif.icon
                                    font.pixelSize: 32
                                    font.family: "JetBrainsMono Nerd Font Mono"
                                    color: currentNotif.priority === "critical"?"#f7768e": "#a9b1d6"
                                    anchors.centerIn: parent
                                }

                            }

                            ColumnLayout {
                                spacing: 2
                                Layout.alignment: Qt.AlignLeft
                                Layout.topMargin: 12
                                Layout.bottomMargin: 12

                                RowLayout {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignLeft

                                    Text {
                                        text: currentNotif.title
                                        color: "#a9b1d6"
                                        font.pixelSize: 14
                                        font.weight: Font.Medium
                                        font.family: "Inter"
                                        elide: Text.ElideRight
                                    }

                                    RowLayout {
                                        spacing: 4
                                        Layout.alignment: Qt.AlignRight

                                        Text {
                                            text: "now"
                                            color: currentNotif.priority === "critical"?"#f7768e":"#565f89"
                                            font.pixelSize: 10
                                            font.weight: Font.Medium
                                            font.family: "Inter"
                                        }
                                    }

                                }

                                Text {
                                    text: currentNotif.body
                                    color: "#565f89"
                                    font.pixelSize: 12
                                    font.weight: Font.Medium
                                    font.family: "Inter"
                                    wrapMode: Text.WordWrap
                                }

                                RowLayout {
                                    id: buttonRow

                                    spacing: 8
                                    visible: currentNotif.btn1 ? true : false

                                    Button {
                                        rightPadding: 12
                                        leftPadding: 12
                                        bottomPadding: 6
                                        topPadding: 10
                                        topInset: 4

                                        contentItem: Label {
                                            text: currentNotif.btn1
                                            font.pixelSize: 10
                                            font.family: "Inter"
                                            color: "#c9d1e0"
                                        }

                                        background: Rectangle {
                                            radius: 8
                                            color: "#24283b"
                                        }

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
        // Qt.quit();

        id: quitTimer

        interval: 220
        repeat: false
        running: false
        onTriggered: {
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
