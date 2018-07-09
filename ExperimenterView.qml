import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import Qt.labs.folderlistmodel 2.1
import Qt.labs.settings 1.0

import "controls" as Neus

Rectangle {
    id: main

    property var runner
    property alias participant: txtParticipant.text

    signal minimize

    // record info about the hardware and software used in the test
    function write_test_header() {
        recorder.write("# program version: " + version)
        recorder.write("# eyetracker: " + eyetracker.name)
        recorder.write("# screen size: " + secondScreen.physicalSize.width + " " + secondScreen.physicalSize.height)
        recorder.write("# screen resolution: " + secondScreen.size.width + " " + secondScreen.size.height)
        recorder.write("# time: " + eyetracker.time())
    }

    Rectangle {
        id: left
        color: "#d6d3cc"
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: main.width * 0.3

        ColumnLayout {
            anchors { top: parent.top; left: parent.left; right: parent.right; bottom: status.top; margins: spacing }
            spacing: 20

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
                            notes.load(recorder.getNotes(text))
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
                            recorder.start("calibrate-" + settings.language, participant)
                            write_test_header()
                            for (var i = 0; i < samples.length; i++)
                                recorder.write(JSON.stringify(samples[i])) // TODO check this with eyetracker
                            recorder.stop()
                            calibrate.calibrated = true
                            calibrate.time = new Date()
                            viewer.plot(samples)
                            notes.append("Calibrated.")
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
                            runner.start(path + "/share/tests/calibrate-" + settings.language + '.json')
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
                            var testName = modelData.test + "-" + settings.language
                            var testFile = path + "/share/tests/" + testName + '.json'
                            test.state = "running"
                            recorder.start(testName, participant)
                            write_test_header()
                            runner.start(testFile)
                            checked = true
                            notes.append("Started " + testName + ".")
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

            // test
            ColumnLayout {
                id: test

                enabled: participant != "" && calibrate.calibrated
                spacing: 10
                Layout.fillHeight: false
                Layout.fillWidth: true

                Neus.Heading {
                    text: qsTr("Test")
                    Layout.fillWidth: true
                }

                // language
                RowLayout {
                    anchors { left: parent.left; right: parent.right }
                    spacing: parent.spacing
                    enabled: !runner.running

                    Neus.Label { text: qsTr("Language") }
                    Neus.ComboBox {
                        model: [
                            { "text": "Croatian", "language": "hr" },
                            { "text": "Slovene", "language": "sl" },
                        ]
                        onActivated: settings.language = model[currentIndex]["language"]
                        Component.onCompleted: {
                            for (var i = 0; i < model.length; i++) {
                                if (model[i]["language"] == settings.language) {
                                    currentIndex = i;
                                    break;
                                }
                            }
                        }
                        textRole: "text"
                        Layout.fillWidth: true
                    }
                }

                Neus.Label {
                    text: qsTr("Practice")
                    font { pointSize: 11; capitalization: Font.MixedCase; weight: Font.Bold }
                    Layout.fillWidth: true
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

                Neus.Label {
                    text: qsTr("Tests")
                    font { weight: Font.Bold }
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
                        onInfo: recorder.write(time + '\t' + JSON.stringify({'time': time, 'type': 'test', 'test': message}))
                        onStopped: {
                            recorder.stop()
                            test.state = ""
                        }
                    }
                    PropertyChanges {
                        target: eyetracker
                        onGaze: {
                            viewer.gaze(
                                data.left.gaze_valid ? data.left.gaze_screen : null,
                                data.right.gaze_valid ? data.right.gaze_screen : null
                            )
                            recorder.write(data.time + '\t' + JSON.stringify({'time': data.time, 'type': 'gaze', 'gaze': data}))
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

                        property var modified: false

                        function append(message) {
                            if (text && text.slice(-1) != "\n")
                                text += "\n"
                            text += new Date().toLocaleString(Qt.locale(), "yyyy-MM-dd hh:mm (t)")
                            text += ": " + message + "\n"
                            cursorPosition = text.length
                        }

                        function save() {
                            recorder.setNotes(participant, text)
                            modified = false
                        }

                        function load(text) {
                            notes.text = text
                            modified = false
                        }

                        onTextChanged: modified = true

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    Neus.Button {
                        text: "Save"
                        enabled: notes.modified
                        onClicked: notes.save()
                        Layout.alignment: Qt.AlignRight
                    }
                }
            }
        }

        // eyetracker status
        Neus.Label {
            id: status
            text: eyetracker.connected ? qsTr("Eyetracker connected.") : qsTr("Eyetracker disconnected.")
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
        spacing: padding

        // passing functions does not work directly in model: below
        property var buttons: [
            { "text": "❌", "click": Qt.quit},
            { "text": "⚊", "click": minimize},
        ]
        Repeater {
            model: parent.buttons
            delegate: Button {
                width: height
                bottomPadding: padding + 2
                padding: 2
                background: Rectangle {
                    color: parent.hovered ? "#d6d6d6" : "#e0e0e0"
                    border.color: Qt.darker(color, 1.1)
                }
                hoverEnabled: true
                font.pointSize: 10
                text: modelData.text
                onClicked: parent.buttons[index].click()
            }
        }
    }

    Settings {
        id: settings
        property string language: "sl"
    }
}
