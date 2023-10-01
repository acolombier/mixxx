import QtQuick 2.15
import QtQuick.Window 2.3
import QtQuick.Scene3D 2.14

import QtQuick.Controls 2.15
import QtQuick.Shapes 1.11
import QtQuick.Layouts 1.3
import QtQuick.Window 2.15

import Qt5Compat.GraphicalEffects

import Mixxx 1.0 as Mixxx
import Mixxx.Controls 1.0 as MixxxControls

// Import other project QML scripts
import "Traktor-Kontrol-S4-MK3-Screens" as S4MK3

Item {
    id: root

    required property string screenId
    property color fontColor: Qt.rgba(242/255,242/255,242/255, 1)
    property color smallBoxBorder: Qt.rgba(44/255,44/255,44/255, 1)

    property string group: "[Channel1]"
    property var deckPlayer: Mixxx.PlayerManager.getPlayer(root.group)

    property var _items_needing_redraw: new Set()

    Timer {
        id: timer
    }
    function setTimeout(cb, delayTime) {
        timer.interval = delayTime;
        timer.repeat = false;
        timer.triggered.connect(cb);
        timer.start();
    }

    function init(controlerName, isDebug) {
        console.log(`Screen ${root.screenId} has started`)
        loader.sourceComponent = live
        group = screenId === "rightdeck" ? "[Channel2]" : "[Channel1]"
        onAir.update()
    }

    function shutdown() {
        console.log(`Screen ${root.screenId} is stopping`)
        loader.sourceComponent = splashoff
    }

    function transformFrame(input) {
        const areasToDraw = []
        let totalPixelToDraw = 0;

        if (!_items_needing_redraw.size) { // No redraw needed
            return new ArrayBuffer(0);
        } else if (_items_needing_redraw.has(root)) { // Full redraw needed
            areasToDraw.push([0, 0, 320, 240]);
            totalPixelToDraw += 320 * 240;
        } else { // Partial redraw needed
            _items_needing_redraw.forEach(function(item) {
                    const pos = item.mapToGlobal(0, 0)
                    console.log(`Redrawing item ${item}`)
                    let x = pos.x, y = pos.y, width = item.width, height = item.height;
                    areasToDraw.push([pos.x, pos.y, item.width, item.height])
                    totalPixelToDraw += item.width * item.height;
            });
            // Note: Some area could overlap and this could be optimised, but the cost of checking that every time vs.
            // the optimisation for when it is happening is likely not worth it
        }
        _items_needing_redraw.clear()

        // console.log(`Redrawing ${totalPixelToDraw} the following region: ${areasToDraw}`)

        const screenIdx = screenId === "leftdeck" ? 0 : 1;

        const outputData = new ArrayBuffer(totalPixelToDraw*2 + 20*areasToDraw.length);
        let offset = 0;

        for (const area of areasToDraw) {
            const [x, y, width, height] = area;
            const header = new Uint8Array(outputData, offset, 16);
            const payload = new Uint8Array(outputData, offset + 16, width*height*2);
            const footer = new Uint8Array(outputData, offset + width*height*2 + 16, 4);

            header.fill(0)
            footer.fill(0)
            header[0] = 0x84;
            header[2] = screenIdx;
            header[3] = 0x21;

            header[8] = x >> 8;
            header[9] = x & 0xff;
            header[10] = y >> 8;
            header[11] = y & 0xff;

            header[12] = width >> 8;
            header[13] = width & 0xff;
            header[14] = height >> 8;
            header[15] = height & 0xff;

            if (x === 0 && width === 320) {
                payload.set(new Uint8Array(input, y * 320 * 2, width*height*2));
            } else {
                for (let line = 0; line < height; line++) {
                    payload.set(new Uint8Array(input, ((y + line) * 320 + x) * 2, width*2), line*width*2);
                }
            }
            footer[0] = 0x40;
            footer[2] = screenIdx;
            offset += width*height*2 + 20
        }
        // console.log(`Generated ${offset} bytes to be sent`)
        return outputData;
    }

    Mixxx.ControlProxy {
        id: trackLoadedControl

        group: root.group
        key: "track_loaded"

        onValueChanged: (value) => {
            _items_needing_redraw.add(root)
        }
    }

    Component {
        id: splashoff
        Rectangle {
            anchors.fill: parent
            color: "black"

            Image {
                anchors.centerIn: parent
                width: root.width*0.8
                height: root.height
                fillMode: Image.PreserveAspectFit
                source: "../images/templates/logo_mixxx.png" // loads cat.png
            }
        }
    }
    Component {
        id: live

        Rectangle {
            anchors.fill: parent
            color: "black"

            function onRuntimeDataUpdate(data) {
                console.log(`Received data on screen#${root.screenId} while currently bind to ${root.group}: ${JSON.stringify(data)}`);
                if (typeof data === "object" && typeof data.group === "object" && data.group.length === 2 && typeof data.group[root.screenId] === "string" && root.group !== data.group[root.screenId]) {
                    root.group = data.group[root.screenId]
                    console.log(`Changed group for screen ${root.screenId} to ${root.group}`);
                }
                var shouldBeCompacted = false;
                if (typeof data.zoomedWaveform === "object") {
                    shouldBeCompacted |= data.zoomedWaveform[root.group]
                    waveformZoomed.visible = data.zoomedWaveform[root.group]
                }
                if (typeof data.keyboardMode === "object") {
                    shouldBeCompacted |= data.keyboardMode[root.group]
                    keyboard.visible = !!data.keyboardMode[root.group]
                }
                deckInfo.state = shouldBeCompacted ? "compacted" : ""
                if (typeof data.displayBeatloopSize === "object") {
                    timeIndicator.mode = data.displayBeatloopSize[root.screenId] ? S4MK3.TimeAndBeatloopIndicator.Mode.BeetjumpSize : S4MK3.TimeAndBeatloopIndicator.Mode.RemainingTime
                    timeIndicator.update()
                }
            }

            Component.onCompleted: {
                // engine.onRuntimeDataUpdate(onRuntimeDataUpdate)
                if (root.screenId === "rightdeck") {
                    root.group = "[Channel2]"
                }

                onRuntimeDataUpdate({
                    // zoomedWaveform: {
                    //     "[Channel1]": true
                    // }
                })

                // root.deckPlayer.onWaveformLengthChanged((value) => {
                //     console.warn("Changed!!")
                // })
                // root.deckPlayer.onWaveformTextureChanged((value) => {
                //     console.warn("Changed!!")
                // })
                // root.deckPlayer.onWaveformTextureSizeChanged((value) => {
                //     console.warn("Changed!!")
                // })
                // setTimeout(() => {root._items_needing_redraw.add(this);}, 1000);
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: 6
                anchors.rightMargin: 6
                anchors.topMargin: 2
                anchors.bottomMargin: 6
                spacing: 6

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    color: "transparent"

                    RowLayout {
                        anchors.fill: parent
                        spacing: 1

                        S4MK3.OnAirTrack {
                            id: onAir
                            group: root.group
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            onUpdated: {
                                root._items_needing_redraw.add(this)
                            }
                        }
                    }
                }

                // Indicator
                Rectangle {
                    id: deckInfo

                    Layout.fillWidth: true
                    Layout.preferredHeight: 105
                    color: "transparent"

                    GridLayout {
                        id: gridLayout
                        anchors.fill: parent
                        columnSpacing: 6
                        rowSpacing: 6
                        columns: 2

                        // Section: Key
                        S4MK3.KeyIndicator {
                            id: keyIndicator
                            group: root.group
                            borderColor: smallBoxBorder

                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            onUpdated: {
                                root._items_needing_redraw.add(this)
                            }
                        }

                        // Section: Bpm
                        S4MK3.BPMIndicator {
                            id: bpmIndicator
                            group: root.group
                            borderColor: smallBoxBorder

                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            onUpdated: {
                                root._items_needing_redraw.add(this)
                            }
                        }

                        // Section: Key
                        S4MK3.TimeAndBeatloopIndicator {
                            id: timeIndicator
                            group: root.group

                            Layout.fillWidth: true
                            Layout.preferredHeight: 72
                            timeColor: smallBoxBorder

                            onUpdated: {
                                root._items_needing_redraw.add(this)
                            }
                        }

                        // Section: Bpm
                        S4MK3.LoopSizeIndicator {
                            id: loopSizeIndicator
                            group: root.group

                            Layout.fillWidth: true
                            Layout.preferredHeight: 72

                            onUpdated: {
                                root._items_needing_redraw.add(this)
                            }
                        }
                    }
                    states: State {
                        name: "compacted"

                        PropertyChanges {
                            target:deckInfo
                            Layout.preferredHeight: 28
                        }
                        PropertyChanges {
                            target: gridLayout
                            columns: 4
                        }
                        PropertyChanges {
                            target: bpmIndicator
                            state: "compacted"
                        }
                        PropertyChanges {
                            target: timeIndicator
                            Layout.preferredHeight: -1
                            Layout.fillHeight: true
                            state: "compacted"
                        }
                        PropertyChanges {
                            target: loopSizeIndicator
                            Layout.preferredHeight: -1
                            Layout.fillHeight: true
                            state: "compacted"
                        }
                    }

                    onStateChanged: {
                        root._items_needing_redraw.add(root)
                    }
                }

                // Track progress
                Item {
                    // Layout.preferredHeight: 40
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    layer.enabled: true

                    S4MK3.Progression {
                        id: progression
                        group: root.group

                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom

                        onUpdated: {
                            root._items_needing_redraw.add(waveform)
                        }
                    }

                    MixxxControls.WaveformOverview {
                        id: waveform
                        group: root.group
                        anchors.fill: parent
                        channels: Mixxx.WaveformOverview.Channels.BothChannels
                        renderer: Mixxx.WaveformOverview.Renderer.RGB
                        colorHigh: 'white'
                        colorMid: 'blue'
                        colorLow: 'green'
                    }

                    // Hotcue
                    Repeater {
                        model: 8

                        S4MK3.HotcuePoint {
                            required property int index

                            Mixxx.ControlProxy {
                                id: samplesControl

                                group: root.group
                                key: "track_samples"

                                onValueChanged: (value) => {
                                    _items_needing_redraw.add(waveform)
                                }
                            }

                            Mixxx.ControlProxy {
                                id: hotcueEnabled
                                group: root.group
                                key: `hotcue_${index}_status`

                                onValueChanged: (value) => {
                                    _items_needing_redraw.add(waveform)
                                }
                            }

                            Mixxx.ControlProxy {
                                id: hotcuePosition
                                group: root.group
                                key: `hotcue_${index}_position`

                                onValueChanged: (value) => {
                                    _items_needing_redraw.add(waveform)
                                }
                            }

                            anchors.top: parent.top
                            // anchors.left: parent.left
                            anchors.bottom: parent.bottom
                            visible: hotcueEnabled.value

                            number: this.index
                            type: S4MK3.HotcuePoint.Type.OneShot
                            position: hotcuePosition.value / samplesControl.value
                        }
                    }

                    // Intro
                    S4MK3.HotcuePoint {

                        Mixxx.ControlProxy {
                            id: introStartEnabled
                            group: root.group
                            key: `intro_start_enabled`

                            onValueChanged: (value) => {
                                _items_needing_redraw.add(waveform)
                            }
                        }

                        Mixxx.ControlProxy {
                            id: introStartPosition
                            group: root.group
                            key: `intro_start_position`

                            onValueChanged: (value) => {
                                _items_needing_redraw.add(waveform)
                            }
                        }

                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        visible: introStartEnabled.value

                        type: S4MK3.HotcuePoint.Type.IntroIn
                        position: introStartPosition.value / samplesControl.value
                    }

                    // Extro
                    S4MK3.HotcuePoint {

                        Mixxx.ControlProxy {
                            id: introEndEnabled
                            group: root.group
                            key: `intro_end_enabled`

                            onValueChanged: (value) => {
                                _items_needing_redraw.add(waveform)
                            }
                        }

                        Mixxx.ControlProxy {
                            id: introEndPosition
                            group: root.group
                            key: `intro_end_position`

                            onValueChanged: (value) => {
                                _items_needing_redraw.add(waveform)
                            }
                        }

                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        visible: introEndEnabled.value

                        type: S4MK3.HotcuePoint.Type.IntroOut
                        position: introEndPosition.value / samplesControl.value
                    }

                    // Loop in
                    S4MK3.HotcuePoint {
                        Mixxx.ControlProxy {
                            id: loopStartPosition
                            group: root.group
                            key: `loop_start_position`

                            onValueChanged: (value) => {
                                _items_needing_redraw.add(waveform)
                            }
                        }

                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        visible: loopStartPosition.value > 0

                        type: S4MK3.HotcuePoint.Type.LoopIn
                        position: loopStartPosition.value / samplesControl.value
                    }

                    // Loop out
                    S4MK3.HotcuePoint {
                        Mixxx.ControlProxy {
                            id: loopEndPosition
                            group: root.group
                            key: `loop_end_position`

                            onValueChanged: (value) => {
                                _items_needing_redraw.add(waveform)
                            }
                        }

                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        visible: loopEndPosition.value > 0

                        type: S4MK3.HotcuePoint.Type.LoopOut
                        position: loopEndPosition.value / samplesControl.value
                    }

                    Item {
                        id: waveformZoomed

                        property var group: root.group
                        property real scale: 0.2

                        visible: false
                        antialiasing: true
                        anchors.fill: parent

                            // MixxxControls.WaveformDisplay {
                            //     anchors.fill: parent
                            //     group: waveformZoomed.group
                            //     scale: waveformZoomed.scale
                            // }

                        Rectangle {
                            color: "white"
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            x: 153
                            width: 2
                        }
                        Item {
                            id: waveformContainer

                            property real duration: samplesControl.value / sampleRateControl.value

                            anchors.fill: parent
                            clip: true

                            Mixxx.ControlProxy {
                                id: samplesControl

                                group: root.group
                                key: "track_samples"
                            }

                            Mixxx.ControlProxy {
                                id: sampleRateControl

                                group: root.group
                                key: "track_samplerate"
                            }

                            Mixxx.ControlProxy {
                                id: playPositionControl

                                group: root.group
                                key: "playposition"
                            }

                            Mixxx.ControlProxy {
                                id: rateRatioControl

                                group: root.group
                                key: "rate_ratio"
                            }

                            Mixxx.ControlProxy {
                                id: zoomControl

                                group: root.group
                                key: "waveform_zoom"
                            }

                            Item {
                                id: waveformBeat

                                property real effectiveZoomFactor: (zoomControl.value * rateRatioControl.value / waveformZoomed.scale) * 6

                                width: waveformContainer.duration * effectiveZoomFactor
                                height: parent.height
                                x: 0.5 * waveformContainer.width - playPositionControl.value * width
                                visible: true

                                Shape {
                                    id: preroll

                                    property real triangleHeight: waveformBeat.height
                                    property real triangleWidth: 0.25 * waveformBeat.effectiveZoomFactor
                                    property int numTriangles: Math.ceil(width / triangleWidth)

                                    anchors.top: waveformBeat.top
                                    anchors.right: waveformBeat.left
                                    width: Math.max(0, waveformBeat.x)
                                    height: waveformBeat.height

                                    ShapePath {
                                        strokeColor: 'red'
                                        strokeWidth: 1
                                        fillColor: "transparent"

                                        PathMultiline {
                                            paths: {
                                                let p = [];
                                                for (let i = 0; i < preroll.numTriangles; i++) {
                                                    p.push([Qt.point(preroll.width - i * preroll.triangleWidth, preroll.triangleHeight / 2), Qt.point(preroll.width - (i + 1) * preroll.triangleWidth, 0), Qt.point(preroll.width - (i + 1) * preroll.triangleWidth, preroll.triangleHeight), Qt.point(preroll.width - i * preroll.triangleWidth, preroll.triangleHeight / 2)]);
                                                }
                                                return p;
                                            }
                                        }
                                    }
                                }

                                Shape {
                                    id: postroll

                                    property real triangleHeight: waveformBeat.height
                                    property real triangleWidth: 0.25 * waveformBeat.effectiveZoomFactor
                                    property int numTriangles: Math.ceil(width / triangleWidth)

                                    anchors.top: waveformBeat.top
                                    anchors.left: waveformBeat.right
                                    width: waveformContainer.width / 2
                                    height: waveformBeat.height

                                    ShapePath {
                                        strokeColor: 'red'
                                        strokeWidth: 1
                                        fillColor: "transparent"

                                        PathMultiline {
                                            paths: {
                                                let p = [];
                                                for (let i = 0; i < postroll.numTriangles; i++) {
                                                    p.push([Qt.point(i * postroll.triangleWidth, postroll.triangleHeight / 2), Qt.point((i + 1) * postroll.triangleWidth, 0), Qt.point((i + 1) * postroll.triangleWidth, postroll.triangleHeight), Qt.point(i * postroll.triangleWidth, postroll.triangleHeight / 2)]);
                                                }
                                                return p;
                                            }
                                        }
                                    }
                                }
                            }

                            MixxxControls.WaveformOverview {
                                property real duration: samplesControl.value / sampleRateControl.value

                                    // anchors.fill: parent
                                    // clip: true

                                group: root.group
                                anchors.fill: parent
                                channels: Mixxx.WaveformOverview.Channels.BothChannels
                                renderer: Mixxx.WaveformOverview.Renderer.RGB
                                colorHigh: 'white'
                                colorMid: 'blue'
                                colorLow: 'green'
                            }
                        }
                    }
                }

                // spacer item
                S4MK3.Keyboard {
                    id: keyboard
                    group: root.group
                    visible: false
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }
    }

    Loader {
        id: loader
        anchors.fill: parent
        sourceComponent: live
        onLoaded: {
            setTimeout(() => _items_needing_redraw.add(root), 100);
        }
    }
}
