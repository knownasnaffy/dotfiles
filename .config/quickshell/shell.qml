import QtQuick
import Quickshell
import qs.Menu
import qs.OSD
import qs.Wallpaper

ShellRoot {
    Wallpaper {
        id: wallpaper
    }

    OSD {
        bottomOffset: wallpaper.visualizerEnabled ? 66 : 47
    }

    Menu {
    }

}
