import QtQuick 2.7
import QtQuick.Controls 2.0

Item {
    signal done

    function run(time, text) {
        message.text = text
        timer.interval = time
        timer.start()
    }

    function abort() {
        timer.stop()
    }

    function get_data() {
        return []
    }

    Label {
        id: message
        anchors.centerIn: parent
        color: 'white'
        font.pixelSize: 32
    }

    Timer {
        id: timer
        repeat: false
        onTriggered: done()
    }
}
