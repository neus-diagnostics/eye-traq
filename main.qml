import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Window 2.2

Window {
    function random_id() {
        function pad(number) {
            return (number < 10 ? '0' : '') + number
        }
        var t = new Date()
        return '' + t.getUTCFullYear() + pad(t.getUTCMonth() + 1) + pad(t.getUTCDate()) +
               '-' + pad(t.getUTCHours()) + pad(t.getUTCMinutes()) + pad(t.getUTCSeconds()) +
               '-' + pad(Math.floor(Math.random() * 100))
    }

    title: qsTr("Eyetracker")
    visible: true
    visibility: Window.FullScreen

    onClosing: Qt.quit()
    // QT BUG: force repaint after entering fullscreen
    onActiveChanged: update()

    StackView {
        id: stack

        anchors.fill: parent
        focus: true

        initialItem: Start {
            onCalibrate: calibrator.init()
            onRecord: recorder.start(testFile, participant)
            onPlay: player.start(logFile)
        }

        Keys.onEscapePressed: pop()
    }

    Calibrator {
        id: calibrator
    }
}
