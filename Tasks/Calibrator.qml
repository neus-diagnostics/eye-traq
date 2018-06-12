import QtQuick 2.7

Task {
    id: screen

    property var point: null

    // task arguments: action (start/add/end), x (relative), y (relative)
    function run(task) {
        var screen_x = width*task.x
        var screen_y = height*task.y
        var dist_x = screen_x-stimulus.x
        var dist_y = screen_y-stimulus.y

        var target_x = screen_x - stimulus.width/2
        var target_y = screen_y - stimulus.height/2

        if (task.action == "start") {
            stimulus.x = target_x
            stimulus.y = target_y
            stimulus.scale = 1.0
            point = null
        } else if (task.action == "end") {
            // wait some time for the final calibrate call to finish
            point = null
        } else {
            moveX.to = target_x
            moveY.to = target_y
            pause.duration = (stimulus.scale < 1.0 ? 1000 : 0)
            grow.duration = (stimulus.scale < 1.0 ? 500 : 0)
            moveX.duration = task.duration - (pause.duration + grow.duration + shrink.duration)
            point = Qt.point(task.x, task.y)
            anim.start()
        }
        _run(task)
    }

    function abort() {
        anim.stop()
        _abort()
    }

    anchors.fill: parent

    Rectangle {
        id: stimulus
        width: 30
        height: 30
        radius: width/2
        color: "white"
        x: screen.width/2 - width/2
        y: screen.height/2 - height/2

        SequentialAnimation {
            id: anim
            running: false
            paused: running && !timer.running
            PauseAnimation {
                id: pause
            }
            NumberAnimation {
                id: grow
                target: stimulus
                property: "scale"
                to: 1.0
            }
            ParallelAnimation {
                NumberAnimation {
                    id: moveX;
                    target: stimulus;
                    property: "x";
                    easing.type: Easing.InOutSine
                }
                NumberAnimation {
                    id: moveY;
                    duration: moveX.duration // synchronize with X animation
                    target: stimulus;
                    property: "y";
                    easing.type: Easing.InOutSine
                }
            }
            NumberAnimation {
                id: shrink
                target: stimulus
                property: "scale"
                to: 0.25
                duration: 1000
            }
        }
    }

    timer.onTriggered: {
        anim.stop()
        if (point)
            eyetracker.calibrate(point)
        done()
    }
}
