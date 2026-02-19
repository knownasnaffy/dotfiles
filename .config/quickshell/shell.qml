import QtQuick
import Quickshell
import qs.Common.Drawer
import qs.Menu
import qs.OSD
import qs.PowerMenu
import qs.Wallpaper

ShellRoot {
    Wallpaper {
        id: wallpaper
    }

    WallpaperChanger {
    }

    OSD {
        bottomOffset: wallpaper.visualizerEnabled ? 66 : 47
    }

    Menu {
    }

    CenterCaller {
        bottomOffset: wallpaper.visualizerEnabled ? 66 : 47
    }

    PowerMenu {
    }

}
