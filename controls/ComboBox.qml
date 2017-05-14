import QtQuick 2.7
import QtQuick.Controls 2.0

ComboBox {
    id: control
    padding: 0
    background: Rectangle {
        color: control.visualFocus ? (control.pressed ? "#cce0ff" : "#f0f6ff") :
            (control.pressed || popup.visible ? "#d0d0d0" : "#e0e0e0")
        border.color: control.visualFocus ? "#0066ff" : Qt.darker(color)
        border.width: control.visualFocus ? 2 : 1
    }
}
