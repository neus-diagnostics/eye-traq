import QtQuick 2.7

Item {
    signal done
    signal info(string text)

    // allow overriding methods
    property var run: _run
    property var abort: _abort
    property var pause: _pause
    property var unpause: _unpause
    property alias timer: timer
    property alias running: timer.running

    function _run(time) {
        // time can be a string when reading test from a file
        timer.interval = Number(time)
        timer.start()
    }

    function _abort() {
        timer.stop()
    }

    function _pause() {
        timer.stop()
    }

    function _unpause() {
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
