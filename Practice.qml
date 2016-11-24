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

        // practice task buttons
        Repeater {
            model: [
                [  // first row with three buttons
                    { "text": qsTr("Image pair"), "test": "file:tests/practice-imgpair" },
                    { "text": qsTr("Pro-saccade (H)"), "test": "file:tests/practice-prosaccade-horizontal" },
                    { "text": qsTr("Pro-saccade (V)"), "test": "file:tests/practice-prosaccade-vertical" },
                ],
                [  // second row with two buttons
                    { "text": qsTr("Anti-saccade"), "test": "file:tests/practice-antisaccade-horizontal" },
                    { "text": qsTr("Smooth pursuit"), "test": "file:tests/practice-pursuit" },
                ]
            ]
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: height * 0.5

                Repeater {
                    model: modelData
                    Neus.Button {
                        text: modelData.text
                        width: content.width * 0.25
                        height: firstScreen.height * 0.04
                        onClicked: runner.start(modelData.test)
                    }
                }
            }
        }
    }
}
