import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2

Window {
    id: window
    color: "#6e6e6e"

    signal next()
    signal abort()

    StackLayout {
        id: tasks
        anchors.fill: parent
        focus: true

        Loader {
            id: blank
            source: "task/blank.qml"
            Connections {
                target: blank.item
                onDone: next()
            }
        }

        Loader {
            id: imgpair
            source: "task/imgpair.qml"
            Connections {
                target: imgpair.item
                onDone: next()
            }
        }

        Loader {
            id: pursuit
            source: "task/pursuit.qml"
            Connections {
                target: pursuit.item
                onDone: next()
            }
        }

        Loader {
            id: saccade
            source: "task/saccade.qml"
            Connections {
                target: saccade.item
                onDone: next()
            }
        }

        Keys.onEscapePressed: abort()
    }

    function run(name, args) {
        switch (name) {
            case "blank":
                tasks.currentIndex = 0
                blank.item.run(args[0])
                break;
            case "imgpair":
                tasks.currentIndex = 1
                imgpair.item.run(args[0], args[1], args[2])
                break;
            case "pursuit":
                tasks.currentIndex = 2
                pursuit.item.run(args[0], args[1], args[2])
                break;
            case "saccade":
                tasks.currentIndex = 3
                saccade.item.run(args[0], args[1])
                break;
        }
        window.showFullScreen()
    }

    function stop() {
        window.hide()
        tasks.children[tasks.currentIndex].item.abort()
    }

    function get_data() {
        return tasks.children[tasks.currentIndex].item.get_data()
    }

    // QT BUG: force repaint after entering fullscreen
    onActiveChanged: update()

    onClosing: close.accepted = false
}
