import Qt.labs.platform
import QtQuick

Item {
    id: root
    
    property string imagePath: ""
    
    anchors.fill: parent
    
    Image {
        anchors.fill: parent
        source: {
            if (root.imagePath.startsWith("~/")) {
                return StandardPaths.writableLocation(StandardPaths.HomeLocation) + root.imagePath.substring(1);
            }
            return root.imagePath;
        }
        fillMode: Image.PreserveAspectCrop
    }
}
