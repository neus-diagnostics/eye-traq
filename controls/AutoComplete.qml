import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQml.Models 2.2

import "." as Neus

Item {
    property alias text: input.text
    property alias completions: model.model
    property alias validator: input.validator
    property string field

    function filter() {
        for (var i = 0; i < completions.count; i++)
            if (completions.get(i, field).search(input.text) !== -1)
                model.items.addGroups(i, 1, "matched")
            else
                model.items.removeGroups(i, 1, "matched")
        if (list.count > 0 && list.currentIndex < 0)
            list.currentIndex = 0
    }

    height: input.height

    Neus.TextField {
        id: input
        width: parent.width
        onTextChanged: {
            filter()
            dropdown.visible = text.length > 0 && list.count > 0
        }
        onFocusChanged: {
            if (!focus)
                dropdown.visible = false
        }
        Keys.onPressed: {
            switch (event.key) {
                case Qt.Key_Down:
                    if (dropdown.visible) {
                        list.incrementCurrentIndex()
                    } else {
                        list.currentIndex = 0
                        dropdown.visible = true
                    }
                    break
                case Qt.Key_Up:
                    if (dropdown.visible) {
                        list.decrementCurrentIndex()
                    } else {
                        list.currentIndex = list.count - 1
                        dropdown.visible = true
                    }
                    break
                case Qt.Key_Tab:
                case Qt.Key_Enter:
                case Qt.Key_Return:
                    text = list.currentItem.text
                    // fall through
                case Qt.Key_Escape:
                    dropdown.visible = false
                    break
            }
        }
    }

    Rectangle {
        id: dropdown
        anchors { top: input.bottom; horizontalCenter: input.horizontalCenter }
        width: parent.width - 2
        height: Math.min(parent.height*4, list.contentHeight)

        color: "#eae9e5"
        border.color: "#777777"
        border.width: 1
        visible: false

        ListView {
            id: list
            anchors { fill: parent; margins: parent.border.width }
            clip: true
            keyNavigationWraps: true

            model: DelegateModel {
                id: model

                delegate: Text {
                    text: model[field]
                    width: list.width
                    padding: 2
                    font.bold: ListView.isCurrentItem
                }
                groups: DelegateModelGroup {
                    name: "matched"
                    includeByDefault: true
                    onChanged: filter()
                }
                filterOnGroup: "matched"
            }

            highlight: Rectangle { color: "lightsteelblue" }
            highlightMoveDuration: 0

            ScrollBar.vertical: ScrollBar { }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    var item = list.itemAt(mouseX, mouseY)
                    if (item !== null) {
                        list.currentIndex = list.indexAt(mouseX, mouseY)
                        input.text = item.text
                    }
                    dropdown.visible = false
                }
            }
        }
    }
}
