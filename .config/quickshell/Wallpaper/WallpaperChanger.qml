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
        for (var i = 0; i < all.length; i++) {
            wallpaperModel.append(all[i]);
        }
    }

    function scrollNext() {
        wallpaperPathView.incrementCurrentIndex();
        switchTimer.restart();
    }

    function scrollPrevious() {
        wallpaperPathView.decrementCurrentIndex();
        switchTimer.restart();
    }

    function applyCenterWallpaper() {
        var idx = wallpaperPathView.currentIndex;
        WallpaperConfig.setWallpaper(Config.wallpapers[idx].id);
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
                    wallpaperPathView.currentIndex = i;
                    break;
                }
            }
        }
    }

    Component.onCompleted: {
        root.updateVisibleWallpapers();
        var all = Config.wallpapers;
        for (var i = 0; i < all.length; i++) {
            if (all[i].id === WallpaperConfig.activeWallpaper) {
                wallpaperPathView.currentIndex = i;
                break;
            }
        }
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
                spacing: 0

                PathView {
                    id: wallpaperPathView
                    model: wallpaperModel
                    interactive: false
                    pathItemCount: 9
                    preferredHighlightBegin: 0.5
                    preferredHighlightEnd: 0.5
                    offset: 0
                    Layout.preferredWidth: 600
                    Layout.preferredHeight: 350 * 9 / 16
                    Layout.alignment: Qt.AlignVCenter

                    path: Path {
                        startX: -1200
                        startY: wallpaperPathView.height / 2
                        PathLine {
                            x: 1800
                            y: wallpaperPathView.height / 2
                        }
                    }

                    delegate: Item {
                        id: delegateRoot
                        property bool isCurrent: PathView.isCurrentItem
                        width: isCurrent ? 350 : 300
                        height: 350 * 9 / 16
                        z: isCurrent ? 1 : 0

                        Item {
                            width: delegateRoot.isCurrent ? 350 : 300
                            height: width * 9 / 16
                            anchors.centerIn: parent

                            Behavior on width {
                                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                            }

                            Behavior on height {
                                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                            }

                            layer.enabled: true
                            layer.effect: MultiEffect {
                                maskEnabled: true
                                maskSource: maskItem
                                maskSpreadAtMin: 1
                                maskThresholdMin: 0.5
                            }

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
                                asynchronous: true
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

                Text {
                    anchors.centerIn: parent
                    text: ""
                    font.family: "JetBrains Mono Nerd Font Propo"
                    font.pixelSize: 20
                    color: "#c0caf5"
                }

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

                Text {
                    anchors.centerIn: parent
                    text: ""
                    font.family: "JetBrains Mono Nerd Font Propo"
                    font.pixelSize: 20
                    color: "#c0caf5"
                }

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
