/****************************************************************************
**
** Copyright (C) 2016 The Qt Company Ltd.
** Contact: http://www.qt.io/licensing/
**
** This file is part of the Qt Quick Controls 2 module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL3$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see http://www.qt.io/terms-conditions. For further
** information use the contact form at http://www.qt.io/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 3 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPLv3 included in the
** packaging of this file. Please review the following information to
** ensure the GNU Lesser General Public License version 3 requirements
** will be met: https://www.gnu.org/licenses/lgpl.html.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 2.0 or later as published by the Free
** Software Foundation and appearing in the file LICENSE.GPL included in
** the packaging of this file. Please review the following information to
** ensure the GNU General Public License version 2.0 requirements will be
** met: http://www.gnu.org/licenses/gpl-2.0.html.
**
** $QT_END_LICENSE$
**
****************************************************************************/

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

    font {
        family: "Lato"
        pointSize: 11
    }

    //! [contentItem]
    contentItem: Text {
        text: control.text
        font: control.font
        opacity: enabled ? 1 : 0.3
        color: "#fefefc"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
    //! [contentItem]

    //! [background]
    background: Rectangle {
        opacity: enabled ? 1 : 0.8
        visible: !control.flat || control.down || control.checked || control.highlighted
        color: control.checked ?
                (enabled && control.hovered ?
                    (control.down ? "#7eb830" : "#95ce48") : "#8dc73f") :
                (enabled && control.hovered ?
                    (control.down ? "#31ba78" : "#42ca89") : "#2bb673")
        border.color: control.visualFocus ? "#0066ff" : Qt.darker(color, 1.1)
        border.width: control.visualFocus ? 2 : 1
        radius: parent.height * 0.05
    }
    //! [background]
}
