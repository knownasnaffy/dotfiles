import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    property var wallpapers: []

    function getWallpaperById(id) {
        for (var i = 0; i < wallpapers.length; i++) {
            if (wallpapers[i].id === id)
                return wallpapers[i];

        }
        return null;
    }

    Component.onCompleted: {
        var data = JSON.parse(configFile.text());
        wallpapers = data.wallpapers;
    }

    FileView {
        id: configFile

        path: Qt.resolvedUrl("config.json")
        blockLoading: true
    }

}
