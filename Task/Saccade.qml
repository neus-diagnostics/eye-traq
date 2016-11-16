import QtQuick 2.7

Item {
    id: screen

    signal done
    signal info(string text)

    property var gap: true
    property var overlap: true
    property var start_time: 0
    property var next: 0

    function run(dir, offset, gap, overlap) {
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

        next = 0
        run_step()
    }

    function run_step() {
        switch (next) {
            case 0:
                target.visible = false
                fixation.visible = true
                timer.interval = start_time
                break
            case 1:
                if (gap) {
                    fixation.visible = false
                    timer.interval = 200
                    break
                } else {
                    next++  // fall through if no gap
                }
            case 2:
                fixation.visible = overlap
                target.visible = true
                timer.interval = 1000
                break
            case 3:
                fixation.visible = true
                target.visible = false
                timer.interval = 8000 - (start_time + 1000 + (gap ? 200 : 0))
                break
            case 4:
                done()
                return
        }
        timer.start()

        info(eyetracker.time() + '\tdata\t' + fixation.visible + '\t' + target.visible)
        next++
    }

    function abort() {
        timer.stop()
    }

    anchors.fill: parent

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

    Timer {
        id: timer
        repeat: false
        onTriggered: run_step()
    }
}
