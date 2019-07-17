import QtQuick 2.7

Rectangle {
    signal minimize

    color: "#d6d3cc"

    ExperimenterView {
        runner: runner
        x: firstScreen.geometry.x
        y: firstScreen.geometry.y
        width: firstScreen.geometry.width
        height: firstScreen.geometry.height
        onMinimize: parent.minimize()
    }

    Runner {
        id: runner
        x: secondScreen.geometry.x
        y: secondScreen.geometry.y
        width: secondScreen.geometry.width
        height: secondScreen.geometry.height
    }
}
