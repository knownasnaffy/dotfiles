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

    Loader {
        anchors.fill: parent
        source: "Backgrounds/" + WallpaperConfig.activeWallpaper + ".qml"
    }

    AudioVisualizer {
        id: audioVisualizer
    }

}
