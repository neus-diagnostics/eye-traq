import QtQuick 2.7

Task {
    id: screen

    property var fade: 150

    // task arguments: left (image name), right (image name)
    function run(task) {
        left.source = "file:///" + path + "/share/images/" + task.left
        right.source = "file:///" + path + "/share/images/" + task.right

        pause.duration = task.duration - 2*fade
        opacity = 0
        anim.restart()
        _run(task)
    }

    // state data: left, right
    function set(state) {
        left.source = "file:///" + path + "/share/images/" + state.left
        right.source = "file:///" + path + "/share/images/" + state.right
        opacity = 1
    }

    function abort() {
        anim.stop()
        _abort()
    }

    function pause() {
        anim.pause()
        _pause()
    }

    function unpause() {
        anim.resume()
        _unpause()
    }

    timer.onTriggered: done()

    Row {
        anchors.centerIn: parent
        spacing: screen.width / 6

        Rectangle {
            color: "#dddddd"
            height: width * 10/8
            width: screen.width / 4
            Image {
                id: left
                anchors.fill: parent
                sourceSize { width: width; height: height }
            }
        }

        Rectangle {
            color: "#dddddd"
            height: width * 10/8
            width: screen.width / 4
            Image {
                id: right
                anchors.fill: parent
                sourceSize { width: width; height: height }
            }
        }
    }

    SequentialAnimation on opacity {
        id: anim
        NumberAnimation { from: 0; to: 1; duration: fade }
        PauseAnimation { id: pause }
        NumberAnimation { from: 1; to: 0; duration: fade }
    }
}
