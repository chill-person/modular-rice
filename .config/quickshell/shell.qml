import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Io


PanelWindow {

    id: bar
    anchors { top: true; left: true; right: true }
    margins { top: 13; left: 20; right: 20 }
    implicitHeight: 33
    color: "transparent"


    Process {
        id: wlogoutProc
        command: ["wlogout"]
    }

    Poller {
        id: vol
        command: "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}'"
        interval: 200
    }

    Poller {
        id: bat
        command: "cat /sys/class/power_supply/BAT0/capacity"
        interval: 30000
    }

    Poller {
        id: bt
        command: "bluetoothctl show | grep -q 'Powered: yes' && echo on || echo off"
        interval: 5000
    }

    Poller {
        id: net
        command: "nmcli -t -f NAME connection show --active | head -n1"
        interval: 10000
    }

    readonly property var player: Mpris.players.values.find(p => p.playbackState === MprisPlaybackState.Playing) ?? Mpris.players.values[2] ?? null


    // ================= Left Section =================

    RowLayout {

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 14
        spacing: 8

        // Power Pill
        Pill {
            icon: "settings_power"
            iconColor: '#e06c75'

            hovered: mouseArea.containsMouse

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    wlogoutProc.running = false
                    wlogoutProc.running = true
                }
            }
        }

        // Lamp Pill - hyprsunset control, right of the power button
        Pill {
            id: lampPill
            icon: "wb_incandescent"
            iconColor: '#fbb974'
            hovered: lampMouse.containsMouse

            MouseArea {
                id: lampMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: sunsetPanel.toggle()
            }
        }

        SunsetPanel {
            id: sunsetPanel
            anchorItem: lampPill
            anchorWindow: bar
        }

        // Music Pill
        Pill {
            id: musicPill
            icon: "music_note"
            maxLabelWidth: 200
            label: bar.player ? `${bar.player.trackArtist || "Unknown"} — ${bar.player.trackTitle || "Unknown"}` : "Nothing is Playing"

            hovered: musicMouseArea.containsMouse

            MouseArea {
                id: musicMouseArea
                anchors.fill: parent
                hoverEnabled: true
            }
        }
    }


    // ================= Right Section =================

    RowLayout {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 14
        spacing: 8

        Pill {
            id: volPill
            icon: "volume_up"
            label: vol.value + "%"
            iconColor: '#eab135'
            hovered: volMouse.containsMouse
            MouseArea { id: volMouse; anchors.fill: parent; hoverEnabled: true }
        }

        Pill {
            id: batPill
            icon: "battery_android_full"
            label: bat.value + "%"
            iconColor: '#309d1f'
            hovered: batMouse.containsMouse
            MouseArea { id: batMouse; anchors.fill: parent; hoverEnabled: true }
        }

        Pill {
            id: netPill
            icon: "android_wifi_3_bar"
            label: net.value
            iconColor: '#abaaa8'
            hovered: netMouse.containsMouse
            MouseArea {
                id: netMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: wifiPanel.toggle()
            }
        }

        Pill {
            id: btPill
            icon: "bluetooth"
            label: bt.value
            iconColor: '#32a797'
            hovered: btMouse.containsMouse
            MouseArea { id: btMouse; anchors.fill: parent; hoverEnabled: true }
        }

        Pill {
            id: notificationPill
            icon: "notifications"
            label: ""
            iconColor: "#f5c542"
            hovered: notificationMouse.containsMouse

            MouseArea {
                id: notificationMouse
                anchors.fill: parent
                hoverEnabled: true

                onClicked: {
                    Quickshell.execDetached(["swaync-client", "-t"])
                }
            }
        }
    }


    // ================= Center Section =================

    RowLayout {
        id: centerGroup
        anchors.centerIn: parent
        spacing: 8

        // Native system clock
        SystemClock {
            id: clock
            precision: SystemClock.Minutes
        }

        Pill {
            id: clockPill
            icon: "nest_clock_farsight_analog"
            label: Qt.formatDateTime(clock.date, "hh:mm")

            hovered: clockMouse.containsMouse

            // the ONE clockMouse: hover = peek, click = lock open
            MouseArea {
                id: clockMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: datePopup.togglePin()
            }
        }

        Workspaces {}
    }

    // Date popup lives outside the layout, anchored under the clock pill
    DatePopup {
        id: datePopup
        anchorItem: clockPill
        anchorWindow: bar
        date: clock.date
        hovered: clockMouse.containsMouse
    }
}
