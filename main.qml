import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Window 2.2

Window {
    title: qsTr("Eyetracker")

    // TODO figure out how to keep window in fullscreen properly
    flags: Qt.FramelessWindowHint
    visible: true
    visibility: Window.FullScreen
    width: Screen.width
    height: Screen.height

    onClosing: Qt.quit()
    // QT BUG: force repaint after entering fullscreen
    onActiveChanged: update()

    FontLoader { source: "fonts/lato-regular.ttf" }
    FontLoader { source: "fonts/lato-bold.ttf" }

    StackView {
        id: stack

        anchors.fill: parent
        focus: true

        initialItem: Start {
            onOptions: stack.push(options)
            onCalibrate: calibrator.init()
            onTest: recorder.start(options.testFile, options.participant)
        }

        Keys.onPressed: {
            switch (event.key) {
                case Qt.Key_Backspace:
                case Qt.Key_Escape:
                    pop();
                    break;
            }
        }

        Options { id: options }
    }

    Calibrator { id: calibrator }
}
