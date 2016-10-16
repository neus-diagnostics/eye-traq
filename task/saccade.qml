import QtQml 2.2
import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.2

Item {
    id: screen
    anchors.fill: parent

    signal done()

    Rectangle {
        width: 30
        height: 30
	color: "transparent"

        id: fixation
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        Rectangle {
            width: 30
            height: 4
            color: "transparent"
            border.color: "white"
            border.width: 2
            y: (parent.height - height) / 2
        }

        Rectangle {
            width: 4
            height: 30
            color: "transparent"
            border.color: "white"
            border.width: 2
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
        onTriggered: next()
    }

    property var gap: true
    property var overlap: true
    property var start_time: 0
    property var step: 0
    property var task_data: []

    function run(dir, offset, gap, overlap) {
        offset = Number(offset)
        if (dir == 'x') {
            // TODO figure out why Screen is needed here
            target.x = (0.5 + offset) * Screen.width - target.width / 2
            target.y = (Screen.height - target.height) / 2
        } else {
            target.x = (Screen.width - target.width) / 2
            target.y = (0.5 + offset) * Screen.height - target.height / 2
        }

        this.gap = (gap == "true")
        this.overlap = (overlap == "true")
        this.start_time = 2500 + Math.random() * 1000

        task_data = []
        step = 0

        next()
    }

    function next() {
        switch (step) {
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
                    step++  // and fall through
                }
            case 2:
                fixation.visible = overlap
                target.visible = true
                timer.interval = 1000
                break
            case 3:
                fixation.visible = true
                target.visible = false
                timer.interval = 10000 - (start_time + 1000 + (gap ? 200 : 0))
                break
            case 4:
                console.log()
                done()
                return
        }
        timer.start()

        task_data.push([fixation.visible, target.visible])
        step++
    }

    function abort() {
        timer.stop()
    }

    function get_data() {
        if (task_data.length > 0)
            return task_data.shift()
        return []
    }
}
