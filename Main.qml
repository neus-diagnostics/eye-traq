import QtQuick 2.7

Rectangle {
    signal minimize

    color: "#d6d3cc"

    ExperimenterView {
        runner: runner
        x: firstScreen.x
        y: firstScreen.y
        width: firstScreen.width
        height: firstScreen.height
        onMinimize: parent.minimize()
    }

    Runner {
        id: runner
        x: secondScreen.x
        y: secondScreen.y
        width: secondScreen.width
        height: secondScreen.height
    }
}
