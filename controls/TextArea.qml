import QtQuick 2.7
import QtQuick.Controls 2.0

Flickable {
    property alias text: area.text

    TextArea.flickable: TextArea {
        id: area

        padding: 4
        font.pointSize: 10
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
