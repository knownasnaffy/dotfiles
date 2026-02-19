import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.Wallpaper
import qs.Wallpaper.AudioVisualizer

PanelWindow {
    property bool visualizerEnabled: audioVisualizer.visualizerEnabled

    aboveWindows: false
    focusable: false
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "Nox:wallpaper"
    WlrLayershell.layer: WlrLayer.Background

    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    IpcHandler {
        target: "wallpaper"

        function next(): void {
            WallpaperConfig.next();
        }

        function previous(): void {
            WallpaperConfig.previous();
        }

        function random(): void {
            WallpaperConfig.random();
        }
    }

    Item {
        anchors.fill: parent

        Loader {
            id: loader1
            anchors.fill: parent
            opacity: 1
            Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } }
        }

        Loader {
            id: loader2
            anchors.fill: parent
            opacity: 0
            Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } }
        }

        property bool useLoader1: true
        property string currentWallpaper: WallpaperConfig.activeWallpaper

        Timer {
            id: fadeTimer
            interval: 50
            property var targetLoader
            onTriggered: targetLoader.opacity = 1
        }

        onCurrentWallpaperChanged: {
            if (useLoader1) {
                loader2.opacity = 0;
                loader2.source = "Backgrounds/" + currentWallpaper + ".qml";
                fadeTimer.targetLoader = loader2;
                fadeTimer.start();
                loader1.opacity = 0;
            } else {
                loader1.opacity = 0;
                loader1.source = "Backgrounds/" + currentWallpaper + ".qml";
                fadeTimer.targetLoader = loader1;
                fadeTimer.start();
                loader2.opacity = 0;
            }
            useLoader1 = !useLoader1;
        }

        Component.onCompleted: {
            loader1.source = "Backgrounds/" + currentWallpaper + ".qml";
            loader1.opacity = 1;
            loader2.opacity = 0;
        }
    }

    AudioVisualizer {
        id: audioVisualizer
    }

}
