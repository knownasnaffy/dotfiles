pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
    id: root

    property bool panelVisible: false
    property bool indicatorVisible: false
    property bool expanding: false
    property real cornerSize: 16

    function closePanel() {
        root.indicatorVisible = false;
        root.expanding = false;
        hideTimer.running = true;
        sirenProc.running = false;
    }

    function openPanel() {
        root.expanding = true;
        mainPanel.visible = true;
        showTimer.running = true;
        indicatorShowTimer.running = true;
        sirenProc.running = true;
    }

    IpcHandler {
        function toggle(): void {
            if (root.panelVisible) {
                root.closePanel();
            } else {
                root.openPanel();
            }
        }

        function close(): void {
            if (root.panelVisible) {
                root.closePanel();
            }
        }

        function open(): void {
            if (!root.panelVisible) {
                root.openPanel();
            }
        }

        target: "battery"
    }

    Timer {
        id: hideTimer
        interval: 200
        running: false
        repeat: false
        onTriggered: {
            root.panelVisible = false;
            hideTimer2.running = true;
        }
    }

    Timer {
        id: hideTimer2
        interval: 500
        running: false
        repeat: false
        onTriggered: {
            mainPanel.visible = false;
        }
    }

    Timer {
        id: showTimer
        interval: 50
        running: false
        repeat: false
        onTriggered: {
            root.panelVisible = true;
        }
    }

    Timer {
        id: indicatorShowTimer
        interval: 600
        running: false
        repeat: false
        onTriggered: {
            root.indicatorVisible = true;
        }
    }

    PanelWindow {
        id: mainPanel

        visible: false
        color: "transparent"
        aboveWindows: true
        focusable: true

        anchors {
            left: true
            top: true
            right: true
            bottom: true
        }

        Rectangle {
            color: 'transparent'
            anchors.fill: parent
            focus: true

            Keys.onPressed: event => {
                // close
                if (event.key === Qt.Key_Escape || event.key === Qt.Key_Q) {
                    root.closePanel();
                }
                if (event.key === Qt.Key_M) {
                    sirenProc.running = !sirenProc.running;
                }
            }

            Rectangle {
                width: parent.width
                height: root.panelVisible ? parent.height / 2 : 0
                color: "#aaFF6F62"

                anchors {
                    bottom: parent.bottom
                    left: parent.left
                }

                Rectangle {
                    anchors {
                        bottom: parent.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                    color: "transparent"
                    height: parent.height / 6
                    width: parent.width

                    Rectangle {
                        visible: false
                        anchors.bottom: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width
                        height: 12
                        color: "#FF6F62"
                    }

                    Item {
                        id: stripCont2
                        anchors.fill: parent
                        clip: true

                        property int stripeWidth: 20
                        property int gap: 40

                        Repeater {
                            model: Math.ceil(parent.width / (stripCont2.stripeWidth + stripCont2.gap)) + 40

                            Rectangle {
                                id: strip2
                                required property int index

                                width: stripCont2.stripeWidth
                                height: parent.height * 3
                                color: "#FF6F62"
                                rotation: 30

                                x: index * (stripCont2.stripeWidth + stripCont2.gap) - parent.width
                                y: -parent.height

                                SequentialAnimation on x {
                                    loops: Animation.Infinite
                                    NumberAnimation {
                                        from: strip2.index * (stripCont2.stripeWidth + stripCont2.gap)
                                        to: strip2.index * (stripCont2.stripeWidth + stripCont2.gap) - stripCont2.width
                                        duration: 5000
                                        easing.type: Easing.Linear
                                    }
                                }
                            }
                        }
                    }
                }

                Behavior on height {
                    NumberAnimation {
                        duration: 500
                        easing.type: root.expanding ? Easing.OutBounce : Easing.OutCubic
                    }
                }
            }
            Rectangle {
                width: parent.width
                height: root.panelVisible ? parent.height / 2 : 0
                color: "#aaFF6F62"

                anchors {
                    top: parent.top
                    left: parent.left
                }

                Rectangle {
                    anchors {
                        top: parent.top
                        horizontalCenter: parent.horizontalCenter
                    }
                    color: "transparent"
                    height: parent.height / 6
                    width: parent.width

                    Rectangle {
                        visible: false
                        anchors.top: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width
                        height: 12
                        color: "#FF6F62"
                    }

                    Item {
                        id: stripCont1
                        anchors.fill: parent
                        clip: true

                        property int stripeWidth: 20
                        property int gap: 40

                        Repeater {
                            model: Math.ceil(parent.width / (stripCont1.stripeWidth + stripCont1.gap)) + 40

                            Rectangle {
                                id: strip1
                                required property int index

                                width: stripCont1.stripeWidth
                                height: parent.height * 3
                                color: "#FF6F62"
                                rotation: 30

                                x: index * (stripCont1.stripeWidth + stripCont1.gap) - parent.width
                                y: -parent.height

                                SequentialAnimation on x {
                                    loops: Animation.Infinite
                                    NumberAnimation {
                                        from: strip1.index * (stripCont1.stripeWidth + stripCont1.gap) - stripCont1.width
                                        to: strip1.index * (stripCont1.stripeWidth + stripCont1.gap)
                                        duration: 5000
                                        easing.type: Easing.Linear
                                    }
                                }
                            }
                        }
                    }
                }

                Behavior on height {
                    NumberAnimation {
                        duration: 500
                        easing.type: root.expanding ? Easing.OutBounce : Easing.OutCubic
                    }
                }
            }

            Text {
                id: indicator
                property bool itemVisible: false

                anchors.centerIn: parent
                text: "󱃍"
                font.pixelSize: 256
                font.family: 'JetBrainsMono Nerd Font'
                color: '#FF6F62'
                opacity: root.indicatorVisible ? itemVisible ? 1 : 0 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }
            }

            Process {
                id: sirenProc
                command: ["mpv", "--loop", "inf", "/home/barinr/Downloads/fronbondi_skegs-sfx-australian-fire-services-vehicle-siren-seamless-loop-480174.mp3"]
            }

            Timer {
                interval: 700
                running: true
                repeat: true
                onTriggered: {
                    indicator.itemVisible = !indicator.itemVisible;
                }
            }
        }
    }
}
