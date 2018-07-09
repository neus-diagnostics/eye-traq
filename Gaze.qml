import QtQuick 2.7

Item {
    id: control

    // how long to show each gaze point (in ms)
    property int duration: 500

    function run(p, color) {
        var x = p.x
        var y = p.y
        var color = color || '#2bb673'
        point.createObject(this, {'normalX': x, 'normalY': y, 'color': color}).destroy(duration)
    }

    anchors.fill: parent
    clip: true

    Component {
        id: point

        Dot {
            radius: 10
            opacity: 0.2
            NumberAnimation on scale {
                duration: control.duration
                from: 1.0
                to: 0.0
                easing.type: Easing.InCubic
                running: true
            }
        }
    }
}
