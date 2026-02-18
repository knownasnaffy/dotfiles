import QtQuick

Image {
    source: "file:///home/barinr/Downloads/w11.jpg"
    fillMode: Image.PreserveAspectCrop
    asynchronous: true
    retainWhileLoading: true
    anchors.fill: parent
}
