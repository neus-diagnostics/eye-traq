import QtQuick 2.7
import QtQuick.Controls 2.0

Label {
    width: parent.width
    font { family: "Lato"; pointSize: 12 }

    background: Rectangle {
        Rectangle {
            width: parent.width
            height: 1
            anchors.bottom: parent.bottom
            color: "transparent"
            border.color: "#dddddd"
        }
    }
}
