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

    Component.onCompleted: {
        runner.onDone.connect(stop)
        onVisibleChanged.connect(stop)
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

            Gaze { id: gaze }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20
            Neus.Button {
                text: runner.running ? qsTr("Stop") : qsTr("Start")
                onClicked: runner.running ? stop() : start()
            }

            Neus.Button {
                id: pause
                text: runner.paused ? qsTr("Resume") : qsTr("Pause")
                visible: runner.running
                onClicked: runner.paused = !runner.paused
            }
        }
    }
}
