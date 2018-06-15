import QtQuick 2.7
import QtQuick.Controls 2.0

Label {
    font {
        pixelSize: 18
        capitalization: Font.AllUppercase
        weight: Font.Bold
    }

    background: Rectangle {
        color: "transparent"
        Rectangle {
            width: parent.width
            height: 1
            anchors.bottom: parent.bottom
            color: "transparent"
            border.color: "#aaaaaa"
        }
    }
}
