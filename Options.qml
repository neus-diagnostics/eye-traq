import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.0
import QtQuick.Layouts 1.0

Item {
    property alias participant: txtParticipant.text
    property alias testFile: dlgTestFile.fileUrl

    function random_id() {
        function pad(number) {
            return (number < 10 ? "0" : "") + number
        }
        var t = new Date()
        return "" + t.getUTCFullYear() + pad(t.getUTCMonth() + 1) + pad(t.getUTCDate()) +
               "-" + pad(t.getUTCHours()) + pad(t.getUTCMinutes()) + pad(t.getUTCSeconds()) +
               "-" + pad(Math.floor(Math.random() * 100))
    }

    GridLayout {
        anchors.centerIn: parent
        columns: 3

        // ID input
        Label { text: qsTr("ID") }
        TextField {
            id: txtParticipant
            selectByMouse: true
            Layout.fillWidth: true
        }
        Button {
            text: qsTr("Random")
            onClicked: participant = random_id()
        }
    
        // testfile selection
        FileDialog {
            id: dlgTestFile
            title: "Load test"
        }
        Label { text: qsTr("Test") }
        TextField {
            text: testFile
            selectByMouse: true
            Layout.fillWidth: true
        }
        Button {
            text: qsTr("…")
            onClicked: dlgTestFile.open()
        }
    }
}
