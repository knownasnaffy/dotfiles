import QtQuick
import Quickshell
import qs.Common.Drawer
import qs.Menu
import qs.PowerMenu
// import qs.Services.Notifications
import qs.Wallpaper
import qs.Widgets.Bar

ShellRoot {
    // Component.onCompleted: {
    //     Notifications.dismiss(null);
    // }

    Wallpaper {
        id: wallpaper
    }

    WallpaperChanger {}

    Clipboard {}

    CenterCaller {
        bottomOffset: wallpaper.visualizerEnabled ? 66 : 47
    }

    PowerMenu {}

    Bar {}
}
