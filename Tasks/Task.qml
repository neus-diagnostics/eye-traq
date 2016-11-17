import QtQuick 2.7

Item {
    signal done
    signal info(string text)

    // allow overriding run() and abort()
    property var run: _run
    property var abort: _abort
    property alias timer: timer

    function _run(time) {
        // time can be a string when reading test from a file
        timer.interval = Number(time)
        timer.start()
    }

    function _abort() {
        timer.stop()
    }

    function pause() {
        timer.stop()
    }

    function unpause() {
        timer.start()
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
    }
}
