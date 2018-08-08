import QtQuick 2.7
import QtQuick.Controls 2.1

Task {
    id: control

    property var sequence: []
    property var answer: []

    run: function (task) {
        set(task)
        answer = []
        if (task.duration !== undefined) {
            _run(task)
            control.enabled = false
        } else {
            control.enabled = true
        }
    }

    // state data
    // choices: a list of strings or objects {image: path}
    // sequence: correct sequence of choices
    set: function (state) {
        if (state.choices !== undefined) {
            choices.model = [] // reset highlighted choices
            choices.model = state.choices
        }
        if (state.sequence !== undefined)
            sequence = state.sequence
    }

    timer.onTriggered: done()

    Grid {
        anchors.centerIn: parent
        columns: 2
        horizontalItemAlignment: Qt.AlignHCenter
        verticalItemAlignment: Qt.AlignVCenter
        spacing: Math.min(control.width, control.height) / 6

        Repeater {
            id: choices

            delegate: GazeArea {
                selectTime: 1.5
                width: control.width / 4
                height: control.height / 4
                enabled: control.enabled

                onSelected: {
                    info(eyetracker.time(), {'action': 'select', 'answer': index})
                    answer.push(index)
                    answerChanged()
                    enabled = false
                    loader.item.highlight()
                    if (answer.length === sequence.length) {
                        // selected the correct number of items – emit done() after a short pause
                        control.enabled = false
                        _run({duration: 2000})
                    }
                }

                Loader {
                    id: loader
                    anchors.fill: parent
                    sourceComponent: typeof modelData === 'string' || typeof modelData === 'number' ? label : image
                }

                Component {
                    id: label
                    Rectangle {
                        function highlight() {
                            color = '#333a66'
                        }
                        color: '#333333'
                        anchors.fill: parent

                        Label {
                            text: modelData
                            anchors.centerIn: parent
                            color: 'white'
                            font.pixelSize: 40
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }

                Component {
                    id: image
                    Rectangle {
                        function highlight() {
                            color = '#333a66'
                        }
                        color: '#333333'
                        anchors.fill: parent

                        Image {
                            source: 'file:///' + path + '/share/images/' + modelData.image
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectFit
                        }
                    }
                }

                Border {
                    size: 0.15
                    visible: parent.gazed
                }
            }
        }
    }
}
