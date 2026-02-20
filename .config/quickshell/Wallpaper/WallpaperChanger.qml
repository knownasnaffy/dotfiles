import Qt.labs.platform
import QtMultimedia
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Common
import qs.Wallpaper

ShellRoot {
    id: root
    property bool panelVisible: false
    property int centerIndex: 0

    ListModel {
        id: wallpaperModel
    }

    function updateVisibleWallpapers() {
        var all = Config.wallpapers;
        wallpaperModel.clear();
        for (var j = -4; j <= 4; j++) {
            var pos = (root.centerIndex + j + all.length) % all.length;
            wallpaperModel.append(all[pos]);
        }
    }

    function scrollNext() {
        var all = Config.wallpapers;
        root.centerIndex = (root.centerIndex + 1) % all.length;
        var newIdx = (root.centerIndex + 4) % all.length;
        wallpaperModel.remove(0);
        wallpaperModel.append(all[newIdx]);
        switchTimer.restart();
    }

    function scrollPrevious() {
        var all = Config.wallpapers;
        root.centerIndex = (root.centerIndex - 1 + all.length) % all.length;
        var newIdx = (root.centerIndex - 4 + all.length) % all.length;
        wallpaperModel.remove(8);
        wallpaperModel.insert(0, all[newIdx]);
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

                ListView {
                    orientation: ListView.Horizontal
                    model: wallpaperModel
                    spacing: 20
                    interactive: false
                    cacheBuffer: 1000
                    Layout.preferredWidth: 350 + 300 * 2 + 20 * 2
                    Layout.preferredHeight: 350 * 9 / 16

                    add: Transition {
                        NumberAnimation { properties: "x"; duration: 200; easing.type: Easing.OutCubic }
                    }

                    remove: Transition {
                        NumberAnimation { properties: "x"; duration: 200; easing.type: Easing.OutCubic }
                    }

                    displaced: Transition {
                        NumberAnimation { properties: "x"; duration: 200; easing.type: Easing.OutCubic }
                    }

                    delegate: Item {
                        width: index === 4 ? 350 : 300
                        height: width * 9 / 16
                        layer.enabled: true

                        Item {
                            id: maskItem
                            anchors.fill: parent
                            visible: false
                            layer.enabled: true

                            Rectangle {
                                anchors.fill: parent
                                radius: 8
                                color: "white"
                            }
                        }

                        Loader {
                            anchors.fill: parent
                            sourceComponent: {
                                if (model.type === "image") return imageComp;
                                if (model.type === "video") return videoComp;
                                if (model.type === "dynamic") return previewComp;
                                return null;
                            }
                            property var wallpaperData: model
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                switchTimer.stop();
                                WallpaperConfig.setWallpaper(model.id);
                            }
                        }

                        layer.effect: MultiEffect {
                            maskEnabled: true
                            maskSource: maskItem
                            maskSpreadAtMin: 1
                            maskThresholdMin: 0.5
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
        Item {
            anchors.fill: parent
            clip: true
            Image {
                anchors.fill: parent
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
    }

    Component {
        id: videoComp
        Item {
            anchors.fill: parent
            clip: true
            
            MediaPlayer {
                id: player
                source: {
                    var path = wallpaperData.path;
                    if (path.startsWith("~/")) {
                        return StandardPaths.writableLocation(StandardPaths.HomeLocation) + path.substring(1);
                    }
                    return path;
                }
                loops: MediaPlayer.Infinite
                autoPlay: true
                videoOutput: videoOutput
            }
            
            VideoOutput {
                id: videoOutput
                anchors.fill: parent
                fillMode: VideoOutput.PreserveAspectCrop
            }
        }
    }

    Component {
        id: previewComp
        Item {
            anchors.fill: parent
            clip: true
            Image {
                anchors.fill: parent
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
}
