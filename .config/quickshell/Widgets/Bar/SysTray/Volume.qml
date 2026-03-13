import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import Quickshell.Io

ColumnLayout {
    id: root
	property bool shouldShowOsd: false

    Layout.alignment: Qt.AlignHCenter
    spacing: 12

	PwObjectTracker {
		objects: [ Pipewire.defaultAudioSink ]
	}

	Connections {
		target: Pipewire.defaultAudioSink?.audio

		function onVolumeChanged() {
			root.shouldShowOsd = true;
            feedbackSoundProc.running = true
			hideTimer.restart();
		}

        function onMutedChanged() {
			root.shouldShowOsd = true;
            speakerVolumeIconTranslate.y = -3
            muteScaleTimer.restart()
			hideTimer.restart();
        }
	}

    Process {
        id: feedbackSoundProc
        running: false
        command: ["sh", "-c", "pw-play ~/Music/audio-volume-change.wav"]
    }

	Timer {
		id: hideTimer
		interval: 1000
		onTriggered: root.shouldShowOsd = false
	}

	Timer {
		id: muteScaleTimer
		interval: 100
		onTriggered: speakerVolumeIconTranslate.y = 0
	}

    Text {
        Layout.alignment: Qt.AlignHCenter
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 17
        text: ""
        color: "#565f89"

        transform: Translate {
            x: 1.5
        }
    }

    Rectangle {
        id: speakerVolumeTextRect

        Layout.alignment: Qt.AlignHCenter
        Layout.preferredHeight: root.shouldShowOsd ? speakerVolumeText.implicitHeight : 0
        Layout.preferredWidth: speakerVolumeText.implicitWidth
        color: "transparent"
        clip: true

        Text {
            property int speakerVolume: Math.round(Pipewire.defaultAudioSink?.audio.volume * 100)

            id: speakerVolumeText
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: speakerVolume > 99 ? 11 : 15
            text: speakerVolume
            color: Pipewire.defaultAudioSink?.audio.muted == true ? "#565f89" : speakerVolume == 0 ?"#565f89": speakerVolume < 20 ? "#f7768e" : speakerVolume < 40 ? "#e0af68" : speakerVolume < 70 ? "#9ece6a" : speakerVolume < 100 ? "#7aa2f7" : "#bb9af7"

            transform: Translate {
                x: 1
            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }

            Behavior on speakerVolume {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on font.pixelSize {
                NumberAnimation {
                    duration: 100
                    easing.type: Easing.Linear
                }
            }
        }

        Behavior on Layout.preferredHeight {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

    }

    Text {
        id: speakerVolumeIcon

        property int speakerVolume: Math.round(Pipewire.defaultAudioSink?.audio.volume * 100)

        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: root.shouldShowOsd ? -2 : -10
        Layout.bottomMargin: 10
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 15
        text: speakerVolume > 40 ? "" : speakerVolume > 0 ?  "" : ""
        color: Pipewire.defaultAudioSink?.audio.muted == true ? "#565f89" : speakerVolume == 0 ?"#565f89": speakerVolume < 20 ? "#f7768e" : speakerVolume < 40 ? "#e0af68" : speakerVolume < 70 ? "#9ece6a" : speakerVolume < 100 ? "#7aa2f7" : "#bb9af7"

        transform: Translate {
            x: 1
            id: speakerVolumeIconTranslate

            Behavior on y {
                NumberAnimation {
                    duration: 100
                    easing.type: Easing.Linear
                }
            }

        }

        Behavior on font.pixelSize {
            NumberAnimation {
                duration: 100
                easing.type: Easing.Linear
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 250
            }
        }

    }

}
