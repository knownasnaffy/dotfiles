import Qt.labs.platform
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Common
import qs.Wallpaper

ShellRoot {
    id: root
    property bool panelVisible: false
    property var visibleWallpapers: []
    property string pendingWallpaper: ""

    function updateVisibleWallpapers() {
        var all = Config.wallpapers;
        var idx = -1;
        for (var i = 0; i < all.length; i++) {
            if (all[i].id === WallpaperConfig.activeWallpaper) {
                idx = i;
                break;
            }
        }

        var visible = [];
        for (var j = -4; j <= 4; j++) {
            var pos = (idx + j + all.length) % all.length;
            visible.push(all[pos]);
        }
        visibleWallpapers = visible;
    }

    function navigateTo(wallpaperId) {
        pendingWallpaper = wallpaperId;
        updateVisibleWallpapers();
        switchTimer.restart();
    }

    Timer {
        id: switchTimer
        interval: 500
        onTriggered: {
            if (pendingWallpaper !== "") {
                WallpaperConfig.setWallpaper(pendingWallpaper);
            }
        }
    }

    Connections {
        target: WallpaperConfig
        function onActiveWallpaperChanged() {
            updateVisibleWallpapers();
        }
    }

    Component.onCompleted: updateVisibleWallpapers()

    IpcHandler {
        target: "wallpaper-changer"

        function toggle(): void {
            root.panelVisible = !root.panelVisible;
        }
    }

    PanelWindow {
        visible: root.panelVisible
        implicitWidth: 600
        implicitHeight: 300
        color: "transparent"
        focusable: true
        WlrLayershell.namespace: "powermenu"

        Rectangle {
            anchors.fill: parent
            color: "#aa1b1e2d"
            radius: 12

            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Escape || event.key === Qt.Key_Q) {
                    root.panelVisible = false
                }

                if (event.key === Qt.Key_J) {
                    var idx = -1;
                    for (var i = 0; i < Config.wallpapers.length; i++) {
                        if (Config.wallpapers[i].id === WallpaperConfig.activeWallpaper) {
                            idx = i;
                            break;
                        }
                    }
                    var prevIdx = (idx - 1 + Config.wallpapers.length) % Config.wallpapers.length;
                    navigateTo(Config.wallpapers[prevIdx].id);
                }

                if (event.key === Qt.Key_Semicolon) {
                    var idx = -1;
                    for (var i = 0; i < Config.wallpapers.length; i++) {
                        if (Config.wallpapers[i].id === WallpaperConfig.activeWallpaper) {
                            idx = i;
                            break;
                        }
                    }
                    var nextIdx = (idx + 1) % Config.wallpapers.length;
                    navigateTo(Config.wallpapers[nextIdx].id);
                }

                if (event.key === Qt.Key_R) {
                    WallpaperConfig.random()
                }
            }

            focus: true

            RowLayout {
                anchors.centerIn: parent
                spacing: 20

                Repeater {
                    model: root.visibleWallpapers

                    Rectangle {
                        width: index === 4 ? 350 : 300
                        height: width * 9 / 16
                        color: "#1b1e2d"
                        radius: 8
                        clip: true
                        Layout.alignment: Qt.AlignVCenter

                        Loader {
                            anchors.fill: parent
                            sourceComponent: {
                                if (modelData.type === "image") return imageComp;
                                if (modelData.type === "video") return videoComp;
                                if (modelData.type === "dynamic") return previewComp;
                                return null;
                            }
                            property var wallpaperData: modelData
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                switchTimer.stop();
                                WallpaperConfig.setWallpaper(modelData.id);
                            }
                        }
                    }
                }
            }

            Rectangle {
                width: 40
                height: 40
                color: "#565f89"
                radius: 16
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 16

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        var idx = -1;
                        for (var i = 0; i < Config.wallpapers.length; i++) {
                            if (Config.wallpapers[i].id === WallpaperConfig.activeWallpaper) {
                                idx = i;
                                break;
                            }
                        }
                        var prevIdx = (idx - 1 + Config.wallpapers.length) % Config.wallpapers.length;
                        navigateTo(Config.wallpapers[prevIdx].id);
                    }
                }
            }
            Rectangle {
                width: 40
                height: 40
                color: "#565f89"
                radius: 16
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 16

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        var idx = -1;
                        for (var i = 0; i < Config.wallpapers.length; i++) {
                            if (Config.wallpapers[i].id === WallpaperConfig.activeWallpaper) {
                                idx = i;
                                break;
                            }
                        }
                        var nextIdx = (idx + 1) % Config.wallpapers.length;
                        navigateTo(Config.wallpapers[nextIdx].id);
                    }
                }
            }
        }
    }

    Component {
        id: imageComp
        Image {
            source: {
                var path = wallpaperData.path;
                if (path.startsWith("~/")) {
                    return StandardPaths.writableLocation(StandardPaths.HomeLocation) + path.substring(1);
                }
                return path;
            }
            fillMode: Image.PreserveAspectCrop
        }
    }

    Component {
        id: videoComp
        Image {
            source: {
                var path = wallpaperData.path;
                if (path.startsWith("~/")) {
                    return StandardPaths.writableLocation(StandardPaths.HomeLocation) + path.substring(1);
                }
                return path;
            }
            fillMode: Image.PreserveAspectCrop
        }
    }

    Component {
        id: previewComp
        Image {
            source: {
                var path = wallpaperData.preview;
                if (path.startsWith("~/")) {
                    return StandardPaths.writableLocation(StandardPaths.HomeLocation) + path.substring(1);
                }
                return path;
            }
            fillMode: Image.PreserveAspectCrop
        }
    }
}
