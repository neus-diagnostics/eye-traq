import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import "controls" as Neus

Rectangle {
    id: main
    property var runner

    color: "#e0d8c1"

    Connections {
        target: eyetracker
        onGazePoint: view.gaze(point)
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
                onClicked: view.currentIndex = 0
            }
            Neus.Button {
                text: qsTr("Calibrate")
                Layout.fillWidth: true
                onClicked: view.currentIndex = 1
            }
            Neus.Button {
                text: qsTr("Practice")
                Layout.fillWidth: true
                onClicked: view.currentIndex = 2
            }
            Neus.Button {
                text: qsTr("Test")
                Layout.fillWidth: true
                onClicked: view.currentIndex = 3
            }
            Neus.Button {
                text: qsTr("About")
                Layout.fillWidth: true
                onClicked: view.currentIndex = 4
            }
        }
    }

    StackLayout {
        id: view

        function gaze(point) {
            var item = children[currentIndex]
            if (item == practice || item == test)
                    item.gaze.run(point)
        }

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: menu.right
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
