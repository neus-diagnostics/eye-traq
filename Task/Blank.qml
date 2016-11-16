import QtQuick 2.7

Item {
    signal done

    function run(time) {
        timer.interval = time
        timer.start()
    }

    function abort() {
        timer.stop()
    }

    Timer {
        id: timer
        repeat: false
        onTriggered: done()
    }
}
