// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright © 2018 Neus Diagnostics, d.o.o.

import QtQuick 2.9

Item {
    id: control

    property color color: 'steelblue'
    property real size: 0.1
    property real radius: 0

    readonly property real actualSize: size * Math.min(width, height)

    anchors.fill: parent

    Repeater {
        model: [
            { width: parent.width, height: parent.height, rotation: 0 },
            { width: parent.height, height: parent.width, rotation: 90 },
        ]
        delegate: Rectangle {
            width: modelData.width
            height: modelData.height
            radius: control.radius
            anchors.centerIn: parent
            rotation: modelData.rotation
            gradient: Gradient {
                GradientStop { position: 0.0; color: control.color }
                GradientStop { position: actualSize/height; color: 'transparent' }
                GradientStop { position: 1-actualSize/height; color: 'transparent' }
                GradientStop { position: 1.0; color: control.color }
            }
        }
    }

    Behavior on color {
        ColorAnimation { duration: 100 }
    }
    Behavior on size {
        NumberAnimation { duration: 200 }
    }
}
