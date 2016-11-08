import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0

import "controls" as Neus

Rectangle {
    property var options
    property var runner

    function start() {
        recorder.start(options.testFile, options.participant)
        runner.start(options.testFile)
    }

    function stop() {
        runner.stop()
        recorder.stop()
    }

    color: "#e0d8c1"

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
        }

        Neus.Button {
            id: control
            anchors.horizontalCenter: parent.horizontalCenter
            text: runner.state != "running" ? qsTr("Start") : qsTr("Stop")
            onClicked: runner.state != "running" ? start() : stop()
        }
    }
}
