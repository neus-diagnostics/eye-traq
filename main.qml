import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.0
import QtQuick.Layouts 1.0

ApplicationWindow {
    id: mainWindow

    function disable() {
        calibrate.enabled = record.enabled = false
    }

    function enable() {
        calibrate.enabled = record.enabled = true
    }

    function random_id() {
        function pad(number) {
            return (number < 10 ? '0' : '') + number
        }
        var t = new Date()
        return '' + t.getUTCFullYear() + pad(t.getUTCMonth() + 1) + pad(t.getUTCDate()) +
               '-' + pad(t.getUTCHours()) + pad(t.getUTCMinutes()) + pad(t.getUTCSeconds()) +
               '-' + pad(Math.floor(Math.random() * 100))
    }

    visible: true
    title: qsTr("Eyetracker")
    height: 300
    width: 600

    onClosing: Qt.quit()

    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 10

        GridLayout {
            // ID input
            Label {
                text: qsTr("ID")
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
                onClicked: participant.text = random_id()
            }

            // name input
            Label {
                text: qsTr("Name")
                Layout.row: 1
                Layout.column: 0
            }
            TextField {
                id: name
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
                id: age
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
        //disable()
    }
}
