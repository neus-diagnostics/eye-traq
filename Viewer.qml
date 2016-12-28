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
        if (lines === undefined) {
            canvas.visible = false
            return
        }
        txtMessage.text = lines.length > 0 ?
            '<font color="green">' + qsTr("Calibration succeded.") + '</font>' :
            '<font color="red">' + qsTr("Calibration failed.") + '</font>'
        canvas.lines = []
        for (var i = 0; i < lines.length; i++)
            canvas.addLine(lines[i])
        canvas.requestPaint()
        canvas.visible = true
    }

    Connections {
        target: runner
        onRunningChanged: {
            if (runner.running)
                canvas.visible = false;
        }
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

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: width * (secondScreen.height / secondScreen.width)

            // canvas for drawing calibration plot lines
            Canvas {
                id: canvas

                property var lines: []
                property var colors: {"left": "#bd4b4b", "right": "#4b86bd"}

                z: 0

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
                visible: false

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.fillStyle = "#000000"
                    ctx.fillRect(0, 0, width, height)
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

                Neus.Label {
                    id: txtMessage
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: parent.height * 3/4
                }
            }

            ShaderEffectSource {
                id: view
                sourceItem: runner
                anchors.fill: parent
                visible: !canvas.visible
                z: 1
            }

            Gaze { id: gaze_overlay; z: 2 }
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

                model: runner.test
                currentIndex: Math.max(runner.next - 1, 0)
                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Center)

                delegate: Row {
                    width: list.width
                    padding: 2
                    leftPadding: 8
                    rightPadding: 8

                    Neus.Label {
                        function format(time) {
                            var minutes = Math.floor(time/60000)
                            var seconds = (time / 1000) % 60
                            return "" +
                                (minutes < 10 ? " " : "") + minutes + ":" +
                                (seconds < 10 ? "0" : "") + seconds.toFixed(2)
                        }
                        text: format(modelData.start)
                        width: parent.width * 0.1
                    }
                    Neus.Label {
                        text: modelData.name
                        width: parent.width * 0.15
                    }
                    Neus.Label {
                        text: modelData.args.join(", ")
                        width: parent.width * 0.75
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
                onClicked: runner.stop()
            }
        }
    }
}
