import QtQuick 2.7
import QtQuick.Controls 2.0

Item {
    id: screen
    anchors.fill: parent

    signal done()

    Rectangle {
        id: stimulus
        height: 30
        width: 30
        radius: width/2
        color: "red"
        border.color: "black"
        border.width: 2
        y: parent.height/2 - height/2

        SequentialAnimation {
            id: anim
            PauseAnimation {
                duration: 500
            }
            SequentialAnimation {
                id: move
                NumberAnimation {
                    id: right
                    target: stimulus
                    properties: "x"
                    easing.type: Easing.InOutSine
                }
                NumberAnimation {
                    id: left
                    target: stimulus
                    properties: "x"
                    easing.type: Easing.InOutSine
                }
            }
        }
    }

    function run(time, offset, period) {
        offset = Number(offset)
        left.to = screen.width * (0.5-offset) - stimulus.width/2
        right.to = screen.width * (0.5+offset) - stimulus.width/2
        stimulus.x = left.to

        left.duration = period / 2
        right.duration = period / 2

        move.loops = time / period

        // disconnect slot if connected already
        anim.stopped.disconnect(done)
        anim.stopped.connect(done)
        anim.start()
    }

    function abort() {
        // do not continue to next step
        anim.stopped.disconnect(done)
        anim.stop()
    }

    function get_data() {
        return [(stimulus.x + stimulus.width/2) / screen.width]
    }
}
