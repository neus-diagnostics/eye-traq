import QtQuick 2.7
import QtQuick.Controls 2.0

Label {
    font {
        family: "Lato"
        pointSize: 14
        capitalization: Font.AllUppercase
    }

    background: Rectangle {
        color: "transparent"
        Rectangle {
            width: parent.width
            height: 1
            anchors.bottom: parent.bottom
            color: "transparent"
            border.color: "#777777"
        }
    }
}
