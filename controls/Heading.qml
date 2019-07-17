// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright © 2016, 2017 Neus Diagnostics, d.o.o.

import QtQuick 2.7
import QtQuick.Controls 2.0

Label {
    font {
        pixelSize: 18
        capitalization: Font.AllUppercase
        weight: Font.Bold
    }

    background: Rectangle {
        color: "transparent"
        Rectangle {
            width: parent.width
            height: 1
            anchors.bottom: parent.bottom
            color: "transparent"
            border.color: "#aaaaaa"
        }
    }
}
