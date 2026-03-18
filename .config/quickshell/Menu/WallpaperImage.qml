import QtQuick

Image {
    source: "file:///home/barinr/Pictures/Wallpapers/bg37.jpg"
    // opacity: 0.2
    fillMode: Image.PreserveAspectCrop
    cache: true
    asynchronous: true
    retainWhileLoading: true
    anchors.fill: parent
}
