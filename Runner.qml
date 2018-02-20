import QtQuick 2.7
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
            info(eyetracker.time() + '\ttest\tstep\t' + next + '\t' +
                 test[next].name + '\t' + test[next].args.join('\t'))
            var task = test[next]
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
            tasks.children[tasks.currentIndex].abort()
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
            tasks.children[tasks.currentIndex].abort()
            while (next < test.length && test[next].name != "message")
                next++
            info(eyetracker.time() + '\ttest\tforward')
            step()
            paused = false
        }
    }

    function stop() {
        if (running) {
            tasks.children[tasks.currentIndex].abort()
            tasks.currentIndex = 0
            running = false
            paused = false
            test = []
            next = 0
            stopped()
        }
    }

    // run a task {name: "…", args: […], duration: …}
    function run(task) {
        var index = tasks.index.indexOf(task.name)
        if (index !== -1) {
            // call task’s run with maximum number of arguments for any task,
            // undefined arguments are ignored
            var args = task.args || []
            tasks.currentIndex = index
            tasks.children[index].run(task.duration, args[0], args[1], args[2], args[3])
        } else {
            step() // ignore anything we don’t understand
        }
    }

    // set runner to a recorded state {name: "…", args: […]}
    // used for playing recorded tests
    function set(task) {
        var index = tasks.index.indexOf(task.name)
        if (index !== -1) {
            // call task’s run with maximum number of arguments for any task,
            // undefined arguments are ignored
            var args = task.args || []
            tasks.currentIndex = index
            tasks.children[index].set(args[0], args[1], args[2], args[3])
        }
    }

    color: "black"

    onPausedChanged: {
        if (!running)
            return;
        var task = tasks.children[tasks.currentIndex]
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

            // keep in sync with actual children below!
            property var index: [
                'blank', 'imgpair', 'pursuit', 'saccade', 'message', 'calibrator',
            ]

            anchors.fill: parent
            focus: true

            Blank {
                onDone: step()
            }
            ImgPair {
                onDone: step()
            }
            Pursuit {
                onDone: step()
                onInfo: main.info(text)
            }
            Saccade {
                onDone: step()
                onInfo: main.info(text)
            }
            Message {
                onDone: step()
            }
            Calibrator {
                onDone: step()
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
