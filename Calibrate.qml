import QtQuick 2.7

import "controls" as Neus

Item {
    id: main

    property var options
    property var runner
    property var colors: {"left": "#bd4b4b", "right": "#4b86bd"}

    function start() {
        status.text = ""
        plot.lines = []
        plot.requestPaint()
        runner.start("file:tests/calibrate")
    }

    function stop() {
        runner.stop()
        eyetracker.calibrate("stop")
    }

    function end(msg) {
        var success = eyetracker.calibrate("compute")
        stop()

        if (success) {
            status.text = "Calibration successful."
            plot.addLines(eyetracker.get_calibration())
            plot.requestPaint()
        } else {
            status.text = "Calibration failed."
        }
    }

    anchors.fill: parent

    onVisibleChanged: eyetracker.calibrate("stop")

    Column {
        id: content

        anchors.horizontalCenter: parent.horizontalCenter
        spacing: parent.height * 0.025

        // duplicate the participant’s view
        ShaderEffectSource {
            sourceItem: runner
            width: height * (secondScreen.width / secondScreen.height)
            height: main.height * 0.9

            // canvas for drawing calibration plot lines
            Canvas {
                id: plot
                property var lines: []

                function addLines(lines) {
                    for (var i = 0; i < lines.length; i++) {
                        var line = lines[i]
                        line.from.x *= width
                        line.from.y *= height
                        line.to.x *= width
                        line.to.y *= height
                        line.color = colors[line.eye]
                        plot.lines.push(line)
                    }
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

        Item {
            width: parent.width
            height: firstScreen.height * 0.04

            Neus.Label {
                id: status
                anchors.left: parent.left
                font.pixelSize: parent.height * 0.5
                verticalAlignment: Text.AlignVCenter
            }

            Neus.Button {
                text: runner.running ? qsTr("Stop") : qsTr("Start")
                anchors.right: parent.right
                width: content.width * 0.1
                height: parent.height
                onClicked: runner.running ? stop() : start()
            }
        }
    }
}
