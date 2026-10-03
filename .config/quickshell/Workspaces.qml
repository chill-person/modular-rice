import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Rectangle {
    implicitWidth: row.implicitWidth + 22
    implicitHeight: 33
    radius: height / 2
    color: '#90000000'

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 8

        Repeater {
            model: Hyprland.workspaces

            Rectangle {
                id: dot
                
                implicitWidth: (modelData.active ? 11 : 6) + (dotMouseArea.containsMouse ? 4 : 0)
                implicitHeight: (modelData.active ? 11 : 6) + (dotMouseArea.containsMouse ? 4 : 0)
                
                radius: width / 2
                color: modelData.active ? "transparent" : "#47b0b7"
                border.width: modelData.active ? 2 : 0
                border.color: "#47b0b7"

                Behavior on implicitWidth {
                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                }
                Behavior on implicitHeight {
                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                }

                MouseArea {
                    id: dotMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    // Fixed for Hyprland 0.55+ Lua IPC engine
                    onClicked: {
                        if (modelData && modelData.name) {
                            Hyprland.dispatch(`hl.dsp.focus({ workspace = "${modelData.name}" })`);
                        }
                    }
                }
            }
        }
    }
}
