import QtQuick 2.7
import QtQuick.Controls 2.0

TextArea {
    font.pointSize: 10
    selectByMouse: true
    padding: 4

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 100
        color: "#eae9e5"
        border.color: "#777777"
        border.width: 1
    }
}
