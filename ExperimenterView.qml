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
            if (!eyetracker.connected && !(state == "" || state == "about"))
                state = ""
        }
    }

    Keys.onPressed: {
        if (event.key == Qt.Key_Home)
            state = ""
    }

    Rectangle {
        id: sidebar
        anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
        width: parent.width/5
        color: "#eae9e5"

        ButtonGroup { id: menuButtons; buttons: menu.children }

        ColumnLayout {
            id: menu
            anchors.centerIn: parent
            width: parent.width * 0.6
            spacing: parent.width * 0.06

            Repeater {
                model: [
                    { "text": qsTr("Set up"), "state": "options" },
                    { "text": qsTr("Calibrate"), "state": "calibrate" },
                    { "text": qsTr("Practice"), "state": "practice" },
                    { "text": qsTr("Test"), "state": "test" },
                    { "text": qsTr("About"), "state": "about" },
                ]
                Neus.Button {
                    text: modelData.text
                    Layout.fillWidth: true
                    checkable: true
                    enabled: eyetracker.connected || modelData.state == "about"
                    onClicked: main.state = modelData.state
                }
            }
        }

        Neus.Label {
            text: eyetracker.status
            anchors {
                bottom: parent.bottom
                left: parent.left
                margins: 20
            }
        }
    }

    Page {
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: sidebar.right
            right: parent.right
        }

        header: Item {
            height: parent.height * 0.12

            Row {
                anchors.right: parent.right

                layoutDirection: Qt.RightToLeft
                padding: 20
                spacing: 10

                Button {
                    text: "×"  // TODO: replace with "❌" (U+274c "close")
                    width: height
                    font { pointSize: 12; weight: Font.Bold }
                    hoverEnabled: true
                    background: Rectangle {
                        color: parent.hovered ? "#d0d0d0" : "#e0e0e0"
                    }
                    onClicked: Qt.quit()
                }
                Button {
                    text: "–"  // TODO: replace with "⚊" (U+268a "minimize")
                    width: height
                    font { pointSize: 12; weight: Font.Bold }
                    hoverEnabled: true
                    background: Rectangle {
                        color: parent.hovered ? "#d0d0d0" : "#e0e0e0"
                    }
                    onClicked: minimize()
                }
            }
        }

        footer: Item {
            height: parent.height * 0.12
        }

        StackLayout {
            id: view

            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.8
            height: parent.height

            Start { }
            Options { id: options }
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
            About { id: about }
        }
    }

    states: [
        State {
            name: ""
            PropertyChanges { target: view; currentIndex: 0 }
            PropertyChanges { target: menuButtons; checkedButton: null }
        },
        State {
            name: "options"
            PropertyChanges { target: view; currentIndex: 1 }
        },
        State {
            name: "calibrate"
            PropertyChanges { target: view; currentIndex: 2 }
            PropertyChanges {
                target: runner
                onDone: calibrate.end()
            }
        },
        State {
            name: "practice"
            PropertyChanges { target: view; currentIndex: 3 }
            PropertyChanges {
                target: eyetracker
                tracking: true
                onGazePoint: practice.gaze.run(point)
            }
        },
        State {
            name: "test"
            PropertyChanges { target: view; currentIndex: 4 }
            PropertyChanges {
                target: eyetracker
                tracking: true
                onGazePoint: test.gaze.run(point)
            }
        },
        State {
            name: "about"
            PropertyChanges { target: view; currentIndex: 5 }
        }
    ]
}
