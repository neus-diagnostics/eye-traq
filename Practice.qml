import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0

import "controls" as Neus

Item {
    id: main

    property var options
    property var runner
    property alias gaze: gaze

    anchors.fill: parent

    Column {
        id: content

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: parent.height * 0.1
        }
        width: parent.width * 0.9
        spacing: main.height * 0.025

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
                text: qsTr("Smooth pursuit")
                width: content.width * 0.25
                height: parent.height
                enabled: !runner.running
                onClicked: runner.start("file:tests/practice-pursuit")
            }

            Neus.Button {
                text: qsTr("Pro-saccade (H)")
                width: content.width * 0.25
                height: parent.height
                enabled: !runner.running
                onClicked: runner.start("file:tests/practice-prosaccade-horizontal")
            }

            Neus.Button {
                text: qsTr("Pro-saccade (V)")
                width: content.width * 0.25
                height: parent.height
                enabled: !runner.running
                onClicked: runner.start("file:tests/practice-prosaccade-vertical")
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            height: main.height * 0.04
            spacing: main.height * 0.025

            Neus.Button {
                text: qsTr("Anti-saccade")
                width: content.width * 0.25
                height: parent.height
                enabled: !runner.running
                onClicked: runner.start("file:tests/practice-antisaccade-horizontal")
            }

            Neus.Button {
                text: qsTr("Image pair")
                width: content.width * 0.25
                height: parent.height
                enabled: !runner.running
                onClicked: runner.start("file:tests/practice-imgpair")
            }
        }
    }
}
