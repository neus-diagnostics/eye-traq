import QtQuick 2.7
import QtQuick.Layouts 1.3

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

    ColumnLayout {
        id: content

        anchors.horizontalCenter: parent.horizontalCenter
        width: main.width * 0.8
        spacing: width * 0.02

        // duplicate the participant’s view
        ShaderEffectSource {
            sourceItem: runner
            width: parent.width
            height: width * (secondScreen.height / secondScreen.width)

            Gaze { id: gaze }
        }

        Item {
            width: parent.width

            Row {
                anchors.left: parent.left
                spacing: content.width * 0.01
                visible: runner.running

                Neus.Button {
                    text: "⏪"
                    width: content.width * 0.05
                    enabled: runner.next > 1
                    onClicked: runner.back()
                }

                Neus.Button {
                    text: "⏯"
                    width: content.width * 0.05
                    checked: runner.paused
                    onClicked: runner.paused = !runner.paused
                }

                Neus.Button {
                    text: "⏩"
                    width: content.width * 0.05
                    enabled: runner.next < runner.test.length
                    onClicked: runner.forward()
                }
            }

            Neus.Button {
                anchors.right: parent.right
                text: runner.running ? qsTr("Stop") : qsTr("Start")
                width: content.width * 0.1
                onClicked: runner.running ? stop() : start()
            }

        }
    }
}
