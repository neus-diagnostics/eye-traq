// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright © 2016 The Qt Company Ltd.
// Copyright © 2016, 2017 Neus Diagnostics, d.o.o.

import QtQuick 2.6
import QtQuick.Templates 2.0 as T

T.Button {
    id: control

    hoverEnabled: true
    implicitWidth: contentItem.implicitWidth + 2*padding
    implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding
    padding: 8
    topPadding: 4
    bottomPadding: topPadding + 2

    contentItem: Text {
        text: control.text
        font: control.font
        opacity: enabled ? 1 : 0.3
        color: "#fefefc"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        opacity: enabled ? 1 : 0.8
        visible: !control.flat || control.down || control.checked || control.highlighted
        color: control.checked ?
                (enabled && control.hovered ?
                    (control.down ? "#7eb830" : "#95ce48") : "#8dc73f") :
                (enabled && control.hovered ?
                    (control.down ? "#31ba78" : "#42ca89") : "#2bb673")
        border.color: control.visualFocus ? "#0066ff" : Qt.darker(color, 1.2)
        border.width: control.visualFocus ? 2 : 1
        radius: parent.height * 0.05
    }
}
