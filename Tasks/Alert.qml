import QtMultimedia 5.6

Task {
    function run() {
        sound.play()
        _run(500)
    }

    function abort() {
        sound.stop()
        _abort()
    }

    timer.onTriggered: done()

    Audio {
        id: sound
        source: "../resources/alert.oga"
    }
}
