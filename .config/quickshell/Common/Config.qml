import Qt.labs.platform
import QtQuick
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    property var wallpapers: []
    property bool loaded: false

    function getWallpaperById(id) {
        for (var i = 0; i < wallpapers.length; i++) {
            if (wallpapers[i].id === id) {
                return wallpapers[i];
            }
        }
        return null;
    }

    Component.onCompleted: {
        var configPath = Qt.resolvedUrl("config.json");
        var xhr = new XMLHttpRequest();
        xhr.open("GET", configPath, false);
        xhr.send();
        
        if (xhr.status === 200) {
            var data = JSON.parse(xhr.responseText);
            wallpapers = data.wallpapers;
            loaded = true;
        }
    }
}
