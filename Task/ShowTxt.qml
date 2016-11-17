import QtQuick.Controls 2.0

Task {
    function run(time, text) {
        message.text = text
        _run(time)
    }

    timer.onTriggered: done()

    Label {
        id: message
        anchors.centerIn: parent
        color: 'white'
        font.pixelSize: 32
    }
}
