import Qt.labs.platform
import QtQuick
pragma Singleton

QtObject {
    property string configPath: StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.config/quickshell/wallpaper-config.json"
    property string activeWallpaper: "BG2"

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

    Component.onCompleted: loadConfig()
}
