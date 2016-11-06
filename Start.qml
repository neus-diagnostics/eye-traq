import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.0
import QtQuick.Layouts 1.0

import "controls" as Neus

Row {
    signal options
    signal calibrate
    signal practice
    signal test
    signal about

    Rectangle {
        height: parent.height
        width: parent.width / 2
        color: "#ece6da"

        Image {
            source: "images/neus.png"
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right;
                rightMargin: parent.width / 6
            }
            fillMode: Image.PreserveAspectFit
            width: parent.width / 2
        }
    }

    Rectangle {
        height: parent.height
        width: parent.width / 2
        color: "#e0d8c1"

        Column {
            anchors {
                verticalCenter: parent.verticalCenter;
                left: parent.left;
                leftMargin: parent.width / 6
            }
            width: parent.width / 3
            spacing: 30

            Neus.Button {
                text: qsTr("Options")
                width: parent.width
                onClicked: options()
            }

            Neus.Button {
                text: qsTr("Calibrate")
                width: parent.width
                onClicked: calibrate()
            }

            Neus.Button {
                text: qsTr("Practice")
                width: parent.width
                onClicked: practice()
            }

            Neus.Button {
                text: qsTr("Test")
                width: parent.width
                onClicked: test()
            }

            Neus.Button {
                text: qsTr("About")
                width: parent.width
                onClicked: about()
            }
        }
    }
}
