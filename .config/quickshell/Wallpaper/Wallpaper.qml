import QtQuick
import Quickshell
import Quickshell.Wayland
import "root:/Wallpaper" as WP
import "root:/Wallpaper/AudioVisualizer" as AV

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

    WP.Background {
    }

    AV.AudioVisualizer {
        id: audioVisualizer
    }

}
