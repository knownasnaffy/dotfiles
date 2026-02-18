import QtQuick
import Quickshell
import qs.Common.Drawer
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

    CenterCaller {
        bottomOffset: wallpaper.visualizerEnabled ? 66 : 47
    }

}
