import QtQuick 2.7
import QtQuick.Controls 2.0
import QtMultimedia 5.6

import "../controls" as Neus

Task {
    // task arguments: audio (file name), text, align
    run: function (task) {
        set(task)
        if (task.audio) {
            audio.source = "file:///" + path + "/share/sounds/" + task.audio
            audio.play()
        }
        _run(task)
    }

    // state data: text, align
    set: function (state) {
        message.horizontalAlignment = (state.align == "left" ? Text.AlignLeft : Text.AlignHCenter)
        message.text = state.text || ""
    }

    abort: function () {
        audio.stop()
        _abort()
    }

    pause: function () {
        audio.pause()
        _pause()
    }

    unpause: function () {
        audio.play()
        _unpause()
    }

    timer.onTriggered: done()

    Neus.Label {
        id: message
        anchors.centerIn: parent
        width: parent.width * 0.66
        wrapMode: Text.WordWrap
        color: 'white'
        font.pixelSize: 43 * parent.height / 1080
        lineHeight: 1.2
        textFormat: Text.StyledText
    }

    Audio { id: audio }
}
