import QtQuick 2.7

Item {
    id: control

    // how long to show each gaze point (in ms)
    property int duration: 500

    function run(p) {
        var x = Number(p.x) * width
        var y = Number(p.y) * height
        point.createObject(this, {"x": x, "y": y}).destroy(duration)
    }

    anchors.fill: parent
    clip: true

    Component {
        id: point

        Rectangle {
            radius: 10
            width: radius*2
            height: radius*2
            color: "#662bb673"

            NumberAnimation on scale {
                duration: control.duration
                from: 1.0
                to: 0.0
                easing.type: Easing.InCubic
                running: true
            }

            Component.onCompleted: {
                // center at coordinates specified when created
                x -= radius
                y -= radius
            }
        }
    }
}
