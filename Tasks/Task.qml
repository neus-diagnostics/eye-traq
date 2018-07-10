import QtQuick 2.7

Item {
    signal done
    signal info(var data)

    // allow overriding methods
    property var run: _run
    property var set: _set
    property var pause: _pause
    property var unpause: _unpause
    property var forward: _forward
    property var back: _back
    property var abort: _abort

    property alias timer: timer
    property alias running: timer.running

    function _run(task) {
        if (task && task.duration !== undefined)
            timer.interval = task.duration
        timer.start()
    }

    function _set(state) {
    }

    function _pause() {
        timer.stop()
    }

    function _unpause() {
        timer.start()
    }

    function _forward() {
        return false
    }

    function _back() {
        return false
    }

    function _abort() {
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
    }
}
