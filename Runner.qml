import QtQuick 2.7
import QtQuick.Layouts 1.3

import "Tasks"

Rectangle {
    property bool running: false
    property bool paused: false

    property var test: []
    property var next: 0

    signal done

    function start(testfile) {
        stop()
        test = recorder.loadTest(testfile)
        next = 0
        running = true
        recorder.write(eyetracker.time() + '\ttest\tstarted')
        step()
    }

    function step() {
        paused = false
        if (next < test.length) {
            recorder.write(eyetracker.time() + '\ttest\tstep\t' + next + '\t' + test[next])
            var tokens = test[next].split('\t')
            next++
            run(tokens[0], tokens.slice(1))
        } else {
            recorder.write(eyetracker.time() + '\ttest\tdone')
            stop()
            done()
        }
    }

    function back() {
        if (running) {
            tasks.children[tasks.currentIndex].abort()
            var nsteps = 0
            while (next > 0 && (test[next] != "checkpoint" || nsteps < 3)) {
                nsteps++
                next--
            }
            recorder.write(eyetracker.time() + '\ttest\tback')
            step()
        }
    }

    function forward() {
        if (running) {
            tasks.children[tasks.currentIndex].abort()
            while (next < test.length && test[next] != "checkpoint")
                next++
            recorder.write(eyetracker.time() + '\ttest\tforward')
            step()
        }
    }

    function stop() {
        if (running) {
            tasks.children[tasks.currentIndex].abort()
            tasks.currentIndex = 0
            running = false
        }
    }

    function run(name, args) {
        switch (name) {
            case "blank":
                tasks.currentIndex = 0
                blank.run(args[0])
                break;
            case "imgpair":
                tasks.currentIndex = 1
                imgpair.run(args[0], args[1], args[2])
                break;
            case "pursuit":
                tasks.currentIndex = 2
                pursuit.run(args[0], args[1], args[2], args[3])
                break;
            case "saccade":
                tasks.currentIndex = 3
                saccade.run(args[0], args[1], args[2], args[3])
                break;
            case "message":
                tasks.currentIndex = 4
                message.run(args[0], args[1], args[2])
                break;
            case "alert":
                tasks.currentIndex = 5
                alert.run()
                break;
            case "calibrator":
                tasks.currentIndex = 6
                calibrator.run(args[0], args[1], args[2], args[3])
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
            recorder.write(eyetracker.time() + '\ttest\tpaused')
            tasks.children[tasks.currentIndex].pause()
        } else {
            recorder.write(eyetracker.time() + '\ttest\tresumed')
            tasks.children[tasks.currentIndex].unpause()
        }
    }

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
            onInfo: recorder.write(text)
        }
        Saccade {
            id: saccade
            onDone: step()
            onInfo: recorder.write(text)
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
}
