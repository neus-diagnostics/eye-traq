import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Window 2.2

ApplicationWindow {
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
    visibility: Window.FullScreen

    onClosing: Qt.quit()

    StackView {
        id: stack
        anchors.fill: parent
        initialItem: Start {
            onCalibrate: calibrator.init()
            onRecord: recorder.start(testFile, participant)
            onPlay: player.start(logFile)
        }
    }

    Calibrator {
        id: calibrator
    }
}
