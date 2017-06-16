import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import Qt.labs.folderlistmodel 2.1

import "controls" as Neus

Rectangle {
    id: main

    property var runner
    property alias participant: txtParticipant.text

    signal minimize

    Rectangle {
        id: left
        color: "#d6d3cc"
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: main.width * 0.3

        ColumnLayout {
            anchors { top: parent.top; left: parent.left; right: parent.right; bottom: status.top; margins: spacing*2 }
            spacing: parent.width * 0.06

            // participant info & calibration
                Column {
                    Layout.fillWidth: true
                    spacing: 10
                    z: 1  // ensure participant autocomplete dropdown is on top

                    RowLayout {
                        z: 1  // ensure participant autocomplete dropdown is on top
                        anchors { left: parent.left; right: parent.right }
                        spacing: parent.spacing
                        Neus.Label { text: qsTr("ID"); font.pointSize: 13; font.weight: Font.Bold }
                        Neus.AutoComplete {
                            id: txtParticipant
                            anchors.verticalCenter: parent.verticalCenter
                            Layout.fillWidth: true
                            completions: FolderListModel {
                                folder: Qt.resolvedUrl("file:data")
                                showFiles: false
                            }
                            field: "fileName"
                            validator: RegExpValidator { regExp: /[^/]*/ }
                            onTextChanged: {
                                notes.text = recorder.getNotes(text)
                                calibrate.score = null
                                viewer.plot()
                            }

                            Neus.Button {
                                text: qsTr("New")
                                anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 4 }
                                font.pointSize: 8
                                padding: 2
                                topPadding: 1

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        function pad(n) { return (n < 10 ? "0" : "") + n }
                                        var t = new Date()
                                        txtParticipant.text =
                                            "" + t.getUTCFullYear() + pad(t.getUTCMonth() + 1) + pad(t.getUTCDate()) +
                                            "-" + pad(t.getUTCHours()) + pad(t.getUTCMinutes()) + pad(t.getUTCSeconds()) +
                                            "-" + pad(Math.floor(Math.random() * 100))
                                    }
                                }
                            }
                        }
                    }

                    // calibrate
                    RowLayout {
                        id: calibrate

                        property var score: null
                        property var time: null

                        enabled: participant != ""
                        width: parent.width

                        function end() {
                            if (eyetracker.calibrate("compute")) {
                                var data = eyetracker.get_calibration()
                                var score = 0.0
                                recorder.start(path + "/share/tests/calibrate", participant)
                                for (var i = 0; i < data.length; i++) {
                                    var a = data[i].from
                                    var b = data[i].to
                                    recorder.write(
                                        data[i].eye + '\t' + data[i].status + '\t' +
                                        a.x + '\t' + a.y + '\t' + b.x + '\t' + b.y)
                                    score += Math.sqrt((a.x-b.x)*(a.x-b.x) + (a.y-b.y)*(a.y-b.y))
                                }
                                recorder.stop()
                                score /= data.length > 0 ? data.length : 1
                                calibrate.time = new Date()
                                calibrate.score = score
                                viewer.plot(data)
                            } else {
                                viewer.plot([])
                            }
                        }

                        Neus.Label {
                            id: txtCalibrated
                            text: qsTr("Not calibrated.")
                            Layout.fillWidth: true
                        }

                        Neus.Button {
                            text: qsTr("Calibrate")
                            enabled: !runner.running
                            onClicked: {
                                calibrate.state = "running"
                                eyetracker.calibrate("start")
                                runner.start(path + "/share/tests/calibrate")
                            }
                        }
                        states: [
                            State {
                                name: ""
                                PropertyChanges {
                                    target: txtCalibrated
                                    text: {
                                        if (calibrate.score === null)
                                            return qsTr("Not calibrated.");
                                        function pad(n) { return (n < 10 ? "0" : "") + n }
                                        return qsTr("Calibrated at ") +
                                            calibrate.time.getHours() + ':' + pad(calibrate.time.getMinutes()) +
                                            qsTr(", score: ") + calibrate.score.toFixed(2) + "."
                                    }
                                }
                            },
                            State {
                                name: "running"
                                PropertyChanges {
                                    target: runner
                                    onDone: calibrate.end()
                                    onStopped: {
                                        eyetracker.calibrate("stop")
                                        calibrate.state = ""
                                    }
                                }
                                PropertyChanges {
                                    target: txtCalibrated
                                    text: qsTr("Calibrating…")
                                }
                            }
                        ]
                    }
                }

            // practice
            ColumnLayout {
                id: practice

                Layout.fillWidth: true
                enabled: participant != "" && calibrate.score
                spacing: 10

                Neus.Heading {
                    Layout.fillWidth: true
                    text: qsTr("Practice")
                }

                ColumnLayout {
                    anchors.horizontalCenter: parent.horizontalCenter
                    Layout.fillWidth: true

                    Repeater {
                        model: [
                            { "text": qsTr("Fake instructions"), "test": "practice-fake-instructions" },
                            { "text": qsTr("Visual paired comparison"), "test": "practice-imgpair" },
                            { "text": qsTr("Pro-saccade task (horizontal)"), "test": "practice-prosaccade-horizontal" },
                            { "text": qsTr("Pro-saccade task (vertical)"), "test": "practice-prosaccade-vertical" },
                            { "text": qsTr("Anti-saccade task (horizontal)"), "test": "practice-antisaccade-horizontal" },
                            { "text": qsTr("Smooth pursuit (horizontal)"), "test": "practice-pursuit" },
                        ]
                        RowLayout {
                            property alias checked: button.checked
                            enabled: !runner.running
                            spacing: 10

                            Neus.Button {
                                id: button
                                text: checked & !hovered ? "✔" : "▸"
                                font.weight: Font.Bold
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 24

                                onClicked: {
                                    var file = path + "/share/tests/" + modelData.test
                                    practice.state = "running"
                                    recorder.start(file, participant)
                                    runner.start(file)
                                    checked = true
                                }
                            }
                            Neus.Label {
                                text: modelData.text
                                Layout.fillWidth: true
                            }
                            Connections {
                                target: main
                                onParticipantChanged: checked = false
                            }
                        }
                    }
                }

                states: State {
                    name: "running"
                    PropertyChanges {
                        target: runner
                        onInfo: recorder.write(text)
                        onStopped: {
                            recorder.stop()
                            practice.state = ""
                        }
                    }
                    PropertyChanges {
                        target: eyetracker
                        onGazePoint: viewer.gaze(point)
                        tracking: true
                    }
                }
            }

            // test
            ColumnLayout {
                id: test

                enabled: participant != "" && calibrate.score
                spacing: 10
                Layout.fillWidth: true

                Neus.Heading {
                    text: qsTr("Test")
                    Layout.fillWidth: true
                }

                GridLayout {
                    columns: 2

                    Neus.Label { text: qsTr("Test type") }
                    Neus.ComboBox {
                        id: testFile
                        property var file: model[currentIndex].file
                        Layout.fillWidth: true

                        model: [
                        ]
                        textRole: "name"
                    }

                    Neus.Label { text: qsTr("Images"); Layout.row: 2 }
                    Neus.ComboBox {
                        property var folder: model[currentIndex].folder
                        Layout.fillWidth: true

                        model: [
                            { name: "Set 1", dir: "images/set1" },
                            { name: "Set 2", dir: "images/set2" },
                        ]
                        textRole: "name"
                    }

                    Neus.Button {
                        Layout.columnSpan: 2
                        Layout.alignment: Qt.AlignRight
                        text: qsTr("Start")
                        enabled: !runner.running
                        width: main.width * 0.1
                        onClicked: {
                            test.state = "running"
                            recorder.start(testFile.file, participant)
                            runner.start(testFile.file)
                        }
                    }
                }
                states: State {
                    name: "running"
                    PropertyChanges {
                        target: runner
                        onInfo: recorder.write(text)
                        onStopped: {
                            recorder.stop()
                            test.state = ""
                        }
                    }
                    PropertyChanges {
                        target: eyetracker
                        onGazePoint: viewer.gaze(point)
                        tracking: true
                    }
                }
            }

            // notes
            ColumnLayout {
                Layout.fillWidth: true
                enabled: participant != ""
                spacing: 10

                Neus.Heading {
                    Layout.fillWidth: true
                    text: qsTr("Notes")
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5

                    Neus.TextArea {
                        id: notes
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                    Neus.Button {
                        text: "Save"
                        Layout.alignment: Qt.AlignRight
                        onClicked: recorder.setNotes(participant, notes.text)
                    }
                }
            }
        }

        // eyetracker status
        Neus.Label {
            id: status
            text: eyetracker.status
            anchors.bottom: parent.bottom
            width: parent.width
            padding: 10
            horizontalAlignment: Text.AlignHCenter
            Rectangle {
                anchors.top: parent.top
                width: parent.width
                color: "#aaaaaa"
                height: 1
            }
        }
    }

    // runner view
    Rectangle {
        id: right
        anchors { right: parent.right; left: left.right }
        height: parent.height
        color: "#eae9e5"

        Viewer {
            id: viewer
            anchors { fill: parent; margins: main.width * 0.03 * 1.5 }
        }
    }

    // wm buttons
    Row {
        anchors { top: parent.top; right: parent.right }

        layoutDirection: Qt.RightToLeft
        padding: 10
        spacing: 10

        Button {
            text: "×"  // TODO: replace with "❌" (U+274c "close")
            width: height
            padding: 2
            font { pointSize: 12; weight: Font.Bold }
            hoverEnabled: true
            background: Rectangle {
                color: parent.hovered ? "#d6d6d6" : "#e0e0e0"
                border.color: Qt.darker(color, 1.1)
            }
            onClicked: Qt.quit()
        }
        Button {
            text: "–"  // TODO: replace with "⚊" (U+268a "minimize")
            width: height
            padding: 2
            font { pointSize: 12; weight: Font.Bold }
            hoverEnabled: true
            background: Rectangle {
                color: parent.hovered ? "#d6d6d6" : "#e0e0e0"
                border.color: Qt.darker(color, 1.1)
            }
            onClicked: minimize()
        }
    }
}
