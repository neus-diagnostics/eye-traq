import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2

Window {
    id: window
    title: qsTr("Calibration")

    Canvas {
        id: plot
        anchors.fill: parent
        focus: true

        onPaint: {
            var ctx = getContext("2d")
            ctx.fillStyle = "#6e6e6e"
            ctx.fillRect(0, 0, width, height)

            ctx.lineWidth = 1;
            for (var i = 0; i < lines.length; i++) {
                ctx.strokeStyle = lines[i]["color"]
                ctx.beginPath()
                ctx.moveTo(lines[i]["from"].x, lines[i]["from"].y)
                ctx.lineTo(lines[i]["to"].x, lines[i]["to"].y)
                ctx.stroke()
                ctx.closePath()
            }
        }

        Keys.onEscapePressed: stop()
        property var lines: []
    }

    Rectangle {
        id: stimulus
        width: 30
        height: 30
        radius: width/2
        color: "red"
        border.width: 2
        border.color: "black"
        x: Screen.width/2 - width/2
        y: Screen.height/2 - height/2

        SequentialAnimation {
            id: anim
            NumberAnimation {
                id: grow
                target: stimulus
                property: "scale"
                to: 1.0
                duration: 500
            }
            ParallelAnimation {
                NumberAnimation { id: moveX; target: stimulus; property: "x" }
                NumberAnimation { id: moveY; target: stimulus; property: "y" }
            }
            NumberAnimation {
                target: stimulus
                property: "scale"
                to: 0.25
                duration: 500
            }
            onStopped: calibrator.add_point()
        }
    }

    Timer {
        id: pause
        interval: 1000
        onTriggered: calibrator.add_point()
    }

    GridLayout {
        id: report
        anchors.centerIn: parent
        visible: false

        Label {
            id: status
            Layout.row: 0
            Layout.column: 0
            Layout.columnSpan: 2
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Hello world!")
        }
        Button {
            Layout.row: 1
            Layout.column: 0
            text: qsTr("OK")
            onClicked: window.hide()
        }
        Button {
            Layout.row: 1
            Layout.column: 1
            text: qsTr("Try again")
            onClicked: calibrator.start()
        }
    }

    function init() {
        plot.lines = []
        plot.requestPaint()
        report.visible = false
        stimulus.x = Screen.width/2 - stimulus.width/2
        stimulus.y = Screen.height/2 - stimulus.height/2
        stimulus.scale = 1.0
        stimulus.visible = true
        window.showFullScreen()
        pause.start()
    }

    function move(point) {
        var screen_x = Screen.width*point.x
        var screen_y = Screen.height*point.y
        var dist_x = screen_x-stimulus.x
        var dist_y = screen_y-stimulus.y
        var dist = Math.sqrt(dist_x*dist_x + dist_y*dist_y)

        grow.duration = (stimulus.scale < 1.0 ? 500 : 0)
        moveX.duration = dist
        moveY.duration = dist
        moveX.to = screen_x - stimulus.width/2
        moveY.to = screen_y - stimulus.height/2

        anim.start()
    }

    function addLine(from, to, color) {
        from.x *= Screen.width
        from.y *= Screen.height
        to.x *= Screen.width
        to.y *= Screen.height
        plot.lines.push({'from': from, 'to': to, 'color': color})
    }

    function end(msg) {
        status.text = msg
        report.visible = true
        stimulus.visible = false
        plot.requestPaint()
    }

    function stop() {
        window.hide()
        if (pause.running)
            pause.stop()
        if (anim.running)
            anim.pause()
        calibrator.stop()
    }

    // QT BUG: force repaint after entering fullscreen
    onActiveChanged: update()

    onClosing: close.accepted = false
}
