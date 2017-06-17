import QtQuick 2.7

Task {
    id: screen

    property var type: "step"
    property var delay: 0
    property var total_time: 0
    property var next: 0

    // delay: show the initial fixation for this long [ms]
    // dir: x/y for horizontal/vertical saccade
    // offset: target displacement from fixation [cm]
    // type: step/gap/overlap
    function run(time, delay, dir, offset, type) {
        time = Number(time)
        delay = Number(delay)
        offset = Number(offset)

        if (dir == 'x') {
            var relative_offset = 10*offset/secondScreen.physicalSize.width
            target.x = (0.5 + relative_offset) * screen.width - target.width / 2
            target.y = (screen.height - target.height) / 2
        } else {
            var relative_offset = 10*offset/secondScreen.physicalSize.height
            target.x = (screen.width - target.width) / 2
            target.y = (0.5 + relative_offset) * screen.height - target.height / 2
        }

        this.type = type
        this.delay = delay
        this.total_time = time

        next = 0
        run_step()
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
                    next++  // fall through if no gap
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
        _run(time)

        info(eyetracker.time() + '\ttest\tdata\t' + fixation.visible + '\t' + target.visible)
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

    Rectangle {
        id: target
        width: 30
        height: 30
        radius: width / 2
        color: "white"
    }
}
