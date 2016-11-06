import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0

import "controls" as Neus

Rectangle {
    color: "#e0d8c1"

    property var options
    property var runner

    function start() {
        state = "running"
        recorder.start(options.testFile, options.participant);
    }

    function stop() {
        recorder.stop()
        state = ""
    }

    onVisibleChanged: {
        if (state == "running")
            stop()
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
        }

        Neus.Button {
            id: control
            text: qsTr("Start")
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: start()
        }
    }

    states: [
        State {
            name: "running"
            PropertyChanges {
                target: control
                text: qsTr("Stop")
                onClicked: stop()
            }
        }
    ]
}
