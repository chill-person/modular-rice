import QtQuick
import QtQuick.Layouts
import Quickshell

Rectangle {
    id: root

    property string icon: ""
    property string label: ""
    property color iconColor: '#47b0b7'
    property int maxLabelWidth: 600
    property bool hovered: false 

    // Custom internal property to allow smooth fractional size calculations
    property real animSize: root.hovered ? 20.0 : 16.0

    implicitWidth: row.implicitWidth + 22
    implicitHeight: 33
    radius: height / 2
    color: '#90000000'
    clip: true 

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    // Animate our custom real number cleanly without rendering blur
    Behavior on animSize {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutQuad
        }
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 7

        Text {
            text: root.icon
            color: root.iconColor
            font.family: "Material Symbols Rounded"
            
            // This forces Qt to re-rasterize the vector font on the fly
            // resulting in perfect crisp lines instead of blurry texture scaling
            font.pixelSize: Math.round(root.animSize)
            
            // Crucial for subpixel sharpness during font shifts
            renderType: Text.QtRendering 

            // Explicitly force alignment boundaries to prevent micro-stuttering text boxes
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            id: labelText
            text: root.label
            color: "#e0e0e0"
            font.family: "Iosevka Nerd Font"
            font.pixelSize: 16
            elide: Text.ElideRight
            Layout.maximumWidth: root.maxLabelWidth
            visible: root.label !== ""

            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }
        }
    }
}
