import QtQuick 2.7
import QtQuick.Controls 2.0

TextField {
    font.pointSize: 12
    font.family: "Lato"
    padding: 4
    leftPadding: padding + 4
    rightPadding: leftPadding
    selectByMouse: true
    selectionColor: "lightsteelblue"

    background: Rectangle {
        implicitWidth: 200
        color: "#eae9e5"
        border.color: "#777777"
        border.width: 1
    }
}
