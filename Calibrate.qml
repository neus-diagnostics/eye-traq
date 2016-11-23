import QtQuick 2.7

import "controls" as Neus

Item {
    id: main

    property var options
    property var runner

    property var colors: {"left": "#bd4b4b", "right": "#4b86bd"}

    function start() {
        plot.lines = []
        plot.requestPaint()
        runner.start("file:tests/calibrate")
    }

    function stop() {
        runner.stop()
        eyetracker.calibrate("stop")
    }

    function end(msg) {
        var msg = "Calibration successful."
        if (!eyetracker.calibrate("compute"))
            msg = "Calibration failed."
        stop()

        var calibration = eyetracker.get_calibration();
        for (var i = 0; i < calibration.length; i++) {
            var line = calibration[i]
            plot.addLine(line["start"], line["end"], colors[line["eye"]])
        }
        plot.requestPaint()
    }

    anchors.fill: parent

    onVisibleChanged: eyetracker.calibrate("stop")

    Column {
        id: content

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: parent.height * 0.1
        }
        width: parent.width * 0.9
        spacing: parent.height * 0.025

        // duplicate the participant’s view
        ShaderEffectSource {
            sourceItem: runner
            width: parent.width
            height: width * (secondScreen.height / secondScreen.width)

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
            text: runner.running ? qsTr("Stop") : qsTr("Start")
            anchors.right: content.right
            width: content.width * 0.1
            height: main.height * 0.04
            onClicked: runner.running ? stop() : start()
        }
    }
}
