// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright © 2016, 2017 Neus Diagnostics, d.o.o.

import QtQuick 2.7
import QtQuick.Controls 2.0

TextField {
    padding: 4
    leftPadding: padding + 4
    rightPadding: leftPadding
    selectByMouse: true
    selectionColor: "lightsteelblue"

    background: Rectangle {
        implicitWidth: 200
        color: "#eae9e5"
        border.color: "#777777"
        border.width: 1
    }
}
