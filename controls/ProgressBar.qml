// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright © 2017 Neus Diagnostics, d.o.o.

import QtQuick 2.7
import QtQuick.Controls 2.0

ProgressBar {
    id: control
    padding: 2

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 18
        color: "#e6e6e6"
        border.color: "#777777"
        border.width: 1
    }

    contentItem: Item {
        implicitHeight: 16
        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            color: "lightsteelblue"
            radius: 2
        }
    }
}
