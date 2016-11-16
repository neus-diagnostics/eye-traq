import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import "Task"

Rectangle {
    property bool running: false
    property var test: []
    property var next: 0

    signal done

    function start(testfile) {
        if (running)
            stop()
        test = recorder.loadTest(testfile)
        next = 0
        running = true
        step()
    }

    function step() {
        if (next < test.length) {
            recorder.write(eyetracker.time() + '\ttest\t' + test[next])
            var tokens = test[next].split('\t')
            next++
            run(tokens[0], tokens.slice(1))
        } else {
            recorder.write(eyetracker.time() + '\ttest\tend')
            stop()
            done()
        }
    }

    function stop() {
        tasks.children[tasks.currentIndex].abort()
        tasks.currentIndex = 0
        running = false
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
            case "showtxt":
                tasks.currentIndex = 4
                showtxt.run(args[0], args[1])
                break;
            case "calibrator":
                tasks.currentIndex = 5
                calibrator.run(args[0], args[1], args[2], args[3])
                break;
        }
    }

    color: "black"

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
        ShowTxt {
            id: showtxt
            onDone: step()
        }
        Calibrator {
            id: calibrator
            onDone: step()
        }
    }
}
