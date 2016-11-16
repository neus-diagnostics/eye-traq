import QtQuick 2.7

Rectangle {
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
        x: secondScreen.x
        y: secondScreen.y
        width: secondScreen.width
        height: secondScreen.height
    }
}
