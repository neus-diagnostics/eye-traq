import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.1
import QtQuick.Layouts 1.3
import QtQml.Models 2.2

ApplicationWindow {
    id: main

    title: qsTr("Neus player")
    width: 800
    height: 800
    visible: true

    property var framerate: 30
    property var index: 0

    function loadTest(path) {
        play.checked = false
        testFile.text = path
        index = 0
        dataModel.clear()
        runner.set({name: 'blank'})

        var testargs = undefined
        var data = []

        var lines = fileIO.read(path).replace(/\r/g, '').split('\n')
        for (var i = 0; i < lines.length; i++) {
            // discard empty lines
            if (!lines[i])
                continue

            // process header
            if (lines[i].startsWith('#')) {
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
                    physicalWidth.text = size[0]
                    physicalHeight.text = size[1]
                    break
                }
                continue
            }

            // process test / gaze data
            var fields = lines[i].trim().split('\t')
            var time = Number(fields[0])

            if (fields[1] == 'gaze' && fields[5] == 'true') {
                data.push({
                    time: time,
                    type: 'gaze',
                    eye: fields[2],
                    x: Number(fields[6]),
                    y: Number(fields[7]),
                })
            } else if (fields[1] == 'test') {
                var args = undefined
                var info = undefined
                if (fields[2] == 'step') {
                    switch (fields[4]) {
                    case 'blank':
                        args = ['blank']
                        break
                    case 'imgpair':
                        var left = fields[5]
                        var right = fields[6]
                        args = ['imgpair', left, right]
                        info = 'imgpair [' + left + ', ' + right + ']'
                        break
                    case "pursuit":
                        testargs = ['pursuit']
                        info = 'pursuit [' + (fields[5] == 'x' ? 'horizontal' : 'vertical') + ']'
                        break
                    case "saccade":
                        var dir = fields[6]
                        var offset = 10*fields[7] / Number((dir == 'x' ? physicalWidth : physicalHeight).text)
                        // fixup old bad recordings
                        if (fields.length <= 9)
                            fields.push('pro')
                        if (fields[9] == 'false')
                            fields[9] = 'anti'
                        if (fields[8] == 'false')
                            fields[8] = 'step'
                        testargs = ['saccade', dir, offset]
                        info = fields[9] + '-saccade [' + (dir == 'x' ? 'horizontal' : 'vertical') + ', ' + fields[8] + ']'
                        break
                    case "message":
                        var align = fields[6]
                        var text = fields[7]
                        args = ['message', align, text]
                        info = fields.length < 7 ? 'alert' : ('message: ' + text)
                        break
                    }
                } else if (fields[2] == 'data') {
                    switch (testargs[0]) {
                    case "pursuit":
                        args = testargs.concat([Number(fields[3]), Number(fields[4])])
                        break
                    case "saccade":
                        args = testargs.concat([fields[3] == 'true', fields[4] == 'true'])
                        break
                    }
                } else {
                    // test start / done / …
                    args = ['blank']
                }

                // TODO sorted insert (by timestamp)
                if (args !== undefined)
                    data.push({time: time, type: 'test', args: JSON.stringify(args),})
                if (info !== undefined)
                    data.push({time: time-1, type: 'info', info: info})
            }
        }

        // update model
        data.unshift({time: data[0].time, type: 'info', info: 'test start'})
        data.sort(function (a, b) { return a.time - b.time })
        var start = data[0].time
        for (var i = 0; i < data.length; i++) {
            data[i].time = (data[i].time - start) / 1000000
            dataModel.append(data[i])
            if (data[i]['type'] == 'info')
                visualModel.items.addGroups(i, 1, ['info'])
        }

        slider.from = data[0].time
        slider.to = data[data.length-1].time
        slider.value = slider.from
    }

    function update() {
        while (index < dataModel.count) {
            var item = dataModel.get(index)
            if (item.time > slider.value)
                break
            if (item.type == 'gaze') {
                gazeOverlay.run(Qt.point(item.x, item.y))
            } else if (item.type == 'test') {
                var args = JSON.parse(item.args)
                runner.set({'name': args[0], 'args': args.slice(1)})
            }
            index++
            if (index == dataModel.count)
                play.checked = false
        }
        while (list.currentIndex < list.count-1 && infoGroup.get(list.currentIndex+1).model.time < slider.value)
            list.currentIndex++
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
                anchors.top: parent.top
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
                        id: physicalWidth
                        text: "518"
                        Layout.fillWidth: true
                        maximumLength: 4
                        validator: IntValidator { bottom: 0; top: 9999 }
                        horizontalAlignment: Text.AlignRight
                    }
                    Label { text: "×"; font.pixelSize: 15; bottomPadding: 8 }
                    TextField {
                        id: physicalHeight
                        text: "324"
                        Layout.fillWidth: true
                        maximumLength: 4
                        validator: IntValidator { bottom: 0; top: 9999 }
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
                    anchors { fill: parent; margins: 1 }
                    clip: true

                    model: visualModel
                    highlight: Rectangle { color: "lightsteelblue" }
                    highlightMoveVelocity: 100000

                    ScrollBar.vertical: ScrollBar { }
                }
            }
        }
            
        Runner {
            id: runner
            Layout.fillWidth: true
            Layout.preferredHeight: width * 9/16
            clip: true
            running: true

            Gaze { id: gazeOverlay }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.ArrowCursor
            }
        }

        RowLayout {
            enabled: list.count > 0
            Layout.fillWidth: true
            Button {
                id: play
                text: qsTr(checked ? "⏸" : "►")
                checkable: true
                onCheckedChanged: {
                    if (checked && slider.value == slider.to) {
                        index = 0
                        slider.value = slider.from
                    }
                }
            }
            Slider {
                id: slider
                Layout.fillWidth: true
                onMoved: {
                    for (list.currentIndex = 0;
                            list.currentIndex < list.count-1 && infoGroup.get(list.currentIndex+1).model.time < value;
                            list.currentIndex++)
                        ;
                    var item = infoGroup.get(list.currentIndex)
                    index = item.itemsIndex
                    value = item.model.time
                    update()
                }
            }
            Label {
                text: slider.value.toFixed(3)
                horizontalAlignment: Text.AlignRight
                Layout.preferredWidth: 50
            }
        }
    }

    ListModel { id: dataModel }
    DelegateModel {
        id: visualModel
        model: dataModel

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
                    list.currentIndex = visualModel.items.get(index).infoIndex
                    main.index = index
                    slider.value = dataModel.get(index).time
                }
            }
        }
        groups: [
            DelegateModelGroup { id: infoGroup; name: "info"; includeByDefault: false }
        ]
        filterOnGroup: "info"
    }

    Timer {
        id: clock
        interval: 1000/framerate
        repeat: true
        running: play.checked && !slider.pressed
        onTriggered: {
            slider.value += interval/1000
            update()
        }
    }
    
    FileDialog {
        id: fileDialog
        title: "Select a test file"
        folder: shortcuts.home
        onAccepted: loadTest(fileDialog.fileUrl)
    }
}
