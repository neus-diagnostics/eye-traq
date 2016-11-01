import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2

import "Task"

Window {
    signal next
    signal abort

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
            case "gaze":
                gaze.run(args[0], args[1], args[2])
                break;
        }
        visibility = Window.FullScreen
    }

    function stop() {
        visibility = Window.Hidden
        tasks.children[tasks.currentIndex].abort()
    }

    function get_data() {
        return tasks.children[tasks.currentIndex].get_data()
    }

    color: "black"

    // QT BUG: force repaint after entering fullscreen
    onActiveChanged: update()
    onClosing: close.accepted = false

    StackLayout {
        id: tasks

        anchors.fill: parent
        focus: true

        Blank { id: blank; onDone: next() }
        ImgPair { id: imgpair; onDone: next() }
        Pursuit { id: pursuit; onDone: next() }
        Saccade { id: saccade; onDone: next() }
        ShowTxt { id: showtxt; onDone: next() }

        Keys.onEscapePressed: abort()
    }

    Gaze {
        id: gaze
    }

    // hide the cursor
    // TODO cursor stays visible until moved
    MouseArea { anchors.fill: parent; cursorShape: Qt.BlankCursor }
}
