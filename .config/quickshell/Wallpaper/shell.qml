import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import "root:/Wallpaper" as WP
import "root:/Wallpaper/AudioVisualizer" as AV

PanelWindow {
    aboveWindows: false
    focusable: true
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
    }

}
