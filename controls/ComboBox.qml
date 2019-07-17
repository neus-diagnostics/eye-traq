// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright © 2016 The Qt Company Ltd.
// Copyright © 2017 Neus Diagnostics, d.o.o.

import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Controls 2.0
import QtQuick.Templates 2.0 as T

T.ComboBox {
    id: control

    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                             Math.max(contentItem.implicitHeight,
                                      indicator ? indicator.implicitHeight : 0) + topPadding + bottomPadding)
    baselineOffset: contentItem.y + contentItem.baselineOffset

    padding: 4
    leftPadding: padding + 2
    rightPadding: leftPadding

    hoverEnabled: true
    opacity: enabled ? 1 : 0.3

    delegate: ItemDelegate {
        width: control.popup.width
        padding: 4
        leftPadding: padding + 2
        rightPadding: leftPadding
        text: control.textRole ? (Array.isArray(control.model) ? modelData[control.textRole] : model[control.textRole]) : modelData
        font {
            family: control.font.family
            pointSize: control.font.pointSize
            weight: control.currentIndex === index ? Font.DemiBold : Font.Normal
        }
        highlighted: control.highlightedIndex == index

        hoverEnabled: true
        background: Rectangle {
            color: hovered ? "#42ca89" : "#eae9e5"
        }
    }

    contentItem: Text {
        leftPadding: control.mirrored && control.indicator ? control.indicator.width + control.spacing : 0
        rightPadding: !control.mirrored && control.indicator ? control.indicator.width + control.spacing : 0

        text: control.displayText
        font: control.font
        color: control.visualFocus ? "#0066ff" : "#353637"
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        color: control.popup.visible || hovered ? Qt.darker("#eae9e5", 1.05) : "#eae9e5"
        border.color: "#777777"
        border.width: 1
    }

    popup: T.Popup {
        y: control.height - (control.visualFocus ? 0 : 1)
        width: control.width
        implicitHeight: contentItem.implicitHeight

        contentItem: ListView {
            id: listview
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex
            highlightRangeMode: ListView.ApplyRange
            highlightMoveDuration: 0

            Rectangle {
                z: 10
                parent: listview
                width: listview.width
                height: listview.height
                color: "transparent"
                border.color: "#777777"
            }

            T.ScrollIndicator.vertical: ScrollIndicator { }
        }

        background: Rectangle { }
    }
}
