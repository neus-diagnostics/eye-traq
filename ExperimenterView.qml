import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

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

        Column {
            anchors { fill: parent; margins: spacing*3/4; leftMargin: spacing }
            spacing: main.width * 0.04

            // options
            Column {
                id: options
                width: parent.width
                spacing: parent.spacing / 4

                Neus.Heading {
                    text: qsTr("Info")
                    font.weight: Font.Bold
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                }

                // subject ID
                Column {
                    width: parent.width
                    Neus.Label { text: qsTr("Subject ID") }
                    Row {
                        spacing: height * 0.2
                        Neus.TextField {
                            id: txtParticipant
                            anchors.verticalCenter: parent.verticalCenter
                            width: main.width * 0.15
                        }
                        Neus.Button {
                            text: qsTr("New")
                            anchors.verticalCenter: parent.verticalCenter
                            font.pointSize: 8
                            padding: 3
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

                // notes
                Column {
                    width: parent.width
                    Neus.Label { text: qsTr("Notes") }
                    Flickable {
                        width: parent.width
                        height: main.height * 0.2
                        TextArea.flickable: Neus.TextArea { wrapMode: TextArea.Wrap }
                        ScrollBar.vertical: ScrollBar { }
                    }
                }
            }

            // eyetracker stuff
            Column {
                width: parent.width
                spacing: parent.spacing / 4

                Column {
                    width: parent.width
                    Neus.Heading {
                        text: qsTr("Test")
                        width: parent.width
                        font.weight: Font.Bold
                        horizontalAlignment: Text.AlignHCenter
                    }
                    TabBar {
                        id: tabs
                        width: parent.width
                        height: 30

                        Neus.TabButton { text: qsTr("Calibrate") }
                        Neus.TabButton { text: qsTr("Practice") }
                        Neus.TabButton { text: qsTr("Run") }

                        background: Rectangle {
                            color: "transparent"
                            Rectangle {
                                width: parent.width
                                height: 1
                                anchors.top: parent.bottom
                                color: "transparent"
                                border.color: "#777777"
                            }
                        }
                    }
                }

                StackLayout {
                    id: page

                    anchors.horizontalCenter: parent.horizontalCenter
                    property alias status: status.text

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    currentIndex: tabs.currentIndex

                    // calibrate
                    ColumnLayout {
                        id: calibrate
                        Layout.fillWidth: true

                        function start() {
                            status.text = qsTr("Calibrating…")
                            viewer.plot()
                            runner.start(path + "/share/tests/calibrate")
                        }

                        function stop() {
                            status.text = qsTr("Calibration aborted.")
                            runner.stop()
                            eyetracker.calibrate("stop")
                        }

                        function end(msg) {
                            var success = eyetracker.calibrate("compute")
                            stop()

                            if (success) {
                                status.text = "Calibration successful."
                                viewer.plot(eyetracker.get_calibration())
                            } else {
                                status.text = "Calibration failed."
                            }
                        }
                        Connections {
                            target: main
                            onParticipantChanged: viewer.plot()
                        }

                        Neus.Label {
                            id: status
                            text: "Not calibrated."
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Neus.Button {
                            text: qsTr("Start")
                            enabled: !runner.running
                            onClicked: calibrate.start()
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    // practice
                    ColumnLayout {
                        width: parent.width / 2
                        Repeater {
                            model: [
                                { "text": qsTr("Image pair"), "test": "practice-imgpair" },
                                { "text": qsTr("Pro-saccade (H)"), "test": "practice-prosaccade-horizontal" },
                                { "text": qsTr("Pro-saccade (V)"), "test": "practice-prosaccade-vertical" },
                                { "text": qsTr("Anti-saccade"), "test": "practice-antisaccade-horizontal" },
                                { "text": qsTr("Smooth pursuit"), "test": "practice-pursuit" },
                            ]
                            Neus.Button {
                                text: modelData.text
                                Layout.fillWidth: true
                                enabled: !runner.running

                                onClicked: {
                                    runner.start(path + "/share/tests/" + modelData.test)
                                    checked = true
                                }
                                Connections {
                                    target: main
                                    onParticipantChanged: checked = false
                                }
                            }
                        }
                    }

                    // test
                    GridLayout {
                        id: test
                        columns: 2

                        function start() {
                            recorder.start(testFile.file, participant)
                            runner.start(testFile.file)
                        }

                        function stop() {
                            runner.stop()
                            recorder.stop()
                        }

                        Connections {
                            target: runner
                            onDone: test.stop()
                        }

                        Neus.Label { text: qsTr("Test type") }
                        ComboBox {
                            id: testFile
                            property var file: model[currentIndex].file
                            Layout.fillWidth: true

                            model: [
                                { name: "1 minute / trial", file: path + "/share/tests/1minute.py" },
                                { name: "2 minutes / trial", file: path + "/share/tests/2minute.py" },
                            ]
                            textRole: "name"
                        }

                        Neus.Label { text: qsTr("Images"); Layout.row: 2 }
                        ComboBox {
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
                            onClicked: test.start()
                        }
                    }
                }
            }
        }
        Neus.Label {
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
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
            left: left.right
        }
        color: "#eae9e5"

        Viewer {
            id: viewer
            anchors.fill: parent
            anchors.rightMargin: main.width * 0.04
            anchors.margins: anchors.rightMargin * 3/4
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
                color: parent.hovered ? "#d0d0d0" : "#e0e0e0"
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
                color: parent.hovered ? "#d0d0d0" : "#e0e0e0"
            }
            onClicked: minimize()
        }
    }

    states: [
        State {
            name: "calibrate"
            when: tabs.currentIndex == 0
            PropertyChanges {
                target: runner
                onDone: calibrate.end()
            }
        },
        State {
            name: "practice"
            when: tabs.currentIndex == 1
            PropertyChanges {
                target: eyetracker
                tracking: true
                onGazePoint: viewer.gaze(point)
            }
        },
        State {
            name: "test"
            when: tabs.currentIndex == 2
            PropertyChanges {
                target: eyetracker
                tracking: true
                onGazePoint: viewer.gaze(point)
            }
        }
    ]
}
