import QtQuick 2.7

Task {
    id: screen

    function run(time, leftfile, rightfile) {
        left.source = path + "/share/images/" + leftfile
        right.source = path + "/share/images/" + rightfile
        _run(time)
    }

    timer.onTriggered: done()

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
}
