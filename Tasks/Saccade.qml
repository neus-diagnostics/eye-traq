import QtQuick 2.7

Task {
    id: screen

    property var gap: true
    property var overlap: true
    property var start_time: 0
    property var total_time: 0
    property var next: 0

    function run(time, dir, offset, gap, overlap) {
        time = Number(time)
        offset = Number(offset)

        if (dir == 'x') {
            target.x = (0.5 + offset) * screen.width - target.width / 2
            target.y = (screen.height - target.height) / 2
        } else {
            target.x = (screen.width - target.width) / 2
            target.y = (0.5 + offset) * screen.height - target.height / 2
        }

        this.gap = (gap == "true")
        this.overlap = (overlap == "true")
        this.start_time = 2500 + Math.random() * 1000
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
                time = start_time
                break
            case 1:
                if (gap) {
                    fixation.visible = false
                    time = 200
                    break
                } else {
                    next++  // fall through if no gap
                }
            case 2:
                fixation.visible = overlap
                target.visible = true
                time = 1000
                break
            case 3:
                fixation.visible = true
                target.visible = false
                time = total_time - (start_time + 1000 + (gap ? 200 : 0))
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
