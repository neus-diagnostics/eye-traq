// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright © 2018 Neus Diagnostics, d.o.o.

import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.3
import QtQml.Models 2.2

Item {
    id: main

    width: 800
    height: 800
    visible: true

    property real framerate: 30.0
    property int index: 0

    property var log: []
    property var secondScreen: null // for compatibility with main program
    property real physicalHeight: 324
    property real physicalWidth: 518

    function loadTest(path) {
        play.checked = false
        runner.set({task: 'blank'})
        testFile.text = path
        index = 0
        log = []

        var lines = fileIO.read(path).replace(/\r/g, '').split('\n')
        for (var i = 0; i < lines.length; i++) {
            // discard empty lines
            if (!lines[i])
                continue

            if (lines[i].startsWith('#')) {
                // process header
                var info = lines[i].slice(1).trim().split(': ')
                switch (info[0]) {
                case 'eyetracker':
                    eyetrackerName.text = info[1]
                    break
                case 'program version':
                    version.text = info[1]
                    break
                case 'screen size':
                    var size = info[1].split(' ')
                    physicalWidth = Number(size[0])
                    physicalHeight = Number(size[1])
                    secondScreen = {
                        size: {width: runner.width, height: runner.height},
                        physicalSize: {width: physicalWidth, height: physicalHeight},
                    }
                    break
                }
            } else {
                // log entries
                var fields = lines[i].trim().split('\t')
                var data = JSON.parse(fields[1])
                data.id = log.length
                log.push(data)
            }
        }

        // stable sort & update timestamps
        log.sort(function (a, b) { return a.time - b.time || a.id - b.id })

        keyframes.clear()
        var start = log[0].time
        for (var i = 0; i < log.length; i++) {
            log[i].time = (log[i].time - start) / 1000000.0
            if (log[i].type === 'test')
                keyframes.append({logIndex: i, time: log[i].time, info: JSON.stringify(log[i].test)})
        }

        slider.from = log[0].time
        slider.to = log[log.length-1].time
        slider.value = slider.from
    }

    function timeToIndex(time, low, high) {
        low = low === undefined ? 0 : low
        high = high === undefined ? log.length : high
        if (high - low <= 1)
            return low
        var mid = Math.floor(high/2 + low/2)
        return log[mid].time < time ? timeToIndex(time, mid, high) : timeToIndex(time, low, mid)
    }

    function show(data, stepsOnly) {
        if (data.type === 'gaze') {
            if (!stepsOnly) {
                var gaze = data.gaze
                if (gaze.left.gaze_valid)
                    gazeOverlay.run(Qt.point(gaze.left.gaze_screen.x, gaze.left.gaze_screen.y), 'red')
                if (gaze.right.gaze_valid)
                    gazeOverlay.run(Qt.point(gaze.right.gaze_screen.x, gaze.right.gaze_screen.y), 'blue')
            }
        } else if (data.type === 'test') {
            var test = data.test
            if (test.type === 'step') {
                test.task.task = test.task.name
                runner.set(test.task)
            } else if (test.type === 'started' || test.type === 'done') {
                runner.set({task: 'blank'})
            } else if (test.type === 'data') {
                if (!stepsOnly) {
                    test.data.task = test.data.name
                    runner.set(test.data)
                }
            }
        }
    }

    ColumnLayout {
        anchors { fill: parent; margins: 10 }
        
        RowLayout {
            spacing: 10
            Layout.fillWidth: true
            Button {
                text: qsTr("Load test")
                onClicked: {
                    play.checked = false
                    fileDialog.visible = true
                }
            }
            TextField {
                id: testFile
                Layout.fillWidth: true
                readOnly: true
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            // test info
            Column {
                Layout.preferredWidth: 180
                Label { text: "Program version"; font.pixelSize: 12 }
                TextField {
                    id: version
                    width: parent.width
                    readOnly: true
                }
                Label { text: "Eyetracker"; font.pixelSize: 12 }
                TextField {
                    id: eyetrackerName
                    width: parent.width
                    readOnly: true
                }
                Label { text: "Screen size"; font.pixelSize: 12 }
                RowLayout {
                    width: parent.width * 3/4
                    TextField {
                        text: physicalWidth
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignRight
                    }
                    Label { text: "×"; font.pixelSize: 15; bottomPadding: 8 }
                    TextField {
                        text: physicalHeight
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignLeft
                    }
                    Label { text: "mm²"; font.pixelSize: 15; bottomPadding: 6 }
                }
            }

            // test items
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.rowSpan: 5
                border.width: 1
                ListView {
                    id: list
                    model: ListModel { id: keyframes }
                    anchors { fill: parent; margins: 1 }
                    clip: true

                    highlight: Rectangle { color: "lightsteelblue" }
                    highlightMoveVelocity: 100000

                    delegate: Item {
                        height: childrenRect.height
                        width: parent.width

                        function pad(n) { return (n < 10 ? '0' : '') + n }

                        RowLayout {
                            width: parent.width
                            Text {
                                text: (time / 60).toFixed() + ':' + pad((time % 60).toFixed(3))
                                Layout.preferredWidth: 50
                                Layout.margins: 2
                            }
                            Text {
                                text: info.replace(/<br>/g, ' ')
                                textFormat: Text.PlainText
                                Layout.fillWidth: true
                                Layout.margins: 2
                                maximumLineCount: 1
                                elide: Text.ElideRight
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                list.currentIndex = index
                                main.index = logIndex
                                slider.value = time
                                slider.onMoved()
                            }
                        }
                    }
                    ScrollBar.vertical: ScrollBar { }
                }
            }
        }
            
        Runner {
            id: runner
            Layout.fillWidth: true
            Layout.preferredHeight: width * physicalHeight/physicalWidth
            clip: true
            running: true
            enabled: false

            Gaze { id: gazeOverlay }
        }

        RowLayout {
            enabled: list.count > 0
            Layout.fillWidth: true
            Button {
                id: play
                text: qsTr(checked ? "pause" : "play")
                checkable: true
                onCheckedChanged: {
                    if (checked && slider.value == slider.to) {
                        index = 0
                        slider.value = slider.from
                        slider.onMoved()
                    }
                }
            }
            Slider {
                id: slider
                Layout.fillWidth: true
                onMoved: {
                    // rewind to last test step before current time
                    for (index = timeToIndex(slider.value); index > 0; index--)
                        if (log[index].type === 'test' && log[index].test.type === 'step')
                            break

                    // replay test step and data items before current time
                    while (index < log.length) {
                        if (log[index].time > slider.value)
                            break
                        show(log[index], true)
                        index++
                    }
                    if (index === log.length)
                        play.checked = false

                    var newIndex = 0
                    while (newIndex < list.count-1 && list.model.get(newIndex+1).time <= slider.value)
                        newIndex++
                    list.currentIndex = newIndex
                }
            }
            Label {
                text: slider.value.toFixed(3)
                horizontalAlignment: Text.AlignRight
                Layout.preferredWidth: 50
            }
        }
    }

    Timer {
        id: clock
        interval: 1000/framerate
        repeat: true
        running: play.checked && !slider.pressed
        onTriggered: {
            slider.value += interval/1000
            while (index < log.length && slider.value >= log[index].time) {
                show(log[index])
                index++
            }
            while (list.currentIndex < list.count-1 && list.model.get(list.currentIndex+1).time <= slider.value)
                list.currentIndex++
        }
    }
    
    FileDialog {
        id: fileDialog
        title: "Select a test file"
        onAccepted: loadTest(fileDialog.fileUrl)
    }
}
