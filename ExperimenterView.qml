import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.2

Item {
    width: Screen.width
    height: Screen.height

    StackView {
        id: stack

        anchors.fill: parent
        focus: true

        initialItem: Start {
            onOptions: stack.push(options)
            onCalibrate: calibrator.init()
            onTest: recorder.start(options.testFile, options.participant)
            onAbout: stack.push(about)
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
        About { id: about }
    }

    Calibrator { id: calibrator }
}
