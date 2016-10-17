import QtQml 2.2
import QtQuick 2.7
import QtQuick.Controls 2.0

Item {
    signal done

    function run(time) {
        timer.interval = time
        timer.start()
    }

    function abort() {
        timer.stop()
    }

    function get_data() {
        return []
    }

    Timer {
        id: timer
        repeat: false
        onTriggered: done()
    }
}
