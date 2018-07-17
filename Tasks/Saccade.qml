import QtQuick 2.7

import '..'

Task {
    property var type: "step"
    property var delay: 0
    property var total_time: 0
    property var next: 0

    // task arguments:
    // delay: show the initial fixation for this long [ms]
    // direction: x/y for horizontal/vertical saccade
    // offset: target displacement from fixation [cm]
    // type: step/gap/overlap
    run: function (task) {
        type = task.type
        delay = task.delay
        total_time = task.duration

        if (task.direction == 'x')
            task.x = 0.5 + 10*task.offset / secondScreen.physicalSize.width
        else
            task.y = 0.5 + 10*task.offset / secondScreen.physicalSize.height

        set(task)
        next = 0
        run_step()
    }

    // state data: direction, relative_offset
    // fixation: show fixation cross?
    // target: show target disc?
    set: function (state) {
        target.normalX = state.x || 0.5
        target.normalY = state.y || 0.5
        fixation.visible = state.fixation || false
        target.visible = state.target || false
    }

    function run_step() {
        var time = 0;
        switch (next) {
            case 0:
                target.visible = false
                fixation.visible = true
                time = delay
                break
            case 1:
                if (type == "gap") {
                    fixation.visible = false
                    time = 200
                    break
                } else {
                    next++  // fall through – skip this step if there is no gap
                }
            case 2:
                fixation.visible = type == "overlap"
                target.visible = true
                time = 1000
                break
            case 3:
                fixation.visible = true
                target.visible = false
                time = total_time - (delay + 1000 + (type == "gap" ? 200 : 0))
                break
            case 4:
                done()
                return
        }
        _run({'duration': time})

        info(eyetracker.time(), {
            'x': target.normalX,
            'y': target.normalY,
            'fixation': fixation.visible,
            'target': target.visible
        })
        next++
    }

    timer.onTriggered: run_step()

    Item {
        id: fixation

        width: 30
        height: 30

        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        Rectangle {
            width: 30
            height: 4
            color: "white"
            y: (parent.height - height) / 2
        }

        Rectangle {
            width: 4
            height: 30
            color: "white"
            x: (parent.width - width) / 2
        }
    }

    Dot {
        id: target
    }
}
