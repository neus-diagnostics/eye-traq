import QtQuick 2.7
import QtQuick.Controls 2.0

Item {
    signal done

    function run(time, text) {
        message.text = text
        timer.interval = time
        timer.start()
    }

    function pause() {
        timer.stop()
    }

    function unpause() {
        timer.start()
    }

    function abort() {
        timer.stop()
    }

    Label {
        id: message
        anchors.centerIn: parent
        color: 'white'
        font.pixelSize: 32
    }

    Timer {
        id: timer
        property date startedAt

        onRunningChanged: {
            if (running)
                startedAt = new Date()
            else
                interval -= (new Date() - startedAt)
        }
        onTriggered: done()
    }
}
