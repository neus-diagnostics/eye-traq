import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.0
import QtQuick.Layouts 1.0

ColumnLayout {
    signal calibrate

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
            text: qsTr("Calibrate")
            Layout.fillWidth: true
            onClicked: calibrate()
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
            text: 'file:///home/timotej/src/oculus/build/data/20161015-181121-73/20161015-181121-test1.log'
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
