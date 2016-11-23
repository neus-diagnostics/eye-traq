import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import "controls" as Neus

Rectangle {
    id: main

    property var runner

    signal minimize

    color: "#d6d3cc"

    onStateChanged: runner.stop()

    Connections {
        target: eyetracker
        onStatusChanged: {
            if (!eyetracker.connected) {
                if (state == "calibrate" || state == "practice" || state == "test")
                    state = "options"
            }
        }
    }

    Rectangle {
        id: sidebar
        anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
        width: parent.width/5
        color: "#eae9e5"

        ButtonGroup { buttons: menu.children }

        ColumnLayout {
            id: menu
            anchors.centerIn: parent
            width: parent.width * 0.6
            spacing: main.height * 0.025

            Neus.Button {
                text: qsTr("Options")
                height: main.height * 0.04
                Layout.fillWidth: true
                checkable: true
                onClicked: main.state = "options"
            }
            Neus.Button {
                text: qsTr("Calibrate")
                height: main.height * 0.04
                Layout.fillWidth: true
                checkable: true
                enabled: eyetracker.connected
                onClicked: main.state = "calibrate"
            }
            Neus.Button {
                text: qsTr("Practice")
                height: main.height * 0.04
                Layout.fillWidth: true
                checkable: true
                enabled: eyetracker.connected
                onClicked: main.state = "practice"
            }
            Neus.Button {
                text: qsTr("Test")
                height: main.height * 0.04
                Layout.fillWidth: true
                checkable: true
                enabled: eyetracker.connected
                onClicked: main.state = "test"
            }
            Neus.Button {
                text: qsTr("About")
                height: main.height * 0.04
                Layout.fillWidth: true
                checkable: true
                onClicked: main.state = "about"
            }
        }

        Neus.Label {
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
                margins: 20
            }
            text: eyetracker.status
        }
    }

    Row {
        anchors {
            top: parent.top
            right: parent.right
        }

        layoutDirection: Qt.RightToLeft
        padding: 20
        spacing: 10

        Button {
            text: "❌"  // U+274c "close"
            width: height
            font.pixelSize: 16
            background: Rectangle { color: "#eae9e5" }
            onClicked: Qt.quit()
        }
        Button {
            text: "⚊"  // U+268a "minimize"
            width: height
            font.pixelSize: 16
            background: Rectangle { color: "#eae9e5" }
            onClicked: minimize()
        }
    }

    StackLayout {
        id: view

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: sidebar.right
            right: parent.right
        }

        Options {
            id: options
        }
        Calibrate {
            id: calibrate
            options: options
            runner: main.runner
        }
        Practice {
            id: practice
            options: options
            runner: main.runner
        }
        Test {
            id: test
            options: options
            runner: main.runner
        }
        About {
            id: about
        }
    }

    states: [
        State {
            name: "options"
            PropertyChanges { target: view; currentIndex: 0 }
        },
        State {
            name: "calibrate"
            PropertyChanges { target: view; currentIndex: 1 }
            PropertyChanges {
                target: runner
                onDone: calibrate.end()
            }
        },
        State {
            name: "practice"
            PropertyChanges { target: view; currentIndex: 2 }
            PropertyChanges {
                target: eyetracker
                tracking: true
                onGazePoint: practice.gaze.run(point)
            }
        },
        State {
            name: "test"
            PropertyChanges { target: view; currentIndex: 3 }
            PropertyChanges {
                target: eyetracker
                tracking: true
                onGazePoint: test.gaze.run(point)
            }
        },
        State {
            name: "about"
            PropertyChanges { target: view; currentIndex: 4 }
        }
    ]
}
