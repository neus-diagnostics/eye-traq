import QtQuick 2.7
import QtQuick.Controls 2.0
import QtMultimedia 5.6

import "../controls" as Neus

Task {
    function run(time, soundfile, align, text) {
        message.horizontalAlignment = (align == "left" ? Text.AlignLeft : Text.AlignHCenter)
        message.text = text || ""
        if (soundfile) {
            audio.source = path + "/share/sounds/" + soundfile
            audio.play()
        }
        _run(time)
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
        font.pointSize: 24
        lineHeight: 1.2
        textFormat: Text.StyledText
    }

    Audio { id: audio }
}
