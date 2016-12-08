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
        paused = false
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
        if (running) {
            tasks.children[tasks.currentIndex].abort()
            var nsteps = 0
            while (next > 0 && (test[next].name != "checkpoint" || nsteps < 3)) {
                nsteps++
                next--
            }
            info(eyetracker.time() + '\ttest\tback')
            step()
        }
    }

    function forward() {
        if (running) {
            tasks.children[tasks.currentIndex].abort()
            while (next < test.length && test[next].name != "checkpoint")
                next++
            info(eyetracker.time() + '\ttest\tforward')
            step()
        }
    }

    function stop() {
        if (running) {
            tasks.children[tasks.currentIndex].abort()
            tasks.currentIndex = 0
            running = false
            test = []
            next = 0
            stopped()
        }
    }

    function run(task) {
        var args = task.args
        switch (task.name) {
            case "blank":
                tasks.currentIndex = 0
                blank.run(task.duration)
                break;
            case "imgpair":
                tasks.currentIndex = 1
                imgpair.run(task.duration, args[0], args[1])
                break;
            case "pursuit":
                tasks.currentIndex = 2
                pursuit.run(task.duration, args[0], args[1], args[2])
                break;
            case "saccade":
                tasks.currentIndex = 3
                saccade.run(task.duration, args[0], args[1], args[2], args[3])
                break;
            case "message":
                tasks.currentIndex = 4
                message.run(task.duration, args[0], args[1])
                break;
            case "alert":
                tasks.currentIndex = 5
                alert.run(task.duration)
                break;
            case "calibrator":
                tasks.currentIndex = 6
                calibrator.run(task.duration, args[0], args[1], args[2])
                break;
            default:
                step()  // ignore anything we don’t understand
                break
        }
    }

    color: "black"

    onPausedChanged: {
        if (!running)
            return;
        if (paused) {
            info(eyetracker.time() + '\ttest\tpaused')
            tasks.children[tasks.currentIndex].pause()
        } else {
            info(eyetracker.time() + '\ttest\tresumed')
            tasks.children[tasks.currentIndex].unpause()
        }
    }

    StackLayout {
        anchors.fill: parent
        currentIndex: running ? 0 : 1

        StackLayout {
            id: tasks

            anchors.fill: parent
            focus: true

            Blank {
                id: blank
                onDone: step()
            }
            ImgPair {
                id: imgpair
                onDone: step()
            }
            Pursuit {
                id: pursuit
                onDone: step()
                onInfo: main.info(text)
            }
            Saccade {
                id: saccade
                onDone: step()
                onInfo: main.info(text)
            }
            Message {
                id: message
                onDone: step()
            }
            Alert {
                id: alert
                onDone: step()
            }
            Calibrator {
                id: calibrator
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
}
