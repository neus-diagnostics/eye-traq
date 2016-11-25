import QtQuick 2.7
import QtQuick.Controls 2.0

import "../controls" as Neus

Task {
    function run(time, text) {
        message.text = text
        _run(time)
    }

    timer.onTriggered: done()

    Neus.Label {
        id: message
        anchors.centerIn: parent
        width: parent.width * 0.6
        wrapMode: Text.WordWrap
        color: 'white'
        font.pointSize: 24
        lineHeight: 1.2
    }
}
