import QtQuick 2.7

import "controls" as Neus

Item {
    id: main

    property var options
    property var runner
    property alias gaze: gaze

    function start() {
        recorder.start(options.testFile, options.participant)
        runner.start(options.testFile)
    }

    function stop() {
        runner.stop()
        recorder.stop()
    }

    anchors.fill: parent

    Connections {
        target: runner
        onDone: stop()
    }

    Column {
        id: content

        anchors.horizontalCenter: parent.horizontalCenter
        spacing: height * 0.03

        // duplicate the participant’s view
        ShaderEffectSource {
            sourceItem: runner
            width: height * (secondScreen.width / secondScreen.height)
            height: main.height * 0.9

            Gaze { id: gaze }
        }

        Item {
            width: parent.width
            height: firstScreen.height * 0.04

            Row {
                anchors.left: parent.left
                height: parent.height
                spacing: main.height * 0.01
                visible: runner.running

                Neus.Button {
                    text: "⏪"
                    width: content.width * 0.05
                    height: parent.height
                    enabled: runner.next > 1
                    onClicked: runner.back()
                }

                Neus.Button {
                    text: runner.paused ? "▶" : "▮▮"
                    font.pixelSize: height * 0.3
                    width: content.width * 0.05
                    height: parent.height
                    onClicked: runner.paused = !runner.paused
                }

                Neus.Button {
                    text: "⏩"
                    width: content.width * 0.05
                    height: parent.height
                    enabled: runner.next < runner.test.length
                    onClicked: runner.forward()
                }
            }

            Neus.Button {
                anchors.right: parent.right
                text: runner.running ? qsTr("Stop") : qsTr("Start")
                width: content.width * 0.1
                height: parent.height
                onClicked: runner.running ? stop() : start()
            }

        }
    }
}
