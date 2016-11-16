import QtGraphicalEffects 1.0
import QtQml 2.2
import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.2

Item {
    id: screen

    function run(p) {
        // create a point and destroy it after 500 ms
        var x = Number(p.x) * width
        var y = Number(p.y) * height
        point.createObject(screen, {"x": x, "y": y}).destroy(500)
    }

    anchors.fill: parent
    clip: true

    Component {
        id: point

        RadialGradient {
            width: 40
            height: 40
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#2bb673" }
                GradientStop { position: 0.5; color: "transparent" }
            }

            NumberAnimation on scale {
                id: anim
                duration: 500
                from: 1.0
                to: 0.0
                easing.type: Easing.InCubic
                running: true
            }

            Component.onCompleted: {
                // center at coordinates specified when created
                x -= width/2
                y -= height/2
            }
        }
    }
}
