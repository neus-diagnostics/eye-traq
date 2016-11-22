import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import "controls" as Neus

Rectangle {
    id: main

    property var runner

    signal minimize

    color: "#e0d8c1"

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
        id: menu
        anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
        width: parent.width/5
        color: "#ece6da"

        ColumnLayout {
            anchors.centerIn: parent
            width: parent.width * 0.6
            spacing: 20

            Neus.Button {
                text: qsTr("Options")
                Layout.fillWidth: true
                onClicked: main.state = "options"
            }
            Neus.Button {
                text: qsTr("Calibrate")
                enabled: eyetracker.connected
                Layout.fillWidth: true
                onClicked: main.state = "calibrate"
            }
            Neus.Button {
                text: qsTr("Practice")
                enabled: eyetracker.connected
                Layout.fillWidth: true
                onClicked: main.state = "practice"
            }
            Neus.Button {
                text: qsTr("Test")
                enabled: eyetracker.connected
                Layout.fillWidth: true
                onClicked: main.state = "test"
            }
            Neus.Button {
                text: qsTr("About")
                Layout.fillWidth: true
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

    Page {
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: menu.right
            right: parent.right
        }

        header: Row {
            layoutDirection: Qt.RightToLeft
            rightPadding: 10
            spacing: 5

            Button {
                text: "❌"  // U+274c "close"
                font.pixelSize: 32
                background: Rectangle { color: "transparent" }
                onClicked: Qt.quit()
            }
            Button {
                text: "⚊"  // U+268a "minimize"
                font.pixelSize: 32
                background: Rectangle { color: "transparent" }
                onClicked: minimize()
            }
        }

        StackLayout {
            id: view

            anchors.fill: parent

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
                onVisibleChanged: eyetracker.command(visible ? "start_tracking" : "stop_tracking")
            }
            Test {
                id: test
                options: options
                runner: main.runner
                onVisibleChanged: eyetracker.command(visible ? "start_tracking" : "stop_tracking")
            }
            About {
                id: about
            }
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
        },
        State {
            name: "practice"
            PropertyChanges { target: view; currentIndex: 2 }
            PropertyChanges {
                target: eyetracker;
                onGazePoint: practice.gaze.run(point)
            }
        },
        State {
            name: "test"
            PropertyChanges { target: view; currentIndex: 3 }
            PropertyChanges {
                target: eyetracker;
                onGazePoint: test.gaze.run(point)
            }
        },
        State {
            name: "about"
            PropertyChanges { target: view; currentIndex: 4 }
        }
    ]
}
