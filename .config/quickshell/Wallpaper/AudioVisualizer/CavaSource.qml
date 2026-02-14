import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: cava

    property var data: []
    property var shadowData: []
    property bool isSilent: true
    property real smoothFactor: 0.3

    signal updated()

    visible: false // it doesn't render anyway

    Process {
        id: cavaProc

        running: true
        command: ["sh", "-c", `
            cava -p /dev/stdin <<EOF
[general]
bars = 40
framerate = 60
autosens = 1

[input]
method = pulse

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 1000
bar_delimiter = 59

[smoothing]
monstercat = 1.5
gravity = 100
noise_reduction = 0.20
EOF
        `]

        stdout: SplitParser {
            onRead: (line) => {
                let points = line.split(";").map((p) => {
                    return parseFloat(p) / 1000;
                }).filter((p) => {
                    return !isNaN(p);
                });
                points = points.concat(points.slice().reverse()).concat(points.slice().reverse());
                if (points.length < 2)
                    return ;

                points[0] = 0;
                points[points.length - 1] = 0;
                cava.isSilent = points.every((p) => {
                    return p === 0;
                });
                if (cava.data.length !== points.length)
                    cava.data = points.slice();
                else
                    cava.data = cava.data.map((v, i) => {
                    return v + (points[i] - v) * cava.smoothFactor;
                });
                let shadow = cava.data.slice();
                for (let i = 0; i < Math.min(12, shadow.length); i++) shadow[i] = 0
                cava.shadowData = shadow;
                cava.updated();
            }
        }

    }

}
