import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import "controls" as Neus

Rectangle {
    id: main
    property var runner

    color: "#e0d8c1"

    TabBar {
        id: bar
        width: parent.width
        height: 90

        background: Rectangle { color: "#ece6da" }

        Neus.TabButton {
            text: qsTr("Options")
        }
        Neus.TabButton {
            text: qsTr("Calibrate")
        }
        Neus.TabButton {
            text: qsTr("Practice")
        }
        Neus.TabButton {
            text: qsTr("Test")
        }
        Neus.TabButton {
            text: qsTr("About")
        }
    }

    StackLayout {
        width: parent.width
        anchors.top: bar.bottom
        anchors.bottom: parent.bottom
        currentIndex: bar.currentIndex

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
}
