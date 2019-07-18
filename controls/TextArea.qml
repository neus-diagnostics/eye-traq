// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright © 2016, 2017 Neus Diagnostics, d.o.o.

import QtQuick 2.7
import QtQuick.Controls 2.0

Flickable {
    property alias text: area.text
    property alias cursorPosition: area.cursorPosition

    TextArea.flickable: TextArea {
        id: area

        padding: 4
        font.pixelSize: 15
        selectByMouse: true
        wrapMode: TextArea.Wrap

        background: Rectangle {
            implicitWidth: 200
            implicitHeight: 100
            color: "#eae9e5"
            opacity: enabled ? 1 : 0.3
            border.color: "#777777"
            border.width: 1
        }
    }
    ScrollBar.vertical: ScrollBar { }
}
