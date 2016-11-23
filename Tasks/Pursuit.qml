import QtQuick 2.7

Task {
    id: screen

    function run(coord, offset, time, period) {
        offset = Number(offset)
        period = Number(period)

        stimulus.x = screen.width/2
        stimulus.y = screen.height/2
        switch (coord) {
            case 'x':
                init.properties = left.properties = right.properties = 'x'
                left.to = screen.width * (0.5-offset) - stimulus.width/2
                init.to = right.to = screen.width * (0.5+offset) - stimulus.width/2
                break
            case 'y':
                init.properties = left.properties = right.properties = 'y'
                left.to = screen.height * (0.5-offset) - stimulus.height/2
                init.to = right.to = screen.height * (0.5+offset) - stimulus.height/2
                break
        }
        init.duration = period / 4
        left.duration = right.duration = period / 2
        stimulus.visible = true

        anim.start()
        infoTimer.start()
        _run(time)
    }

    function abort() {
        anim.stop()
        infoTimer.stop()
        _abort()
    }

    timer.onTriggered: {
        infoTimer.stop()
        anim.stop()
        done()
    }

    Rectangle {
        id: stimulus
        height: 30
        width: 30
        radius: width/2
        color: "white"
        visible: false

        SequentialAnimation {
            id: anim

            paused: running && !timer.running
            onStopped: stimulus.visible = false

            PauseAnimation { duration: 500 }

            NumberAnimation {
                id: init
                target: stimulus
                easing.type: Easing.InOutSine
            }

            SequentialAnimation {
                loops: Animation.Infinite

                NumberAnimation {
                    id: left
                    target: stimulus
                    easing.type: Easing.InOutSine
                }

                NumberAnimation {
                    id: right
                    target: stimulus
                    easing.type: Easing.InOutSine
                }
            }
        }
    }

    Timer {
        id: infoTimer
        interval: 1000/60
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            info(eyetracker.time() + '\tdata\t'
                 + ((stimulus.x + stimulus.width/2) / screen.width) + '\t'
                 + ((stimulus.y + stimulus.height/2) / screen.height) + '\t')
        }
    }
}
