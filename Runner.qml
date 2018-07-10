import QtQuick 2.9
import QtQuick.Layouts 1.3

import "Tasks"

Rectangle {
    id: main

    property bool running: false
    property bool paused: false

    property var name: ''
    property var test: []
    property var next: 0

    signal info(var time, var message)
    signal done
    signal stopped

    function sendInfo(message) {
        info(eyetracker.time(), message)
    }

    function start(testfile) {
        stop()
        name = testfile.replace(/.*\//, '');  // use filename as test name
        test = recorder.loadTest(testfile)
        next = 0
        running = true
        sendInfo({'type': 'started'})
        step()
    }

    function step() {
        if (next < test.length) {
            var task = test[next]
            sendInfo({'type': 'step', 'step': next, 'task': task})
            next++
            run(task)
        } else {
            sendInfo({'type': 'done'})
            done()
            stop()
        }
    }

    function back() {
        if (!running)
            return
        if (tasks.selected.back())
            return
        if (next > 0) {
            tasks.selected.abort()
            var nsteps = 0
            while (next > 0 && (nsteps++ < 3 || test[next].name != "message"))
                next--
            sendInfo({'type': 'back'})
            step()
            paused = false
        }
    }

    function forward() {
        if (!running)
            return
        if (tasks.selected.forward())
            return
        if (next < test.length) {
            tasks.selected.abort()
            while (next < test.length && test[next].name != "message")
                next++
            sendInfo({'type': 'forward'})
            step()
            paused = false
        }
    }

    function stop() {
        if (running) {
            tasks.selected.abort()
            running = false
            paused = false
            test = []
            next = 0
            stopped()
        }
    }

    // run a task {name: "…", duration: …, args…}
    function run(task) {
        if (tasks.select(task.name))
            tasks.selected.run(task)
        else
            step() // ignore anything we don’t understand
    }

    // set runner to a recorded state {task: "…", args…}
    // used for playing recorded tests
    function set(state) {
        if (tasks.select(state.task))
            tasks.selected.set(state)
    }

    color: "black"

    onPausedChanged: {
        if (!running)
            return
        var task = tasks.children[tasks.currentIndex].item
        if (paused) {
            sendInfo({'type': 'paused'})
            if (task.running)
                task.pause()
        } else {
            sendInfo({'type': 'resumed'})
            if (!task.running)
                task.unpause()
        }
    }

    StackLayout {
        anchors.fill: parent
        currentIndex: running ? 0 : 1

        StackLayout {
            id: tasks

            property var selected: children[currentIndex].item

            function select(name) {
                var index = items.model.indexOf(name)
                if (index !== -1) {
                    currentIndex = index
                    return selected
                } else {
                    console.log('unknown task:', name)
                    return null
                }
            }

            anchors.fill: parent
            focus: true

            Repeater {
                id: items
                model: ['blank', 'imgpair', 'message', 'pursuit', 'saccade', 'calibrator']
                delegate: Loader {
                    source: 'Tasks/' + modelData[0].toUpperCase() + modelData.substring(1) + '.qml'
                    Connections {
                        target: item
                        enabled: main.enabled
                        onDone: step()
                        onInfo: sendInfo({'type': 'data', 'data': data})
                    }
                }
            }
        }

        Rectangle {
            color: "black"
            anchors.fill: parent
            Image {
                // set the stand-by image
                // source: ""
                anchors.centerIn: parent
                width: parent.width / 2
                height: parent.height / 2
                fillMode: Image.PreserveAspectFit
                sourceSize { width: width; height: height }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.BlankCursor
    }
}
