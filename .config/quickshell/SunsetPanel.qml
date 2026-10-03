import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Io

// Popup panel that hangs below the lamp Pill.
// Section 1: hyprsunset (blue-light filter) on/off + warmth slider
// Section 2: per-monitor enable/disable, resolution/refresh cycling, brightness
PopupWindow {
    id: root

    // The Pill (or any Item) this panel should hang below, and the bar
    // (PanelWindow) it belongs to, used to anchor the popup's position.
    property var anchorItem: null
    property var anchorWindow: null

    // Match your Hyprland general{} gaps so the popup sits the same way
    // your tiled windows do: gaps_out from the screen edge, gaps_in
    // between it and the bar, no border.
    readonly property int gapsOut: 20
    readonly property int gapsIn: 8

    width: 300
    height: content.implicitHeight + 24
    visible: false
    color: "transparent"

    // Anchored to the bar's own window (not the icon): rect.x: 0 lines
    // the popup's left edge up with the bar's left edge, which is
    // already inset by gaps_out from the screen - so the popup ends up
    // exactly gaps_out from the screen edge too, same as any tiled
    // window. rect.y drops it gaps_in below the bar.
    anchor {
        window: root.anchorWindow
        rect.x: 0
        rect.y: (root.anchorWindow ? root.anchorWindow.height : 0) + root.gapsIn
    }

    function toggle() {
        root.visible = !root.visible
        if (root.visible) monitorPoll.run()
    }

    // ================= hyprsunset ======================================
    //
    // Confirmed failure mode: hyprctl hyprsunset only works once the
    // daemon's IPC socket is open, and that takes a beat after launch
    // ("Couldn't connect to .../.hyprsunset.sock"). Rather than guess a
    // fixed delay, we retry the hyprctl call with backoff until it
    // stops reporting a connection error.

    property bool sunsetEnabled: false
    property int temperature: 4500
    readonly property int minTemp: 2500
    readonly property int maxTemp: 6500

    property var _pendingCallback: null

    Process {
        id: daemonCheck
        command: ["pgrep", "-x", "hyprsunset"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (this.text.trim() === "") {
                    console.log("[SunsetPanel] hyprsunset not running, starting it")
                    Quickshell.execDetached(["hyprsunset"])
                }
                const cb = root._pendingCallback
                root._pendingCallback = null
                if (cb) cb()
            }
        }
    }

    function ensureDaemon(callback) {
        root._pendingCallback = callback
        daemonCheck.running = false; daemonCheck.running = true
    }

    // Generic hyprctl runner used for both identity and temperature,
    // retrying while the socket isn't up yet.
    property var _retryArgs: []
    property int _retryCount: 0

    Process {
        id: ctlProc
        stdout: StdioCollector {
            onStreamFinished: if (this.text.trim() !== "") console.log("[SunsetPanel]", this.text.trim())
        }
        stderr: StdioCollector {
            onStreamFinished: {
                const t = this.text.trim()
                if (t === "") return
                if (t.includes("Couldn't connect") && root._retryCount < 8) {
                    root._retryCount++
                    retryTimer.start()
                } else {
                    console.log("[SunsetPanel] hyprctl error:", t)
                }
            }
        }
    }

    Timer {
        id: retryTimer
        interval: 250
        onTriggered: {
            ctlProc.command = root._retryArgs
            ctlProc.running = false; ctlProc.running = true
        }
    }

    function runHyprctl(args) {
        root._retryArgs = args
        root._retryCount = 0
        ctlProc.command = args
        ctlProc.running = false; ctlProc.running = true
    }

    function applySunset() {
        root.ensureDaemon(() => {
            if (root.sunsetEnabled) {
                root.runHyprctl(["hyprctl", "hyprsunset", "temperature", String(root.temperature)])
            } else {
                root.runHyprctl(["hyprctl", "hyprsunset", "identity"])
            }
        })
    }

    // Debounce the slider so we don't spam the daemon every pixel of drag.
    Timer {
        id: tempDebounce
        interval: 120
        onTriggered: if (root.sunsetEnabled) root.runHyprctl(["hyprctl", "hyprsunset", "temperature", String(root.temperature)])
    }

    // ================= monitors ========================================

    property var monitors: []

    Process {
        id: monitorPoll
        command: ["hyprctl", "monitors", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.monitors = JSON.parse(this.text)
                } catch (e) {
                    root.monitors = []
                }
            }
        }
        function run() { running = false; running = true }
    }

    function toggleMonitor(mon) {
        const cmd = mon.disabled
            ? `hyprctl keyword monitor "${mon.name},preferred,auto,1"`
            : `hyprctl keyword monitor "${mon.name},disable"`
        Quickshell.execDetached(["sh", "-c", cmd])
        monitorPoll.run()
    }

    function cycleMode(mon) {
        if (!mon.availableModes || mon.availableModes.length === 0) return
        const cur = `${mon.width}x${mon.height}@${mon.refreshRate.toFixed(2)}Hz`
        let idx = mon.availableModes.indexOf(cur)
        idx = (idx + 1) % mon.availableModes.length
        const mode = mon.availableModes[idx]
        Quickshell.execDetached(["sh", "-c", `hyprctl keyword monitor "${mon.name},${mode},auto,1"`])
        monitorPoll.run()
    }

    // swayosd-client with a bare (unsigned) number sets brightness to that
    // absolute percentage, and pops the same OSD your XF86Brightness keys
    // trigger - so the slider and your keyboard stay in sync.
    Process {
        id: brightnessProc
        command: ["swayosd-client", "--brightness", String(root.brightness)]
    }

    property int brightness: 80
    Timer {
        id: brightnessDebounce
        interval: 60
        onTriggered: { brightnessProc.running = false; brightnessProc.running = true }
    }

    // ==================================================================
    // ui
    // ==================================================================

    Rectangle {
        id: content
        anchors.fill: parent
        radius: 18
        // matches Pill's own background exactly
        color: '#bf000000'

        implicitHeight: col.implicitHeight + 28

        ColumnLayout {
            id: col
            anchors.fill: parent
            anchors.margins: 14
            spacing: 14

            // ---------- Night Light header ----------
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: "wb_incandescent"
                    font.family: "Material Symbols Rounded"
                    font.pixelSize: 20
                    color: root.sunsetEnabled ? "#fbb974" : "#50453a"
                }

                Text {
                    text: "Night Light"
                    color: "#eee0d5"
                    font.family: "Iosevka Nerd Font"
                    font.pixelSize: 15
                    Layout.fillWidth: true
                }

                Rectangle {
                    id: toggleTrack
                    width: 42
                    height: 24
                    radius: height / 2
                    color: root.sunsetEnabled ? "#fbb974" : "#50453a"
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Rectangle {
                        width: 18
                        height: 18
                        radius: height / 2
                        color: '#9a46371e'
                        anchors.verticalCenter: parent.verticalCenter
                        x: root.sunsetEnabled ? parent.width - width - 3 : 3
                        Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.sunsetEnabled = !root.sunsetEnabled
                            root.applySunset()
                        }
                    }
                }
            }

            // Warmth slider
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                enabled: root.sunsetEnabled
                opacity: root.sunsetEnabled ? 1.0 : 0.4
                Behavior on opacity { NumberAnimation { duration: 150 } }

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Warmth"
                        color: "#eee0d5"
                        font.family: "Iosevka Nerd Font"
                        font.pixelSize: 13
                        Layout.fillWidth: true
                    }
                    Text {
                        text: root.temperature + "K"
                        color: "#fbb974"
                        font.family: "Iosevka Nerd Font"
                        font.pixelSize: 13
                    }
                }

                SliderBar {
                    Layout.fillWidth: true
                    value: root.temperature
                    from: root.minTemp
                    to: root.maxTemp
                    onMoved: v => {
                        root.temperature = Math.round(v)
                        tempDebounce.restart()
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#33eee0d5" }

            // ---------- Displays header ----------
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                Text {
                    text: "desktop_windows"
                    font.family: "Material Symbols Rounded"
                    font.pixelSize: 20
                    color: "#fbb974"
                }
                
            }

            // Backlight brightness
            

            
        }
    }
}
