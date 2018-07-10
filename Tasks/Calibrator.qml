import QtQuick 2.7

import '..'

Task {
    property var point: null

    // task arguments: action (start/add/end), x (relative), y (relative)
    run: function (task) {
        if (task.action == "start") {
            stimulus.normalX = task.x
            stimulus.normalY = task.y
            stimulus.scale = 1.0
            point = null
        } else if (task.action == "end") {
            // wait some time for the final calibrate call to finish
            point = null
        } else {
            moveX.to = task.x
            moveY.to = task.y
            pause.duration = (stimulus.scale < 1.0 ? 1000 : 0)
            grow.duration = (stimulus.scale < 1.0 ? 500 : 0)
            moveX.duration = task.duration - (pause.duration + grow.duration + shrink.duration)
            point = Qt.point(task.x, task.y)
            anim.start()
        }
        _run(task)
    }

    abort: function () {
        anim.stop()
        _abort()
    }

    anchors.fill: parent

    Dot {
        id: stimulus

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
                    property: "normalX";
                    easing.type: Easing.InOutSine
                }
                NumberAnimation {
                    id: moveY;
                    duration: moveX.duration // synchronize with X animation
                    target: stimulus;
                    property: "normalY";
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
