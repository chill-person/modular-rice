import QtQuick

// Small reusable slider matching the lamp panel's rounded, orange-accent look.
Item {
    id: root

    property real from: 0
    property real to: 100
    property real value: 0
    signal moved(real value)

    implicitHeight: 18

    readonly property real ratio: root.to > root.from
        ? Math.max(0, Math.min(1, (root.value - root.from) / (root.to - root.from)))
        : 0

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 6
        radius: height / 2
        color: "#50453a"
    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: track.width * root.ratio
        height: 6
        radius: height / 2
        color: "#fbb974"
    }

    Rectangle {
        id: handle
        width: 16
        height: 16
        radius: 8
        color: "#eee0d5"
        anchors.verticalCenter: parent.verticalCenter
        x: (track.width - width) * root.ratio

        Behavior on x {
            enabled: !dragArea.drag.active
            NumberAnimation { duration: 80 }
        }
    }

    MouseArea {
        id: dragArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        function setFromX(mx) {
            const r = Math.max(0, Math.min(1, mx / root.width))
            root.moved(root.from + r * (root.to - root.from))
        }

        onPressed: mouse => setFromX(mouse.x)
        onPositionChanged: mouse => { if (pressed) setFromX(mouse.x) }
    }
}
