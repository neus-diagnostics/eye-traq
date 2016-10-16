import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.0
import QtQuick.Layouts 1.0

ApplicationWindow {
    id: mainWindow
    visible: true
    title: qsTr("Eyetracker")
    height: 300
    width: 600

    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 10

        GridLayout {
            // ID input
            Label {
                text: qsTr("ID")
                Layout.row: 0
                Layout.column: 0
            }
            TextField {
                id: participant
                selectByMouse: true
                Layout.row: 0
                Layout.column: 1
                Layout.fillWidth: true
            }
            Button {
                id: random
                text: qsTr("Random")
                Layout.row: 0
                Layout.column: 2
                onClicked: {
                    var pad = function (number) {
                        return (number < 10 ? '0' : '') + number
                    }
                    var now = new Date()
                    participant.text = '' +
                        now.getUTCFullYear() +
                        pad(now.getUTCMonth() + 1) +
                        pad(now.getUTCDate()) +
                        '-' +
                        pad(now.getUTCHours()) +
                        pad(now.getUTCMinutes()) +
                        pad(now.getUTCSeconds()) +
                        '-' +
                        pad(Math.floor(Math.random() * 100))
                }
            }

            // name input
            Label {
                text: qsTr("Name")
                Layout.row: 1
                Layout.column: 0
            }
            TextField {
                placeholderText: qsTr("John Smith")
                selectByMouse: true
                Layout.row: 1
                Layout.column: 1
                Layout.columnSpan: 2
                Layout.fillWidth: true
            }

            // age input
            Label {
                text: qsTr("Age")
                Layout.row: 2
                Layout.column: 0
            }
            SpinBox {
                value: 0
                editable: true
                Layout.row: 2
                Layout.column: 1
            }
        }

        // calibrate
        RowLayout {
            Button {
                id: calibrate
                text: qsTr("Calibrate")
                Layout.fillWidth: true
                onClicked: calibrator.start()
            }
        }

        // record
        RowLayout {
            FileDialog {
                id: testFileDialog
                title: "Load test"
                onAccepted: testFile.text = testFileDialog.fileUrl
            }
            TextField {
                id: testFile
                selectByMouse: true
                Layout.fillWidth: true
            }
            Button {
                text: qsTr("…")
                onClicked: testFileDialog.open()
            }
            Button {
                id: record
                text: qsTr("Record")
                onClicked: {
                    if (participant.text == '')
                        random.clicked()
                    recorder.start(testFile.text, participant.text)
                }
            }
        }

        // play
        RowLayout {
            FileDialog {
                id: logFileDialog
                title: "Load recording"
                onAccepted: logFile.text = logFileDialog.fileUrl
            }
            TextField {
                id: logFile
                selectByMouse: true
                Layout.fillWidth: true
            }
            Button {
                text: qsTr("…")
                onClicked: logFileDialog.open()
            }
            Button {
                text: qsTr("Play")
                onClicked: player.start(logFile.text)
            }
        }
    }

    Component.onCompleted: {
        disable()
    }

    onClosing: Qt.quit()

    function disable() {
        calibrate.enabled = false
        record.enabled = false
    }

    function enable() {
        calibrate.enabled = true
        record.enabled = true
    }
}
