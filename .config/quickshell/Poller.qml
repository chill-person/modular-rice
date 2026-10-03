import Quickshell
import Quickshell.Io 
import QtQuick

Scope {
    id: root

    property string command: ""
    property int interval: 3000
    property string value: ""

    // Main process to run and collect the output of root.command
    Process {
        id: proc 
        command: ["sh", "-c", root.command]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.value = this.text.trim()
        }
    }

    // Timer for regular polling interval
    Timer {
        interval: root.interval
        running: true
        repeat: true
        onTriggered: proc.running = true
    }

    // Automatic event listener for volume commands
    Process {
        id: audioListener
        // Only start this process if the command is audio-related
        running: root.command.includes("wpctl") || root.command.includes("pactl")
        command: ["pactl", "subscribe"]

        stdout: SplitParser {
            onRead: data => {
                // Instantly re-run proc whenever a PipeWire/PulseAudio sink event occurs
                if (data.includes("sink")) {
                    proc.running = true
                }
            }
        }
    }
}