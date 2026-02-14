import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Item {
    property bool silent: true
    property int silentTime: 0
    property int activeTime: 0

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

        interval: 500
        repeat: true
        running: true
        onTriggered: {
            if (silent) {
                silentTime++;
                activeTime = 0;
                if (silentTime === 6)
                    run(`hyprctl keyword general:gaps_out "10,16,10,16"`);

            } else {
                activeTime++;
                silentTime = 0;
                if (activeTime === 2)
                    run(`hyprctl keyword general:gaps_out "10,16,28,16"`);

            }
        }
    }

}
