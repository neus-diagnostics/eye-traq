import QtQuick 2.7

import "controls" as Neus

Item {
    property var options
    property var runner

    property var colors: {"left": "#bd4b4b", "right": "#4b86bd"}

    function start() {
        plot.lines = []
        plot.requestPaint()
        eyetracker.command("start_calibration")
        runner.done.connect(end)
        runner.start("file:tests/calibrate")
    }

    function stop() {
        runner.done.disconnect(end)
        runner.stop()
        eyetracker.command("stop_calibration")
    }

    function end(msg) {
        var msg = "Calibration successful."
        if (!eyetracker.command("compute_calibration"))
            msg = "Calibration failed."
        stop()

        var calibration = eyetracker.get_calibration();
        for (var i = 0; i < calibration.length; i++) {
            var line = calibration[i]
            plot.addLine(line["start"], line["end"], colors[line["eye"]])
        }
        plot.requestPaint()
    }

    Component.onCompleted: {
        runner.onDone.connect(end)
        onVisibleChanged: stop()
    }

    Column {
        anchors.fill: parent
        spacing: parent.height * 0.03
        topPadding: parent.height * 0.05

        // duplicate the participant’s view
        ShaderEffectSource {
            anchors.horizontalCenter: parent.horizontalCenter
            sourceItem: runner
            width: parent.width * 0.8
            height: parent.height * 0.8

            // canvas for drawing calibration plot lines
            Canvas {
                id: plot
                property var lines: []

                function addLine(from, to, color) {
                    from.x *= width
                    from.y *= height
                    to.x *= width
                    to.y *= height
                    plot.lines.push({'from': from, 'to': to, 'color': color})
                }

                anchors.fill: parent
                focus: true
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    ctx.lineWidth = 1;
                    for (var i = 0; i < lines.length; i++) {
                        ctx.strokeStyle = lines[i]["color"]
                        ctx.beginPath()
                        ctx.moveTo(lines[i]["from"].x, lines[i]["from"].y)
                        ctx.lineTo(lines[i]["to"].x, lines[i]["to"].y)
                        ctx.stroke()
                        ctx.closePath()
                    }
                }
            }
        }

        Neus.Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: runner.running ? qsTr("Stop") : qsTr("Start")
            onClicked: runner.running ? stop() : start()
        }
    }
}
