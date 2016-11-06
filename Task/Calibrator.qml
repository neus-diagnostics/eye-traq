import QtQuick 2.7

Item {
    id: screen

    signal done

    function run(x, y, time, animate) {
        x = Number(x)
        y = Number(y)
        time = Number(time)
        animate = Boolean(animate)

        var screen_x = width*x
        var screen_y = height*y
        var dist_x = screen_x-stimulus.x
        var dist_y = screen_y-stimulus.y
        var dist = Math.sqrt(dist_x*dist_x + dist_y*dist_y)

        moveX.to = screen_x - stimulus.width/2
        moveY.to = screen_y - stimulus.height/2
        if (animate) {
            grow.duration = (stimulus.scale < 1.0 ? 500 : 0)
            moveX.duration = dist
            moveY.duration = dist
            shrink.to = 0.25
            shrink.duration = 1000
        } else {
            grow.duration = 0
            moveX.duration = 0
            moveY.duration = 0
            shrink.to = 1.0
            shrink.duration = 0
        }

        timer.interval = grow.duration + dist + shrink.duration + time
        anim.start()
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
        onTriggered: { anim.stop(); done() }
    }
}
