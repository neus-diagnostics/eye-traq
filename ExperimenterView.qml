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
                            calibrate.calibrated = false
                            viewer.plot()
                        }

                        Neus.Button {
                            text: qsTr("New")
                            anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 4 }
                            font.pointSize: 8
                            padding: 4
                            topPadding: 2

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

                    property var calibrated: false
                    property var time: null

                    enabled: eyetracker.connected && participant != ""
                    width: parent.width

                    function end() {
                        if (eyetracker.calibrate("compute")) {
                            var samples = eyetracker.get_calibration()
                            recorder.start(path + "/share/tests/calibrate", participant)
                            recorder.write("# eye\tvalid\tpoint_x\tpoint_y\tgaze_x\tgaze_y")
                            for (var i = 0; i < samples.length; i++)
                                recorder.write(
                                    samples[i].eye + '\t' + samples[i].valid + '\t' +
                                    samples[i].from.x + '\t' + samples[i].from.y + '\t' +
                                    samples[i].to.x + '\t' + samples[i].to.y)
                            recorder.stop()
                            calibrate.calibrated = true
                            calibrate.time = new Date()
                            viewer.plot(samples)
                            notes.log("Calibrated.")
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
                                    if (!calibrate.calibrated)
                                        return qsTr("Not calibrated.");
                                    function pad(n) { return (n < 10 ? "0" : "") + n }
                                    return qsTr("Calibrated at ") +
                                        calibrate.time.getHours() + ':' + pad(calibrate.time.getMinutes()) + "."
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

            // button (with label on right) for running practice / tests
            Component {
                id: testButton

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
                            var testFile = path + "/share/tests/" + modelData.test
                            test.state = "running"
                            recorder.start(testFile, participant)
                            recorder.write(
                                "# time\tevent\t" +
                                "eye\tpupil_valid\tpupil_diameter\t" +
                                "gaze_valid\t" +
                                "gaze_screen_x\tgaze_screen_y\t" +
                                "gaze_ucs_x\tgaze_ucs_y\tgaze_ucs_z\t" +
                                "eye_valid\t" +
                                "eye_ucs_x\teye_ucs_y\teye_ucs_z\t" +
                                "eye_trackbox_x\teye_trackbox_y\teye_trackbox_z\t" +
                                "eyetracker_time")
                            runner.start(testFile)
                            checked = true
                            notes.log("Started " + modelData.test + ".")
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

            // practice
            ColumnLayout {
                id: practice

                Layout.fillWidth: true
                enabled: participant != "" && calibrate.calibrated
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
                        delegate: testButton
                    }
                }
            }

            // test
            ColumnLayout {
                id: test

                enabled: participant != "" && calibrate.calibrated
                spacing: 10
                Layout.fillWidth: true

                Neus.Heading {
                    text: qsTr("Test")
                    Layout.fillWidth: true
                }

                ColumnLayout {
                    anchors.horizontalCenter: parent.horizontalCenter
                    Layout.fillWidth: true

                    Repeater {
                        model: [
                        ]
                        delegate: testButton
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
                        onGaze: {
                            if (data.gaze_valid)
                                viewer.gaze(data.gaze_screen)
                            recorder.write(
                                data.time + '\tgaze\t' + data.eye + '\t' +
                                data.pupil_valid + '\t' + data.pupil_diameter + '\t' +
                                data.gaze_valid + '\t' +
                                data.gaze_screen.x + '\t' + data.gaze_screen.y + '\t' +
                                data.gaze_ucs.x + '\t' + data.gaze_ucs.y + '\t' + data.gaze_ucs.z + '\t' +
                                data.eye_valid + '\t' +
                                data.eye_ucs.x + '\t' + data.eye_ucs.y + '\t' + data.eye_ucs.z + '\t' +
                                data.eye_trackbox.x + '\t' + data.eye_trackbox.y + '\t' + data.eye_trackbox.z + '\t' +
                                data.eyetracker_time)
                        }
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
                        function log(message) {
                            if (text && text.slice(-1) != "\n")
                                text += "\n"
                            text += new Date().toLocaleString(Qt.locale(), "yyyy-MM-dd hh:mm (t)")
                            text += ": " + message + "\n"
                            recorder.setNotes(participant, text)
                        }

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
