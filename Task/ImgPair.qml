import QtQuick 2.7

Item {
    id: screen

    signal done

    function run(time, leftfile, rightfile) {
        left.source = "../images/" + leftfile
        right.source = "../images/" + rightfile
        timer.interval = time
        timer.start()
    }

    function abort() {
        timer.stop()
    }

    Row {
        anchors.centerIn: parent
        spacing: screen.width / 6

        Image {
            id: left
            height: screen.height / 2
            width: screen.width / 4
        }

        Image {
            id: right
            height: screen.height / 2
            width: screen.width / 4
        }
    }

    Timer {
        id: timer
        repeat: false
        onTriggered: done()
    }
}
