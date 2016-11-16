import QtQuick 2.7

Item {
    id: screen

    signal done
    signal info(string text)

    function run(coord, offset, time, period) {
        time = Number(time)
        offset = Number(offset)
        period = Number(period)

        switch (coord) {
            case 'x':
                left.properties = right.properties = 'x'
                left.to = screen.width * (0.5-offset) - stimulus.width/2
                right.to = screen.width * (0.5+offset) - stimulus.width/2
                stimulus.x = left.to
                stimulus.y = screen.height/2 - stimulus.height/2
                break
            case 'y':
                left.properties = right.properties = 'y'
                left.to = screen.height * (0.5-offset) - stimulus.height/2
                right.to = screen.height * (0.5+offset) - stimulus.height/2
                stimulus.x = screen.width/2 - stimulus.width/2
                stimulus.y = left.to
                break
        }

        left.duration = period / 2
        right.duration = period / 2

        stimulus.visible = true
        timer.interval = time

        anim.start()
        timer.start()
        infoTimer.start()
    }

    function pause() {
        if (timer.running) {
            anim.pause()
            timer.stop()
        }
    }

    function unpause() {
        if (!timer.running) {
            timer.start()
            anim.resume()
        }
    }

    function abort() {
        anim.stop()
        timer.stop()
        infoTimer.stop()
    }

    anchors.fill: parent

    Rectangle {
        id: stimulus
        height: 30
        width: 30
        radius: width/2
        color: "white"
        visible: false

        SequentialAnimation {
            id: anim
            onStopped: stimulus.visible = false

            PauseAnimation { duration: 500 }

            SequentialAnimation {
                loops: Animation.Infinite

                NumberAnimation {
                    id: right
                    target: stimulus
                    easing.type: Easing.InOutSine
                }

                NumberAnimation {
                    id: left
                    target: stimulus
                    easing.type: Easing.InOutSine
                }
            }
        }
    }

    Timer {
        id: timer
        property date startedAt

        onRunningChanged: {
            if (running)
                startedAt = new Date()
            else
                interval -= (new Date() - startedAt)
        }
        onTriggered: { infoTimer.stop(); anim.stop(); done() }
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
