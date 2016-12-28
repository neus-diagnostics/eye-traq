import QtQuick 2.7

Task {
    id: screen

    // dir: x/y for horizontal/vertical saccade
    // offset: target displacement from fixation [cm]
    // period: travel time from left to right and back
    function run(time, dir, offset, period) {
        offset = Number(offset)
        period = Number(period)

        init.duration = period / 3
        left.duration = right.duration = period / 2
        init.properties = left.properties = right.properties = dir
        if (dir == "x") {
            var relative_offset = 10*offset/secondScreen.physicalSize.width
            left.to = screen.width * (0.5-relative_offset) - stimulus.width/2
            init.to = right.to = screen.width * (0.5+relative_offset) - stimulus.width/2
        } else {
            var relative_offset = 10*offset/secondScreen.physicalSize.height
            left.to = screen.height * (0.5-relative_offset) - stimulus.height/2
            init.to = right.to = screen.height * (0.5+relative_offset) - stimulus.height/2
        }

        stimulus.x = screen.width/2 - stimulus.width/2
        stimulus.y = screen.height/2 - stimulus.height/2
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
            info(eyetracker.time() + '\ttest\tdata\t'
                 + ((stimulus.x + stimulus.width/2) / screen.width) + '\t'
                 + ((stimulus.y + stimulus.height/2) / screen.height) + '\t')
        }
    }
}
