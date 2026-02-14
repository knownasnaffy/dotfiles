import QtQuick

Canvas {
    id: canvas

    property var data: []
    property var shadowData: []

    function drawWave(ctx, values, isShadow) {
        function clamp(v) {
            return Math.max(0, Math.min(1, v));
        }

        if (values.length < 2)
            return ;

        ctx.beginPath();
        if (isShadow) {
            ctx.globalAlpha = 0.3;
            ctx.save();
            ctx.translate(-80, -2);
            ctx.scale(1.02, 1.05);
        } else {
            ctx.globalAlpha = 0.9;
        }
        ctx.fillStyle = "#1a1b26";
        ctx.moveTo(0, height);
        let step = width / (values.length - 1);
        for (let i = 0; i < values.length - 1; i++) {
            let x1 = i * step;
            let y1 = height - clamp(values[i]) * height;
            let x2 = (i + 1) * step;
            let y2 = height - clamp(values[i + 1]) * height;
            ctx.quadraticCurveTo(x1, y1, (x1 + x2) / 2, (y1 + y2) / 2);
        }
        ctx.lineTo(width, height);
        ctx.closePath();
        ctx.fill();
        if (isShadow)
            ctx.restore();

    }

    onPaint: {
        let ctx = getContext("2d");
        ctx.clearRect(0, 0, width, height);
        drawWave(ctx, data, false);
        drawWave(ctx, shadowData, true);
    }
}
