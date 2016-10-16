import QtQuick 2.7
import QtQuick.Controls 2.0

Item {
    anchors.fill: parent

    signal done()

    Rectangle {
        id: center
        width: 30
        height: 30
        color: "transparent"
        border.color: "black"
        border.width: 2
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
    }

    Rectangle {
        id: fixation
        width: 20
        height: 20
        radius: width/2
        color: "red"
        border.color: "black"
        border.width: 2
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
    }

    Rectangle {
        id: target
        width: 20
        height: 20
        radius: width/2
        color: "red"
        border.color: "black"
        border.width: 2
        y: (parent.height - height) / 2
    }

    Timer {
        id: timer
        repeat: false
        onTriggered: next()
    }

    property var gap: true
    property var step: 0
    property var task_data: []

    function run(offset, gap) {
        offset = Number(offset)
        target.x = (0.5 + offset) * width - target.width / 2
        this.gap = (gap == "true")

        task_data = []
        step = 0

        next()
    }

    function next() {
        switch (step) {
        case 0:
            fixation.visible = false
            target.visible = false
            timer.interval = 1000
            break
        case 1:
            fixation.visible = true
            timer.interval = 1000
            break
        case 2:
            if (gap)
                fixation.visible = false
            else
                target.visible = true
            timer.interval = 200
            break
        case 3:
            if (gap) {
                target.visible = true
                timer.interval = 2000
            } else {
                fixation.visible = false
                timer.interval = 1800
            }
            break
        case 4:
            fixation.visible = false
            target.visible = false
            timer.interval = 1000
            break
        case 5:
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
