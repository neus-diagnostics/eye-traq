import QtQuick 2.7

import "controls" as Neus

Column {
    id: main

    property var options
    property var runner
    property alias gaze: gaze

    anchors.horizontalCenter: parent.horizontalCenter
    spacing: width * 0.02

    // duplicate the participant’s view
    ShaderEffectSource {
        sourceItem: runner
        width: parent.width
        height: width * (secondScreen.height / secondScreen.width)

        Gaze { id: gaze }
    }

    // practice task buttons
    Repeater {
        model: [
            [  // first row with three buttons
                { "text": qsTr("Image pair"), "test": "practice-imgpair" },
                { "text": qsTr("Pro-saccade (H)"), "test": "practice-prosaccade-horizontal" },
                { "text": qsTr("Pro-saccade (V)"), "test": "practice-prosaccade-vertical" },
            ],
            [  // second row with two buttons
                { "text": qsTr("Anti-saccade"), "test": "practice-antisaccade-horizontal" },
                { "text": qsTr("Smooth pursuit"), "test": "practice-pursuit" },
            ]
        ]
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: height * 0.5

            Repeater {
                model: modelData
                Neus.Button {
                    text: modelData.text
                    width: main.width * 0.25
                    onClicked: {
                        runner.start(path + "/share/tests/" + modelData.test)
                        checked = true
                    }
                    Connections {
                        target: options
                        onParticipantChanged: checked = false
                    }
                }
            }
        }
    }
}
