// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright © 2016-2018 Neus Diagnostics, d.o.o.

import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import "controls" as My

Item {
    anchors.fill: parent

    function gaze(left, right) {
        if (left)
            gaze_overlay.run(left, '#f44336')
        if (right)
            gaze_overlay.run(right, '#2196f3')
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
            if (lines[i].valid)
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

    ColumnLayout {
        anchors.fill: parent

        // use at most 4/5 of Viewer height to show participant’s view with the correct aspect ratio
        Item {
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth:
                (secondScreen.geometry.width / secondScreen.geometry.height < parent.width / (parent.height*4/5)) ?
                    (parent.height*4/5 * (secondScreen.geometry.width / secondScreen.geometry.height)) : parent.width
            Layout.preferredHeight:
                (secondScreen.geometry.width / secondScreen.geometry.height < parent.width / (parent.height*4/5)) ?
                    (parent.height*4/5) : (parent.width * (secondScreen.geometry.height / secondScreen.geometry.width))

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

                My.Label {
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

        // use remaining space to show test progress
        Row {
            opacity: runner.running ? 1.0 : 0.0
            spacing: 10
            My.Label { text: qsTr("Running: ") + runner.name }
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

                    My.Label {
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
                    My.Label {
                        text: modelData.name
                        width: parent.width * 0.15
                    }
                    My.Label {
                        text: JSON.stringify(modelData, function (key, value) {
                            return key === 'name' || key === 'start' ? undefined : value
                        })
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

            My.Button {
                text: qsTr("Prev")  // TODO: replace with "⏪ "
                enabled: runner.next > 1
                onClicked: runner.back()
            }

            My.Button {
                text: qsTr("Pause")  // TODO: replace with "⏯"
                checked: runner.paused
                onClicked: runner.paused = !runner.paused
            }

            My.Button {
                text: qsTr("Next")  // TODO: replace with "⏩ "
                enabled: runner.next < runner.test.length
                onClicked: runner.forward()
            }

            My.ProgressBar {
                Layout.fillWidth: true
                value: runner.running ? runner.next / runner.test.length : 0
            }

            My.Button {
                text: qsTr("Stop")  // TODO: replace with unicode char
                onClicked: runner.stop()
            }
        }
    }
}
