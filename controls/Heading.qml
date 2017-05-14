import QtQuick 2.7
import QtQuick.Controls 2.0

Label {
    font {
        family: "Lato"
        pointSize: 13
        capitalization: Font.AllUppercase
        weight: Font.Bold
    }

    background: Rectangle {
        color: "transparent"
        Rectangle {
            anchors { left: parent.left; right: parent.right }
            height: 1
            anchors.bottom: parent.bottom
            color: "transparent"
            border.color: "#777777"
        }
    }
}
