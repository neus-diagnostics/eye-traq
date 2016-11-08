import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0

import "controls" as Neus

Rectangle {
    id: main

    property var options
    property var runner

    function start(testfile) {
        runner.start(testfile)
    }

    function stop() {
        runner.stop()
    }

    color: "#e0d8c1"

    Component.onCompleted: {
        onVisibleChanged.connect(stop)
    }

    Grid {
        anchors {
            left: parent.left
            leftMargin: parent.width * 0.05
            verticalCenter: parent.verticalCenter
        }
        width: parent.width * 0.25

        verticalItemAlignment: Grid.AlignVCenter
        spacing: parent.width * 0.01
        columns: 2

        Label { text: qsTr("Smooth pursuit") }
        Neus.Button {
            id: pursuit
            text: qsTr("Start")
            height: 40
            enabled: runner.state != "running"
            onClicked: start("file:tests/practice-pursuit")
        }

        Label { text: qsTr("Pro-saccade task (horizontal)") }
        Neus.Button {
            id: pstX
            text: qsTr("Start")
            height: 40
            enabled: runner.state != "running"
            onClicked: start("file:tests/practice-prosaccade-horizontal")
        }

        Label { text: qsTr("Pro-saccade task (vertical)") }
        Neus.Button {
            id: pstY
            text: qsTr("Start")
            height: 40
            enabled: runner.state != "running"
            onClicked: start("file:tests/practice-prosaccade-vertical")
        }

        Label { text: qsTr("Anti-saccade task (horizontal)") }
        Neus.Button {
            id: astX
            text: qsTr("Start")
            height: 40
            enabled: runner.state != "running"
            onClicked: start("file:tests/practice-antisaccade-horizontal")
        }

        Label { text: qsTr("Visual paired comparison") }
        Neus.Button {
            id: vpc
            text: qsTr("Start")
            height: 40
            enabled: runner.state != "running"
            onClicked: start("file:tests/practice-imgpair")
        }
    }

    // duplicate the participant’s view
    ShaderEffectSource {
        anchors {
            right: parent.right
            rightMargin: parent.width * 0.05
            verticalCenter: parent.verticalCenter
        }
        sourceItem: main.runner
        width: parent.width * 0.6
        height: parent.height * 0.6
    }
}
