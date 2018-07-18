import QtQuick 2.11
import QtQuick.Controls 2.1

GazeArea {
    property alias text: label.text
    property alias color: label.color

    property real size
    width: size
    height: size

    opacity: enabled ? (gazed ? 1.0 : 0.8) : 0.2

    Dial {
        anchors { fill: parent; margins: size / 8 }

        value: parent.time
        handle: null

        Label {
            id: label
            anchors.centerIn: parent
            font.pixelSize: 50
        }
    }
}
