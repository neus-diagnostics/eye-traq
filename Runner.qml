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

    signal info(string text)
    signal done
    signal stopped

    function start(testfile) {
        stop()
        name = testfile.replace(/.*\//, '');  // use filename as test name
        test = recorder.loadTest(testfile)
        next = 0
        running = true
        info(eyetracker.time() + '\ttest\tstarted')
        step()
    }

    function step() {
        if (next < test.length) {
            var task = test[next]
            info(eyetracker.time() + '\ttest\tstep\t' + next + '\t' +
                 JSON.stringify(task, function (key, value) {
                     return key === 'start' ? undefined : value
                 }))
            next++
            run(task)
        } else {
            info(eyetracker.time() + '\ttest\tdone')
            done()
            stop()
        }
    }

    function back() {
        if (running && next > 0) {
            tasks.selected.abort()
            var nsteps = 0
            while (next > 0 && (nsteps++ < 3 || test[next].name != "message"))
                next--
            info(eyetracker.time() + '\ttest\tback')
            step()
            paused = false
        }
    }

    function forward() {
        if (running && next < test.length) {
            tasks.selected.abort()
            while (next < test.length && test[next].name != "message")
                next++
            info(eyetracker.time() + '\ttest\tforward')
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
            info(eyetracker.time() + '\ttest\tpaused')
            if (task.running)
                task.pause()
        } else {
            info(eyetracker.time() + '\ttest\tresumed')
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
                        onDone: step()
                        onInfo: main.info(text)
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
