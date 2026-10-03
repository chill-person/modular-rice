import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

// Sci-fi date panel built from the same parts as your pills:
// capsule chips, Material Symbols icons, #90000000 glass, teal accent.
// Hover to peek. Click the clock to lock it open; click anywhere
// outside the panel to close it.
PopupWindow {
    id: root

    property var anchorItem: null
    property var anchorWindow: null
    property date date: new Date()

    // driven from shell.qml
    property bool hovered: false
    property bool pinned: false
    readonly property bool shown: hovered || pinned

    readonly property int gapsIn: 8

    // palette (matched to Pill.qml)
    readonly property color accent: "#47b0b7"
    readonly property color fg: "#e0e0e0"
    readonly property string mono: "Iosevka Nerd Font"
    readonly property string icons: "Material Symbols Rounded"

    visible: shown || content.opacity > 0.01
    width: 290
    height: content.implicitHeight
    color: "transparent"

    // ---- click-to-pin / click-outside-to-close ----
    property double lastCleared: 0

    function togglePin() {
        if (pinned) {
            pinned = false
        } else if (Date.now() - lastCleared > 350) {
            // the 350ms guard stops the same click that dismissed the grab
            // (when you click the clock while locked) from re-opening it
            pinned = true
        }
    }

    HyprlandFocusGrab {
        windows: [root]
        active: root.pinned
        onCleared: {
            root.pinned = false
            root.lastCleared = Date.now()
        }
    }

    // ---- positioning: centered under the anchor ----
    property real targetX: 0
    function recenter() {
        if (!anchorItem || !anchorWindow) return
        const p = anchorWindow.contentItem.mapFromItem(anchorItem, 0, 0)
        targetX = p.x + anchorItem.width / 2 - width / 2
    }
    onShownChanged: if (shown) recenter()
    Connections {
        target: root.anchorItem
        function onWidthChanged() { root.recenter() }
    }
    anchor {
        window: root.anchorWindow
        rect.x: root.targetX
        rect.y: (root.anchorWindow ? root.anchorWindow.height : 0) + root.gapsIn
    }

    // ---- date maths ----
    readonly property int year: date.getFullYear()
    readonly property int month: date.getMonth()
    readonly property int today: date.getDate()
    readonly property int daysInMonth: new Date(year, month + 1, 0).getDate()
    readonly property int offset: (new Date(year, month, 1).getDay() + 6) % 7   // Monday start
    readonly property int cells: Math.ceil((offset + daysInMonth) / 7) * 7
    readonly property bool leap: (year % 4 === 0 && year % 100 !== 0) || year % 400 === 0
    readonly property int daysInYear: leap ? 366 : 365
    readonly property int dayOfYear: Math.round((new Date(year, month, today) - new Date(year, 0, 1)) / 86400000) + 1

    function isoWeek(d) {
        const t = new Date(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()))
        const dn = t.getUTCDay() || 7
        t.setUTCDate(t.getUTCDate() + 4 - dn)
        const y0 = new Date(Date.UTC(t.getUTCFullYear(), 0, 1))
        return Math.ceil(((t - y0) / 86400000 + 1) / 7)
    }
    readonly property int week: isoWeek(date)

    // live seconds, only ticks while visible
    property string liveTime: Qt.formatDateTime(new Date(), "hh:mm:ss")
    Timer {
        interval: 1000
        repeat: true
        running: root.visible
        triggeredOnStart: true
        onTriggered: root.liveTime = Qt.formatDateTime(new Date(), "hh:mm:ss")
    }

    // capsule chip: same DNA as Pill (rounded, icon + label), outlined
    component Chip: Rectangle {
        id: chip
        property string icon: ""
        property string label: ""
        property color c: "#47b0b7"

        implicitWidth: chipRow.implicitWidth + 18
        implicitHeight: 26
        radius: height / 2
        color: "#1a47b0b7"
        border.width: 1
        border.color: "#3347b0b7"

        RowLayout {
            id: chipRow
            anchors.centerIn: parent
            spacing: 5

            Text {
                visible: chip.icon !== ""
                text: chip.icon
                color: chip.c
                font.family: "Material Symbols Rounded"
                font.pixelSize: 15
                renderType: Text.QtRendering
                Layout.alignment: Qt.AlignVCenter
            }
            Text {
                text: chip.label
                color: "#e0e0e0"
                font.family: "Iosevka Nerd Font"
                font.pixelSize: 11
                font.letterSpacing: 1
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }

    Rectangle {
        id: content
        width: parent.width
        implicitHeight: col.implicitHeight + 32
        height: implicitHeight
        radius: 24
        color: "#90000000"
        border.width: 1
        border.color: root.pinned ? "#8047b0b7" : "#3347b0b7"
        Behavior on border.color { ColorAnimation { duration: 200 } }

        opacity: root.shown ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }
        transform: Translate {
            y: root.shown ? 0 : -6
            Behavior on y { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
        }

        // ---- sweeping scanline (behind everything) ----
        Item {
            anchors.fill: parent
            anchors.margins: 1
            clip: true

            Rectangle {
                id: scan
                x: 16
                width: parent.width - 32
                height: 26
                y: -26
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 1.0; color: "#1247b0b7" }
                }
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: "#3047b0b7"
                }
            }

            SequentialAnimation {
                running: root.visible && root.shown
                loops: Animation.Infinite
                NumberAnimation { target: scan; property: "y"; from: -26; to: content.height; duration: 2600; easing.type: Easing.InOutSine }
                PauseAnimation { duration: 1600 }
            }
        }

        ColumnLayout {
            id: col
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // ---------- status row ----------
            RowLayout {
                Layout.fillWidth: true

                Chip {
                    icon: "nest_clock_farsight_analog"
                    label: root.liveTime
                    c: root.accent
                }
                Item { Layout.fillWidth: true }
                Chip {
                    icon: root.pinned ? "lock" : "sensors"
                    label: root.pinned ? "LOCKED" : "LIVE"
                    c: root.accent
                }
            }

            // ---------- ring + date ----------
            RowLayout {
                Layout.fillWidth: true
                spacing: 14

                Canvas {
                    id: ring
                    Layout.preferredWidth: 72
                    Layout.preferredHeight: 72

                    property real prog: root.today / root.daysInMonth
                    property real shownProg: 0

                    onProgChanged: if (root.shown) shownProg = prog
                    onShownProgChanged: requestPaint()

                    NumberAnimation {
                        id: ringAnim
                        target: ring
                        property: "shownProg"
                        from: 0
                        to: ring.prog
                        duration: 700
                        easing.type: Easing.OutCubic
                    }
                    Connections {
                        target: root
                        function onShownChanged() { if (root.shown) ringAnim.restart() }
                    }

                    onPaint: {
                        const ctx = getContext("2d")
                        ctx.reset()
                        const cx = width / 2, cy = height / 2

                        // outer tick ring
                        ctx.lineWidth = 1
                        ctx.lineCap = "butt"
                        ctx.strokeStyle = "rgba(71,176,183,0.35)"
                        for (let i = 0; i < 48; i++) {
                            const a = i / 48 * Math.PI * 2
                            const r1 = (i % 4 === 0) ? 31 : 33
                            ctx.beginPath()
                            ctx.moveTo(cx + Math.cos(a) * r1, cy + Math.sin(a) * r1)
                            ctx.lineTo(cx + Math.cos(a) * 35, cy + Math.sin(a) * 35)
                            ctx.stroke()
                        }

                        // track
                        ctx.lineWidth = 4
                        ctx.lineCap = "round"
                        ctx.strokeStyle = "rgba(71,176,183,0.2)"
                        ctx.beginPath()
                        ctx.arc(cx, cy, 26, 0, Math.PI * 2)
                        ctx.stroke()

                        // month progress
                        ctx.strokeStyle = "#47b0b7"
                        ctx.beginPath()
                        ctx.arc(cx, cy, 26, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * shownProg)
                        ctx.stroke()
                    }

                    Text {
                        anchors.centerIn: parent
                        text: String(root.today).padStart(2, "0")
                        color: root.fg
                        font.family: root.mono
                        font.pixelSize: 24
                        font.bold: true
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 3

                    Text {
                        text: Qt.formatDateTime(root.date, "dddd").toUpperCase()
                        color: root.fg
                        font.family: root.mono
                        font.pixelSize: 15
                        font.letterSpacing: 3
                    }
                    Text {
                        text: Qt.formatDateTime(root.date, "MMMM").toUpperCase() + " // " + root.year
                        color: root.accent
                        font.family: root.mono
                        font.pixelSize: 11
                        font.letterSpacing: 2
                    }
                    RowLayout {
                        spacing: 6
                        Chip { icon: "today"; label: "DAY " + String(root.dayOfYear).padStart(3, "0"); c: root.accent }
                        Chip { icon: "view_week"; label: "WK " + String(root.week).padStart(2, "0"); c: root.accent }
                    }
                }
            }

            // ---------- year gauge: 12 capsule segments ----------
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 3

                    Repeater {
                        model: 12
                        Rectangle {
                            readonly property real frac: index < root.month ? 1
                                : (index === root.month ? root.today / root.daysInMonth : 0)
                            Layout.fillWidth: true
                            Layout.preferredHeight: 6
                            radius: 3
                            color: "#2647b0b7"

                            Rectangle {
                                height: parent.height
                                width: parent.width * parent.frac
                                radius: 3
                                color: root.accent
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: Math.round(root.dayOfYear / root.daysInYear * 100) + "% ELAPSED"
                        color: root.fg
                        opacity: 0.6
                        font.family: root.mono
                        font.pixelSize: 9
                        font.letterSpacing: 1.5
                        Layout.fillWidth: true
                    }
                    Text {
                        text: (root.daysInYear - root.dayOfYear) + "D REMAIN"
                        color: root.fg
                        opacity: 0.6
                        font.family: root.mono
                        font.pixelSize: 9
                        font.letterSpacing: 1.5
                    }
                }
            }

            // ---------- calendar capsule ----------
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: calCol.implicitHeight + 16
                radius: 18
                color: "#0f47b0b7"
                border.width: 1
                border.color: "#1f47b0b7"

                ColumnLayout {
                    id: calCol
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 4

                    Grid {
                        columns: 7
                        Layout.fillWidth: true
                        Repeater {
                            model: ["MO", "TU", "WE", "TH", "FR", "SA", "SU"]
                            Text {
                                width: calCol.width / 7
                                horizontalAlignment: Text.AlignHCenter
                                text: modelData
                                color: root.accent
                                opacity: index >= 5 ? 0.45 : 0.85
                                font.family: root.mono
                                font.pixelSize: 10
                                font.letterSpacing: 1
                            }
                        }
                    }

                    Grid {
                        columns: 7
                        Layout.fillWidth: true
                        rowSpacing: 2

                        Repeater {
                            model: root.cells
                            Item {
                                readonly property int day: index - root.offset + 1
                                readonly property bool valid: day >= 1 && day <= root.daysInMonth
                                readonly property bool isToday: valid && day === root.today
                                readonly property bool isPast: valid && day < root.today
                                readonly property bool isWeekend: (index % 7) >= 5

                                width: calCol.width / 7
                                height: 26

                                // pulsing halo behind today
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 34
                                    height: 26
                                    radius: 13
                                    color: "#3347b0b7"
                                    visible: parent.isToday
                                    SequentialAnimation on opacity {
                                        running: root.visible && parent.visible
                                        loops: Animation.Infinite
                                        NumberAnimation { to: 0.25; duration: 900; easing.type: Easing.InOutSine }
                                        NumberAnimation { to: 1.0; duration: 900; easing.type: Easing.InOutSine }
                                    }
                                }
                                // today capsule
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 28
                                    height: 22
                                    radius: 11
                                    color: root.accent
                                    visible: parent.isToday
                                }
                                Text {
                                    anchors.centerIn: parent
                                    text: parent.valid ? String(parent.day).padStart(2, "0") : ""
                                    color: parent.isToday ? "#0b1d1e" : root.fg
                                    opacity: parent.isToday ? 1 : (parent.isPast ? 0.35 : (parent.isWeekend ? 0.6 : 0.9))
                                    font.family: root.mono
                                    font.pixelSize: 12
                                    font.bold: parent.isToday
                                }
                            }
                        }
                    }
                }
            }

            // ---------- hint ----------
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: root.pinned ? "CLICK OUTSIDE TO CLOSE" : "CLICK CLOCK TO LOCK"
                color: root.fg
                opacity: 0.4
                font.family: root.mono
                font.pixelSize: 9
                font.letterSpacing: 2
            }
        }
    }
}
