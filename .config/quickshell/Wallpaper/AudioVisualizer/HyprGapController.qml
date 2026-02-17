import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Item {
    property bool silent: true
    property int silentTime: 0
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
            if (silent) {
                silentTime++;
                if (silentTime === 5) {
                    // after 5 seconds of silence, increase the gaps
                    run(`hyprctl keyword general:gaps_out "10,16,10,16"`);
                    gapsIncreased = false;
                }
            } else {
                silentTime = 0;
                run(`hyprctl keyword general:gaps_out "10,16,28,16"`);
                gapsIncreased = true;
            }
        }
    }

}
