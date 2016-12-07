import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import "controls" as Neus

Item {
    anchors.fill: parent

    function gaze(point) {
        gaze_overlay.run(point)
    }

    function plot(lines) {
        lines = lines || []
        canvas.lines = []
        for (var i = 0; i < lines.length; i++)
            canvas.addLine(lines[i])
        canvas.requestPaint()
    }

    Neus.Heading {
        id: header
        font.weight: Font.Bold
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
    }

    ColumnLayout {
        anchors.top: header.bottom
        anchors.bottom: parent. bottom
        width: parent.width

        ShaderEffectSource {
            id: view
            sourceItem: runner

            Layout.fillWidth: true
            Layout.preferredHeight: width * (secondScreen.height / secondScreen.width)

            // canvas for drawing calibration plot lines
            Canvas {
                id: canvas

                property var lines: []
                property var colors: {"left": "#bd4b4b", "right": "#4b86bd"}

                visible: !eyetracker.tracking

                function addLine(line) {
                    line.from.x *= width
                    line.from.y *= height
                    line.to.x *= width
                    line.to.y *= height
                    line.color = colors[line.eye]
                    lines.push(line)
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
            Gaze { id: gaze_overlay }
        }

        Row {
            opacity: runner.running ? 1.0 : 0.0
            spacing: 10
            Neus.Label { text: qsTr("Running: ") + runner.name }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#eae9e5"
            border.color: "#777777"
            border.width: 1

            ListView {
                id: list
                anchors.fill: parent
                anchors.margins: parent.border.width
                clip: true

                currentIndex: Math.max(runner.next - 1, 0)
                model: runner.test

                delegate: Row {
                    width: list.width
                    padding: 2
                    leftPadding: 8
                    rightPadding: 8
                    Neus.Label {
                        text: modelData.index
                        width: parent.width * 0.05
                    }
                    Neus.Label {
                        text: modelData.name
                        width: parent.width * 0.15
                    }
                    Neus.Label {
                        text: modelData.args.join(", ")
                        width: parent.width * 0.8
                        maximumLineCount: 1
                        elide: Text.ElideRight
                    }
                }

                highlight: Rectangle { color: "lightsteelblue" }

                ScrollBar.vertical: ScrollBar { }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            enabled: runner.running

            Neus.Button {
                text: qsTr("Prev")  // TODO: replace with "⏪ "
                enabled: runner.next > 1
                onClicked: runner.back()
            }

            Neus.Button {
                text: qsTr("Pause")  // TODO: replace with "⏯"
                checked: runner.paused
                onClicked: runner.paused = !runner.paused
            }

            Neus.Button {
                text: qsTr("Next")  // TODO: replace with "⏩ "
                enabled: runner.next < runner.test.length
                onClicked: runner.forward()
            }

            ProgressBar {
                Layout.fillWidth: true
                value: runner.running ? runner.next / runner.test.length : 0
            }

            Neus.Button {
                text: qsTr("Stop")  // TODO: replace with unicode char
                enabled: runner.running
                onClicked: runner.stop()
            }
        }
    }
}
