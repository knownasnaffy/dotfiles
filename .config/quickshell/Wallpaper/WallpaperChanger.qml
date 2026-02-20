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
    property int centerIndex: 0

    function updateVisibleWallpapers() {
        var all = Config.wallpapers;
        var visible = [];
        for (var j = -4; j <= 4; j++) {
            var pos = (root.centerIndex + j + all.length) % all.length;
            visible.push(all[pos]);
        }
        root.visibleWallpapers = visible;
    }

    function scrollNext() {
        root.centerIndex = (root.centerIndex + 1) % Config.wallpapers.length;
        root.updateVisibleWallpapers();
        switchTimer.restart();
    }

    function scrollPrevious() {
        root.centerIndex = (root.centerIndex - 1 + Config.wallpapers.length) % Config.wallpapers.length;
        root.updateVisibleWallpapers();
        switchTimer.restart();
    }

    function applyCenterWallpaper() {
        WallpaperConfig.setWallpaper(Config.wallpapers[root.centerIndex].id);
    }

    Timer {
        id: switchTimer
        interval: 500
        onTriggered: {
            root.applyCenterWallpaper();
        }
    }

    Connections {
        target: WallpaperConfig
        function onActiveWallpaperChanged() {
            var all = Config.wallpapers;
            for (var i = 0; i < all.length; i++) {
                if (all[i].id === WallpaperConfig.activeWallpaper) {
                    root.centerIndex = i;
                    break;
                }
            }
            root.updateVisibleWallpapers();
        }
    }

    Component.onCompleted: {
        var all = Config.wallpapers;
        for (var i = 0; i < all.length; i++) {
            if (all[i].id === WallpaperConfig.activeWallpaper) {
                root.centerIndex = i;
                break;
            }
        }
        root.updateVisibleWallpapers();
    }

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
                    root.scrollPrevious();
                }

                if (event.key === Qt.Key_Semicolon) {
                    root.scrollNext();
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
                color: "#aa1b1e2d"
                radius: 16
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 16

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.scrollPrevious()
                }
            }
            Rectangle {
                width: 40
                height: 40
                color: "#aa1b1e2d"
                radius: 16
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 16

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.scrollNext()
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
