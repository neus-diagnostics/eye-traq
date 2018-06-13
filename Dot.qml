import QtQuick 2.7

Rectangle {
    // position from 0.0 to 1.0
    property real normalX
    property real normalY

    x: normalX * parent.width - radius
    y: normalY * parent.height - radius

    radius: 15
    width: radius*2
    height: radius*2
    color: 'white'
    border { color: Qt.darker(color); width: 1 }
}
