import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import "controls" as Neus

Item {
    property alias participant: txtParticipant.text
    property alias testFile: test.file
    property alias images: images.folder

    Column {
        anchors.left: parent.left
        width: parent.width * 0.6
        spacing: width * 0.02

        Neus.Heading {
            text: qsTr("Subject")
        }
        RowLayout {
            anchors { left: parent.left; leftMargin: parent.spacing }
            spacing: parent.spacing

            // Subject ID input
            Neus.Label { text: qsTr("ID") }
            Neus.TextField {
                id: txtParticipant
                selectByMouse: true
                Layout.fillWidth: true
            }
            Neus.Button {
                text: qsTr("New")

                font.pointSize: 8
                padding: 5
                onClicked: {
                    function pad(n) { return (n < 10 ? "0" : "") + n }
                    var t = new Date()
                    participant = "" + t.getUTCFullYear() + pad(t.getUTCMonth() + 1) + pad(t.getUTCDate()) +
                                  "-" + pad(t.getUTCHours()) + pad(t.getUTCMinutes()) + pad(t.getUTCSeconds()) +
                                  "-" + pad(Math.floor(Math.random() * 100))
                }

            }
        }

        Neus.Heading {
            text: qsTr("Test")
            topPadding: parent.spacing * 4
        }

        GridLayout {
            anchors { left: parent.left; leftMargin: parent.spacing }
            columns: 2
            columnSpacing: parent.spacing
            rowSpacing: parent.spacing

            Neus.Label { text: qsTr("Type") }
            ComboBox {
                id: test
                property var file: model[currentIndex].file
                Layout.fillWidth: true

                model: [
                    { name: "1 minute / trial", file: path + "/share/tests/1minute.py" },
                    { name: "2 minutes / trial", file: path + "/share/tests/2minute.py" },
                ]
                textRole: "name"
            }

            Neus.Label { text: qsTr("Images") }
            ComboBox {
                id: images
                property var folder: model[currentIndex].folder
                Layout.fillWidth: true

                model: [
                    { name: "Set 1", dir: "images/set1" },
                    { name: "Set 2", dir: "images/set2" },
                ]
                textRole: "name"
            }
        }

        // spacer
        Neus.Heading { }

        // idiot button
        Neus.Button {
            anchors.right: parent.right
            text: qsTr("Save")
            onClicked: { console.log("NOP") }
        }
    }
}
