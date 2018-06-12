import QtQuick 2.7
import QtQuick.Controls 2.0
import QtMultimedia 5.6

import "../controls" as Neus

Task {
    // task arguments: audio (file name), text, align
    function run(task) {
        set(task)
        if (task.audio) {
            audio.source = "file:///" + path + "/share/sounds/" + task.audio
            audio.play()
        }
        _run(task)
    }

    // state data: text, align
    function set(state) {
        message.horizontalAlignment = (state.align == "left" ? Text.AlignLeft : Text.AlignHCenter)
        message.text = state.text || ""
    }

    function abort() {
        audio.stop()
        _abort()
    }

    function pause() {
        audio.pause()
        _pause()
    }

    function unpause() {
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
