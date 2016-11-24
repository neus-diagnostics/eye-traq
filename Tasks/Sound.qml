import QtMultimedia 5.6

Task {
    function run(time, soundfile) {
        sound.source = "../sounds/" + soundfile
        sound.play()
        _run(time)
    }

    function abort() {
        sound.stop()
        _abort()
    }

    timer.onTriggered: done()

    Audio {
        id: sound
    }
}
