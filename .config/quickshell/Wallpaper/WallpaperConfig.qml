import Qt.labs.platform
import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    property string configPath: StandardPaths.writableLocation(StandardPaths.AppDataLocation) + "/wallpaper-config.json"
    property var wallpapers: ["BG1", "BG2", "BG3", "BG4", "BG5", "BG6", "BG7", "BG8", "BG9", "BG10", "BG11"]
    property string activeWallpaper: "BG2"

    function loadConfig() {
        var jsonData = JSON.parse(jsonFile.text());
        activeWallpaper = jsonData.activeWallpaper;
    }

    function setWallpaper(id) {
        activeWallpaper = id;
        var config = JSON.stringify({
            "activeWallpaper": id
        }, null, 2);
        jsonFile.setText(config);
    }

    function next() {
        var idx = wallpapers.indexOf(activeWallpaper);
        setWallpaper(wallpapers[(idx + 1) % wallpapers.length]);
    }

    function previous() {
        var idx = wallpapers.indexOf(activeWallpaper);
        setWallpaper(wallpapers[(idx - 1 + wallpapers.length) % wallpapers.length]);
    }

    function random() {
        var idx = Math.floor(Math.random() * wallpapers.length);
        setWallpaper(wallpapers[idx]);
    }

    Component.onCompleted: loadConfig()

    FileView {
        id: jsonFile

        path: Qt.resolvedUrl(Quickshell.env("XDG_DATA_HOME") + '/wallpaper-config.json')
        blockLoading: true
    }

}
