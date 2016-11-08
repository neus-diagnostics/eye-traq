import QtQuick 2.7
import QtQuick.Controls 2.0

StackView {
    id: stack

    property var runner

    focus: true

    initialItem: Start {
        onOptions: push(options)
        onCalibrate: push(calibrate)
        onPractice: push(practice)
        onTest: push(test)
        onAbout: push(about)
    }

    Keys.onPressed: {
        if (busy)
            return
        switch (event.key) {
            case Qt.Key_Backspace:
            case Qt.Key_Escape:
                //recorder.reset()  // TODO move this somewhere else
                pop()
                break
        }
    }

    Options {
        id: options
        visible: false
    }
    Calibrate {
        id: calibrate
        visible: false
        options: options
        runner: stack.runner
    }
    Practice {
        id: practice
        visible: false
        options: options
        runner: stack.runner
    }
    Test {
        id: test
        visible: false
        options: options
        runner: stack.runner
    }
    About {
        id: about
        visible: false
    }
}
