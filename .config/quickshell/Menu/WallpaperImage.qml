import QtQuick
import Quickshell

Image {
    source: "file:///home/barinr/Pictures/Wallpapers/bg37.jpg"
    // opacity: 0.2
    fillMode: Image.PreserveAspectCrop
    sourceSize.width: QsWindow.window?.width
    sourceSize.height: QsWindow.window?.height

    width: QsWindow.window?.screen.width
    height: QsWindow.window?.screen.height
    cache: true
    asynchronous: true
    retainWhileLoading: true
    anchors.fill: parent
}
