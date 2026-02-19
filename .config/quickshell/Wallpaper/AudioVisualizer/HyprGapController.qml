import QtQuick
import Quickshell.Io

Item {
    id: root

    property bool silent: true
    property int silentTime: 0
    property int activeTime: 0
    property bool gapsIncreased: false

    Process {
        id: exec

        running: false

        stdout: StdioCollector {
            onStreamFinished: exec.running = false
        }

    }

    Timer {
        function run(cmd) {
            if (exec.running)
                return ;

            exec.command = ["sh", "-c", cmd];
            exec.running = true;
        }

        interval: 1000
        repeat: true
        running: true
        onTriggered: {
            if (root.silent) {
                root.silentTime++;
                root.activeTime = 0;
                if (root.silentTime === 5) {
                    // after 5 seconds of silence, decrease the gaps
                    run(`hyprctl keyword general:gaps_out "10,16,10,16"`);
                    root.gapsIncreased = false;
                }
            } else {
                root.silentTime = 0;
                root.activeTime++;
                if (root.activeTime === 5) {
                    // after 2 seconds of music, increase the gaps
                    run(`hyprctl keyword general:gaps_out "10,16,28,16"`);
                    root.gapsIncreased = true;
                }
            }
        }
    }

}
