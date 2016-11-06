import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.2

Rectangle {
    anchors.fill: parent

    color: "#e0d8c1"

    ExperimenterView {
        runner: runner
        x: firstScreen.x
        y: firstScreen.y
        width: firstScreen.width
        height: firstScreen.height
    }

    Runner {
        id: runner
        objectName: "runner"
        x: secondScreen.x
        y: secondScreen.y
        width: secondScreen.width
        height: secondScreen.height
    }
}
