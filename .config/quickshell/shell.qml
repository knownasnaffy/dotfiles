import QtQuick
import Quickshell
import qs.OSD
import qs.Wallpaper

ShellRoot {
    Wallpaper {
        id: wallpaper
    }

    OSD {
        bottomOffset: wallpaper.visualizerEnabled ? 66 : 47
    }

}
