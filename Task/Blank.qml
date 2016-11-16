import QtQuick 2.7

Item {
    signal done

    function run(time) {
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
