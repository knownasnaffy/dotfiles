import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import Quickshell.Io

ColumnLayout {
    id: root
	property bool shouldShowSpeakerOSD: false
	property bool shouldShowMicOSD: false

    Layout.alignment: Qt.AlignHCenter
    spacing: 12

	PwObjectTracker {
		objects: [ Pipewire.defaultAudioSink, Pipewire.defaultAudioSource ]
	}

	Connections {
		target: Pipewire.defaultAudioSink?.audio

		function onVolumeChanged() {
			root.shouldShowSpeakerOSD = true;
            feedbackSoundProc.running = true
			hideSpeakerLabelTimer.restart();
		}

        function onMutedChanged() {
			root.shouldShowSpeakerOSD = true;
            speakerVolumeIconTranslate.y = -3
            speakerMuteScaleTimer.restart()
			hideSpeakerLabelTimer.restart();
        }
	}

	Connections {
		target: Pipewire.defaultAudioSource?.audio

		function onVolumeChanged() {
			root.shouldShowMicOSD = true;
			hideMicLabelTimer.restart();
		}

        function onMutedChanged() {
			root.shouldShowMicOSD = true;
			hideMicLabelTimer.restart();
            micVolumeIconTranslate.y = -3
            micMuteScaleTimer.restart()
        }
	}

    Process {
        id: feedbackSoundProc
        running: false
        command: ["sh", "-c", "pw-play ~/Music/audio-volume-change.wav"]
    }

	Timer {
		id: hideSpeakerLabelTimer
		interval: 1000
		onTriggered: root.shouldShowSpeakerOSD = false
	}

	Timer {
		id: hideMicLabelTimer
		interval: 1000
		onTriggered: root.shouldShowMicOSD = false
	}

	Timer {
		id: speakerMuteScaleTimer
		interval: 100
		onTriggered: speakerVolumeIconTranslate.y = 0
	}

	Timer {
		id: micMuteScaleTimer
		interval: 100
		onTriggered: micVolumeIconTranslate.y = 0
	}

    Rectangle {
        id: micVolumeTextRect

        Layout.alignment: Qt.AlignHCenter
        Layout.preferredHeight: root.shouldShowMicOSD ? micVolumeText.implicitHeight : 0
        Layout.preferredWidth: micVolumeText.implicitWidth
        color: "transparent"
        clip: true

        Text {
            property int micVolume: Math.round(Pipewire.defaultAudioSource?.audio.volume * 100)

            id: micVolumeText
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: micVolume > 99 ? 11 : 15
            text: micVolume
            color: Pipewire.defaultAudioSource?.audio.muted == true ? "#565f89" : micVolume == 0 ?"#565f89": micVolume < 20 ? "#f7768e" : micVolume < 40 ? "#e0af68" : micVolume < 70 ? "#9ece6a" : "#7aa2f7"

            transform: Translate {
                x: 1
            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }

            Behavior on micVolume {
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
        property int micVolume: Math.round(Pipewire.defaultAudioSource?.audio.volume * 100)

        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: root.shouldShowMicOSD ? -2 : -10
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 17
        text: micVolume > 0 ?  "" : ""
        color: Pipewire.defaultAudioSource?.audio.muted == true ? "#565f89" : micVolume == 0 ?"#565f89": micVolume < 20 ? "#f7768e" : micVolume < 40 ? "#e0af68" : micVolume < 70 ? "#9ece6a" : "#7aa2f7"

        transform: Translate {
            x: 1
            id: micVolumeIconTranslate

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

    Rectangle {
        id: speakerVolumeTextRect

        Layout.alignment: Qt.AlignHCenter
        Layout.preferredHeight: root.shouldShowSpeakerOSD ? speakerVolumeText.implicitHeight : 0
        Layout.preferredWidth: speakerVolumeText.implicitWidth
        color: "transparent"
        clip: true

        Text {
            property int speakerVolume: Math.round(Pipewire.defaultAudioSink?.audio.volume * 100)

            id: speakerVolumeText
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: speakerVolume > 99 ? 11 : 15
            text: speakerVolume
            color: Pipewire.defaultAudioSink?.audio.muted == true ? "#565f89" : speakerVolume == 0 ?"#565f89": speakerVolume < 20 ? "#f7768e" : speakerVolume < 40 ? "#e0af68" : speakerVolume <= 70 ? "#9ece6a" : speakerVolume < 100 ? "#7aa2f7" : "#bb9af7"

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
        property int speakerVolume: Math.round(Pipewire.defaultAudioSink?.audio.volume * 100)

        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: root.shouldShowSpeakerOSD ? -2 : -10
        Layout.bottomMargin: 10
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 15
        text: speakerVolume > 40 ? "" : speakerVolume > 0 ?  "" : ""
        color: Pipewire.defaultAudioSink?.audio.muted == true ? "#565f89" : speakerVolume == 0 ?"#565f89": speakerVolume < 20 ? "#f7768e" : speakerVolume < 40 ? "#e0af68" : speakerVolume <= 70 ? "#9ece6a" : speakerVolume < 100 ? "#7aa2f7" : "#bb9af7"

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
