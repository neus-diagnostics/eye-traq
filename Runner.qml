import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import "Task"

Rectangle {
    signal next

    function stop() {
        tasks.children[tasks.currentIndex].abort()
        tasks.currentIndex = 0
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
            case "gaze":
                gaze.run(args[0], args[1], args[2])
                break;
        }
    }

    function get_data() {
        return tasks.children[tasks.currentIndex].get_data()
    }

    color: "black"

    StackLayout {
        id: tasks

        anchors.fill: parent
        focus: true

        Blank { id: blank; onDone: next() }
        ImgPair { id: imgpair; onDone: next() }
        Pursuit { id: pursuit; onDone: next() }
        Saccade { id: saccade; onDone: next() }
        ShowTxt { id: showtxt; onDone: next() }
        Calibrator { id: calibrator; onDone: next() }
    }

    Gaze { id: gaze }
}
