import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Button {
    id: root

    property real prefferedSize: 0
    property real prefferedIconSize: 56
    property real variableOpacity: 1
    required property string iconString
    required property string helpString
    required property string bgColor
    required property string fgColor
    property real helpTextOpacity: 0

    function onHelpToggle() {
        helpTextOpacity = helpTextOpacity === 0 ? 0.8 : 0;
    }

    Layout.preferredWidth: prefferedSize
    Layout.preferredHeight: prefferedSize
    Component.onCompleted: {
        prefferedSize = 150;
    }
    onPressed: {
        prefferedSize = 146;
        variableOpacity = 0.9;
        prefferedIconSize = 55;
    }
    onReleased: {
        prefferedSize = 150;
        variableOpacity = 1;
        prefferedIconSize = 56;
    }

    Behavior on helpTextOpacity {
        NumberAnimation {
            duration: 120
            easing.type: Easing.OutCubic
        }

    }

    Behavior on prefferedSize {
        NumberAnimation {
            duration: 120
            easing.type: Easing.OutCubic
        }

    }

    Behavior on prefferedIconSize {
        NumberAnimation {
            duration: 120
            easing.type: Easing.OutCubic
        }

    }

    Behavior on variableOpacity {
        NumberAnimation {
            duration: 120
            easing.type: Easing.OutCubic
        }

    }

    background: Rectangle {
        radius: 36
        color: root.bgColor
        opacity: root.variableOpacity

        Text {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: root.helpTextOpacity * -8
            text: root.iconString
            font.pixelSize: root.prefferedIconSize
            font.family: "JetBrainsMono Nerd Font Mono"
            color: root.fgColor
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 12
            text: root.helpString
            font.pixelSize: root.prefferedIconSize - 32
            font.family: "JetBrainsMono Nerd Font Mono"
            color: root.fgColor
            opacity: root.helpTextOpacity
            scale: root.helpTextOpacity
        }

    }

}
