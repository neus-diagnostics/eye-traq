import QtGraphicalEffects 1.0
import QtQml 2.2
import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.2

Item {
    id: screen

    function run(x, y) {
        var w = 30
        var h = 30
        x = Number(x) * Screen.width - w/2
        y = Number(y) * Screen.height - h/2

        // create a point and destroy it after 500 ms
        point.createObject(screen, {"width": w, "height": h, "x": x, "y": y}).destroy(500)
    }

    function abort() {
    }

    function get_data() {
        return []
    }

    anchors.fill: parent

    Component {
        id: point

        RadialGradient {
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
        }
    }
}
