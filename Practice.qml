import QtQuick 2.7

import "controls" as Neus

Item {
    id: main

    property var options
    property var runner
    property alias gaze: gaze

    anchors.fill: parent

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

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            height: firstScreen.height * 0.04
            spacing: height * 0.6
            enabled: !runner.running

            Neus.Button {
                text: qsTr("Image pair")
                width: content.width * 0.25
                height: parent.height
                onClicked: runner.start("file:tests/practice-imgpair")
            }

            Neus.Button {
                text: qsTr("Pro-saccade (H)")
                width: content.width * 0.25
                height: parent.height
                onClicked: runner.start("file:tests/practice-prosaccade-horizontal")
            }

            Neus.Button {
                text: qsTr("Pro-saccade (V)")
                width: content.width * 0.25
                height: parent.height
                onClicked: runner.start("file:tests/practice-prosaccade-vertical")
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            height: firstScreen.height * 0.04
            spacing: height * 0.6
            enabled: !runner.running

            Neus.Button {
                text: qsTr("Anti-saccade")
                width: content.width * 0.25
                height: parent.height
                onClicked: runner.start("file:tests/practice-antisaccade-horizontal")
            }

            Neus.Button {
                text: qsTr("Smooth pursuit")
                width: content.width * 0.25
                height: parent.height
                onClicked: runner.start("file:tests/practice-pursuit")
            }
        }
    }
}
