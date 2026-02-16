pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import qs.Common

PanelWindow {
    id: root

    property color mColor: "#505050"
    property int cornerHeight: 16
    property int cornerWidth: cornerHeight
    property real animatedWidth: 72

    required property real bottomOffset

    implicitWidth: 480
    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true
    mask: myRegion
    color: "transparent"
    contentItem.layer.enabled: true
    HyprlandWindow.visibleMask: myRegion

    	// Bind the pipewire node so its volume will be tracked
	PwObjectTracker {
		objects: [ Pipewire.defaultAudioSink ]
	}

	Connections {
		target: Pipewire.defaultAudioSink?.audio

		function onVolumeChanged() {
			root.shouldShowOsd = true;
			hideTimer.restart();
		}
	}

	property bool shouldShowOsd: false

	Timer {
		id: hideTimer
		interval: 1000
		onTriggered: root.shouldShowOsd = false
	}


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
            anchors.bottomMargin: root.bottomOffset // 47 for normal, 66 for when audio visualizer is in effect

            Shape {
                property int currentCorner: 3

                opacity: bg.animatedHeight > 20 ? 1 : 0
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

                    opacity: bg.animatedHeight > 20 ? 1 : 0
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
                    property real animatedHeight: root.shouldShowOsd ? 300 : 0

                    topLeftRadius: 12
                    Layout.preferredWidth: root.animatedWidth > 20 ? root.animatedWidth + 12 : 0
                    Layout.preferredHeight: animatedHeight > 0 ? animatedHeight + 10 : 0

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
        anchors.bottomMargin: root.bottomOffset + 2 // 49 for normal, 68 for when audio visualizer is in effect

        RowLayout {
            spacing: 0
            Layout.alignment: Qt.AlignRight | Qt.AlignBottom

            Rectangle {
                id: bg

                    property real animatedHeight: root.shouldShowOsd ? 300 : 0

                radius: 12
                color: "#ee1b1e2d"
                clip: true
                Layout.preferredWidth: root.animatedWidth
                Layout.preferredHeight: animatedHeight

                MultiEffect {
                    anchors.fill: bg
                    source: bg
                    blurEnabled: true
                    blur: 0.6 // strength (0–1)
                    blurMax: 12 // radius
                    opacity: 0.9
                }

                Rectangle {
		    anchors.fill: parent
		    height: 300
		    width: root.animatedWidth
		    color: "#1b1e2d"
		    radius: 12

		    ColumnLayout {
                id: contentLayout
			    spacing: 8
					anchors {
						fill: parent
						topMargin: 20
						bottomMargin: 16
					}


					Rectangle {
                        id: sliderParent
						// Stretches to fill all left-over space
						Layout.fillHeight: true
						Layout.alignment: Qt.AlignHCenter

						Layout.preferredWidth: 16
						radius: 20
						color: "#565f89"
                                bottomLeftRadius: 2
                                bottomRightRadius: 2

                            }
                            Rectangle {
                                id: thumb
                                Layout.preferredHeight: 4
                                Layout.preferredWidth: 40
                                color: "#7aa2f7"
                                radius: 4
                                Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                            }

                            Rectangle {
                                property real animatedHeight: (( contentLayout.height - (contentLayout.spacing * 3) - thumb.implicitHeight - contentLayout.anchors.topMargin - contentLayout.anchors.bottomMargin + 2 ) * Pipewire.defaultAudioSink?.audio.volume ) ?? 0
                                Layout.alignment: Qt.AlignHCenter

                                Behavior on animatedHeight {
                                    NumberAnimation {
                                    duration: 220
                                    easing.type: Easing.OutCubic
                                    }

                                }
                                color: "#7aa2f7"

						Layout.preferredWidth: 16
                                implicitHeight: animatedHeight
                                radius: sliderParent.radius
                                topLeftRadius: 2
                                topRightRadius: 2

					}
					Text {
						text: ""
						font.pixelSize: 16
						font.family: "JetBrains Mono Nerd Font Propo"
						color: "#c0caf5"

						Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                        Layout.topMargin: 8
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
