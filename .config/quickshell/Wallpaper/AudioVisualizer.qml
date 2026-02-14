import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

Item {
    id: root

    property int silentTime: 0
    property int visualizingTime: 0
    property bool isSilent: true
    property var cavaData: []
    property var cavaShadowData: []

    anchors.fill: parent

    Process {
        // base it on smoothed data

        id: cavaProc

        running: true
        command: ["sh", "-c", `
            cava -p /dev/stdin <<EOF
[general]
# Reduced to 20 for wider, smoother hills
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
waves = 0
gravity = 100
noise_reduction = 0.20

[eq]
1 = 1
2 = 1
3 = 1
4 = 1
5 = 1
EOF
        `]

        stdout: SplitParser {
            onRead: (data) => {
                let newPoints = data.split(";").map((p) => {
                    return parseFloat(p.trim()) / 1000;
                }).filter((p) => {
                    return !isNaN(p);
                });
                // --- force FAR ENDS to zero (for BOTH normal & shadow) ---
                if (newPoints.length >= 2) {
                    newPoints[0] = 0;
                    newPoints[newPoints.length - 1] = 0;
                }
                // Silence detection (keep or replace with EPS if you want)
                root.isSilent = newPoints.every((p) => {
                    return p === 0;
                });
                const smoothFactor = 0.3;
                // --- NORMAL DATA (unchanged behavior) ---
                if (root.cavaData.length === 0 || root.cavaData.length !== newPoints.length) {
                    root.cavaData = newPoints.slice();
                } else {
                    let smoothed = [];
                    for (let i = 0; i < newPoints.length; i++) {
                        let oldVal = root.cavaData[i];
                        let newVal = newPoints[i];
                        smoothed.push(oldVal + (newVal - oldVal) * smoothFactor);
                    }
                    root.cavaData = smoothed;
                }
                // --- SHADOW DATA ---
                // start from the already-smoothed normal data
                let shadowPoints = root.cavaData.slice();
                // force FIRST 4 values to zero (shadow-only rule)
                for (let i = 0; i < Math.min(6, shadowPoints.length); i++) {
                    shadowPoints[i] = 0;
                }
                // (far ends are already zero because they came from newPoints)
                root.cavaShadowData = shadowPoints;
                canvasLeft.requestPaint();
                canvasRight.requestPaint();
            }
        }

    }

    Rectangle {
        z: 3
        color: "transparent"
        anchors.fill: parent
        anchors.rightMargin: parent.width / 2
        anchors.leftMargin: 40
        anchors.topMargin: parent.height - 64
        anchors.bottomMargin: 38
        opacity: tiledWindowCount > 0 ? 1 : 0

        Canvas {
            id: canvasLeft

            function drawMountainWave(ctx, data, isShadow) {
                function clamp(v, min, max) {
                    return Math.max(min, Math.min(max, v));
                }

                if (data.length < 2)
                    return ;

                const MIN_AMPLITUDE = 0;
                // Horizontal gradient
                var gradient = ctx.createLinearGradient(0, 0, width, 0);
                gradient.addColorStop(0, '#1a1b26');
                gradient.addColorStop(0.3, '#1a1b26');
                gradient.addColorStop(0.6, '#1a1b26');
                gradient.addColorStop(1, '#1a1b26');
                ctx.beginPath();
                if (isShadow) {
                    ctx.globalAlpha = 0.3;
                    ctx.save();
                    ctx.translate(-80, -2); // shadow up
                    ctx.scale(1.02, 1.05);
                } else {
                    ctx.globalAlpha = 0.9;
                }
                ctx.fillStyle = gradient;
                // Start at bottom-left
                ctx.moveTo(0, height);
                var startVal = clamp(data[0], MIN_AMPLITUDE, 1);
                var startY = height - (startVal * height);
                ctx.lineTo(0, startY);
                var barWidth = width / (data.length - 1);
                for (var i = 0; i < data.length - 1; i++) {
                    var vCurr = clamp(data[i], MIN_AMPLITUDE, 1);
                    var vNext = clamp(data[i + 1], MIN_AMPLITUDE, 1);
                    var xCurr = i * barWidth;
                    var yCurr = height - (vCurr * height);
                    var xNext = (i + 1) * barWidth;
                    var yNext = height - (vNext * height);
                    var xMid = (xCurr + xNext) / 2;
                    var yMid = (yCurr + yNext) / 2;
                    ctx.quadraticCurveTo(xCurr, yCurr, xMid, yMid);
                }
                var lastVal = clamp(data[data.length - 1], MIN_AMPLITUDE, 1);
                var lastX = (data.length - 1) * barWidth;
                var lastY = height - (lastVal * height);
                ctx.lineTo(lastX, lastY);
                ctx.lineTo(width, height);
                ctx.closePath();
                ctx.fill();
                if (isShadow)
                    ctx.restore();

            }

            anchors.fill: parent
            onPaint: {
                var ctx = getContext('2d');
                ctx.clearRect(0, 0, width, height);
                drawMountainWave(ctx, root.cavaData, false);
                drawMountainWave(ctx, root.cavaShadowData, true);
            }
        }

    }

    Rectangle {
        z: 3
        color: "transparent"
        anchors.fill: parent
        anchors.rightMargin: 40
        anchors.leftMargin: parent.width / 2
        anchors.topMargin: parent.height - 64
        anchors.bottomMargin: 38
        opacity: tiledWindowCount > 0 ? 1 : 0

        Canvas {
            id: canvasRight

            function drawMountainWave(ctx, data, isShadow) {
                function clamp(v, min, max) {
                    return Math.max(min, Math.min(max, v));
                }

                if (data.length < 2)
                    return ;

                const MIN_AMPLITUDE = 0;
                // Horizontal gradient
                var gradient = ctx.createLinearGradient(0, 0, width, 0);
                gradient.addColorStop(0, '#1a1b26');
                gradient.addColorStop(0.3, '#1a1b26');
                gradient.addColorStop(0.6, '#1a1b26');
                gradient.addColorStop(1, '#1a1b26');
                ctx.beginPath();
                if (isShadow) {
                    ctx.globalAlpha = 0.3;
                    ctx.save();
                    ctx.translate(-80, -2); // shadow up
                    ctx.scale(1.02, 1.05);
                } else {
                    ctx.globalAlpha = 0.9;
                }
                ctx.fillStyle = gradient;
                // Start at bottom-left
                ctx.moveTo(0, height);
                var startVal = clamp(data[0], MIN_AMPLITUDE, 1);
                var startY = height - (startVal * height);
                ctx.lineTo(0, startY);
                var barWidth = width / (data.length - 1);
                for (var i = 0; i < data.length - 1; i++) {
                    var vCurr = clamp(data[i], MIN_AMPLITUDE, 1);
                    var vNext = clamp(data[i + 1], MIN_AMPLITUDE, 1);
                    var xCurr = i * barWidth;
                    var yCurr = height - (vCurr * height);
                    var xNext = (i + 1) * barWidth;
                    var yNext = height - (vNext * height);
                    var xMid = (xCurr + xNext) / 2;
                    var yMid = (yCurr + yNext) / 2;
                    ctx.quadraticCurveTo(xCurr, yCurr, xMid, yMid);
                }
                var lastVal = clamp(data[data.length - 1], MIN_AMPLITUDE, 1);
                var lastX = (data.length - 1) * barWidth;
                var lastY = height - (lastVal * height);
                ctx.lineTo(lastX, lastY);
                ctx.lineTo(width, height);
                ctx.closePath();
                ctx.fill();
                if (isShadow)
                    ctx.restore();

            }

            anchors.fill: parent
            onPaint: {
                var ctx = getContext('2d');
                ctx.clearRect(0, 0, width, height);
                drawMountainWave(ctx, root.cavaData, false);
                drawMountainWave(ctx, root.cavaShadowData, true);
            }
        }

    }

    Process {
        id: shellExec

        running: false

        stdout: StdioCollector {
            onStreamFinished: shellExec.running = false
        }

    }

    Timer {
        function exec(cmd) {
            if (shellExec.running)
                return ;

            // safety: don't overlap
            shellExec.command = ["sh", "-c", cmd];
            shellExec.running = true;
        }

        interval: 500
        repeat: true
        running: true
        onTriggered: {
            if (root.isSilent) {
                silentTime += 1;
                if (silentTime === 6) {
                    visualizingTime = 0;
                    exec(`hyprctl keyword general:gaps_out "10, 16, 10, 16"`);
                }
            } else {
                visualizingTime += 1;
                if (visualizingTime === 2) {
                    silentTime = 0;
                    exec(`hyprctl keyword general:gaps_out "10, 16, 28, 16"`);
                }
            }
        }
    }

}
