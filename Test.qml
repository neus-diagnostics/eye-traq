import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0

import "controls" as Neus

Item {
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

    Component.onCompleted: {
        onVisibleChanged.connect(stop)
    }

    Connections {
        target: runner
        onDone: stop()
    }

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

            Gaze { id: gaze }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            height: main.height * 0.04
            spacing: main.height * 0.025

            Neus.Button {
                text: runner.running ? qsTr("Stop") : qsTr("Start")
                width: content.width * 0.1
                height: parent.height
                onClicked: runner.running ? stop() : start()
            }

            Neus.Button {
                id: pause
                text: runner.paused ? qsTr("Resume") : qsTr("Pause")
                width: content.width * 0.1
                height: parent.height
                visible: runner.running
                onClicked: runner.paused = !runner.paused
            }
        }
    }
}
