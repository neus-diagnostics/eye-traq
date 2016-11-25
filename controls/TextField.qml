import QtQuick 2.7
import QtQuick.Controls 2.0

TextField {
    font.pointSize: 12
    padding: 2

    background: Rectangle {
        implicitWidth: 200

        Rectangle {
            width: parent.width
            height: 2
            anchors.bottom: parent.bottom
            color: "transparent"
            border.color: "#777777"
            border.width: 2
        }
    }
}
