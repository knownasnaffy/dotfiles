import Qt.labs.platform
import QtQuick
pragma Singleton

QtObject {
    property string configPath: StandardPaths.writableLocation(StandardPaths.AppDataLocation) + "/wallpaper-config.json"
    property string activeWallpaper: "BG2"
    property var wallpapers: ["BG1", "BG2", "BG3", "BG4"]

    function loadConfig() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "file://" + configPath);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                var config = JSON.parse(xhr.responseText);
                activeWallpaper = config.activeWallpaper;
            }
        };
        xhr.send();
    }

    function setWallpaper(id) {
        activeWallpaper = id;
        var config = JSON.stringify({
            "activeWallpaper": id
        }, null, 2);
        var xhr = new XMLHttpRequest();
        xhr.open("PUT", "file://" + configPath);
        xhr.send(config);
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
}
