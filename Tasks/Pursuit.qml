import QtQuick 2.7

import '..'

Task {
    // task arguments
    // direction: x/y for horizontal/vertical saccade
    // offset: target displacement from fixation [cm]
    // period: travel time from left to right and back
    run: function (task) {
        var relative_offset = 0.0;
        if (task.direction === 'x') {
            init.property = 'normalX'
            relative_offset = 10*task.offset / secondScreen.physicalSize.width
        } else if (task.direction === 'y') {
            init.property = 'normalY'
            relative_offset = 10*task.offset / secondScreen.physicalSize.height
        }
        left.to = 0.5 - relative_offset
        init.to = right.to = 0.5 + relative_offset
        init.duration = task.period / 3
        left.duration = right.duration = task.period / 2

        set({})
        anim.start()
        _run(task)
    }

    // state data: x (relative), y (relative)
    set: function (state) {
        stimulus.normalX = state.x || 0.5
        stimulus.normalY = state.y || 0.5
    }

    abort: function () {
        anim.stop()
        _abort()
    }

    timer.onTriggered: {
        anim.stop()
        done()
    }

    Dot {
        id: stimulus

        onNormalXChanged: info({'x': stimulus.normalX, 'y': stimulus.normalY})
        onNormalYChanged: info({'x': stimulus.normalX, 'y': stimulus.normalY})

        SequentialAnimation {
            id: anim

            paused: running && !timer.running

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
                    property: init.property
                    easing.type: Easing.InOutSine
                }

                NumberAnimation {
                    id: right
                    target: stimulus
                    property: init.property
                    easing.type: Easing.InOutSine
                }
            }
        }
    }
}
