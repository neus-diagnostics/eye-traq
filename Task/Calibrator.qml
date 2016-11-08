import QtQuick 2.7

Item {
    id: screen

    property var point: null

    signal done

    function run(x, y, time, animate) {
        x = Number(x)
        y = Number(y)
        time = Number(time)
        animate = animate == "true"

        var screen_x = width*x
        var screen_y = height*y
        var dist_x = screen_x-stimulus.x
        var dist_y = screen_y-stimulus.y
        var dist = Math.sqrt(dist_x*dist_x + dist_y*dist_y)

        var target_x = screen_x - stimulus.width/2
        var target_y = screen_y - stimulus.height/2
        timer.interval = time

        if (animate) {
            grow.duration = (stimulus.scale < 1.0 ? 500 : 0)
            moveX.to = target_x
            moveY.to = target_y
            moveX.duration = dist
            moveY.duration = dist
            shrink.to = 0.25
            shrink.duration = 1000
            point = Qt.point(x, y)
            timer.interval += grow.duration + dist + shrink.duration
            anim.start()
        } else {
            stimulus.x = target_x
            stimulus.y = target_y
            stimulus.scale = 1.0
            point = null
        }

        timer.start()
    }

    function abort() {
        anim.stop()
        timer.stop()
    }

    function get_data() {
        return [
            (stimulus.x + stimulus.width/2) / screen.width,
            (stimulus.y + stimulus.height/2) / screen.height,
        ]
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
            NumberAnimation {
                id: grow
                target: stimulus
                property: "scale"
                to: 1.0
                duration: 500
            }
            ParallelAnimation {
                NumberAnimation { id: moveX; target: stimulus; property: "x" }
                NumberAnimation { id: moveY; target: stimulus; property: "y" }
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

    Timer {
        id: timer
        repeat: false
        onTriggered: {
            anim.stop()
            if (point)
                eyetracker.calibrate(point)
            done()
        }
    }
}
