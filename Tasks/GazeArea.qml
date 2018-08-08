import QtQuick 2.7

Item {
    id: control

    // gaze duration before the selected signal is emitted
    property real selectTime: 1.0

    property real time: 0.0 // relative time of the current gaze (0 = no gaze, 1 = selected)
    property bool gazed: time > 0.02

    signal selected

    // we use Animation instead of Timer to keep track of elapsed time
    NumberAnimation on time {
        id: timer

        from: 0.0
        to: 1.0
        duration: control.selectTime * 1000
        running: false

        onStopped: {
            if (control.enabled && time === to)
                selected()
        }
    }

    // reset time when control is disabled
    Binding on time {
        when: !enabled
        value: 0.0
    }

    Connections {
        target: eyetracker
        enabled: control.enabled
        onPointChanged: {
            var valid = point.x != 0.0 || point.y != 0.0
            var saccade = eyetracker.velocity > 0.5
            var gaze = mapFromGlobal(
                secondScreen.geometry.x + eyetracker.point.x * secondScreen.geometry.width,
                secondScreen.geometry.y + eyetracker.point.y * secondScreen.geometry.height)

            if (time > 0.0) {
                // stop gaze timer when a saccade is detected outside control
                if (!valid || !contains(gaze)) {
                    timer.stop()
                    time = 0.0
                }
            } else {
                // start gaze timer when a fixation is detected inside control
                if (valid && (!saccade && contains(gaze)))
                    timer.start()
            }
        }
    }
}
