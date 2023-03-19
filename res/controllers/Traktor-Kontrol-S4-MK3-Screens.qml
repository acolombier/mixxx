import QtQuick 2.15
import QtQuick.Window 2.3
import QtQuick.Scene3D 2.14

import QtQuick.Controls 2.15
import QtQuick.Shapes 1.11
import QtQuick.Layouts 1.3

import Qt5Compat.GraphicalEffects

import Mixxx 1.0 as Mixxx
import Mixxx.Controls 1.0 as MixxxControls

// Import other project QML scripts
import "Traktor-Kontrol-S4-MK3-Screens" as S4MK3

Rectangle {
    id: root

    required property int screenId
    property color fontColor: Qt.rgba(242/255,242/255,242/255, 1)
    property color smallBoxBorder: Qt.rgba(44/255,44/255,44/255, 1)

    property string group: "[Channel1]"
    property var deckPlayer: Mixxx.PlayerManager.getPlayer(root.group)

    visible: true
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
        engine.onRuntimeDataUpdate(onRuntimeDataUpdate)

        onRuntimeDataUpdate(engine.getRuntimeData())

        // root.deckPlayer.onWaveformLengthChanged((value) => {
        //     console.warn("Changed!!")
        // })
        // root.deckPlayer.onWaveformTextureChanged((value) => {
        //     console.warn("Changed!!")
        // })
        // root.deckPlayer.onWaveformTextureSizeChanged((value) => {
        //     console.warn("Changed!!")
        // })
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
                }

                // Section: Bpm
                S4MK3.BPMIndicator {
                    id: bpmIndicator
                    group: root.group
                    borderColor: smallBoxBorder

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                // Section: Key
                S4MK3.TimeAndBeatloopIndicator {
                    id: timeIndicator
                    group: root.group

                    Layout.fillWidth: true
                    Layout.preferredHeight: 72
                    timeColor: smallBoxBorder
                }

                // Section: Bpm
                S4MK3.LoopSizeIndicator {
                    id: loopSizeIndicator
                    group: root.group

                    Layout.fillWidth: true
                    Layout.preferredHeight: 72
                }
            }
            states: State {
                name: "compacted"

                PropertyChanges {
                    target:deckInfo
                    Layout.preferredHeight: 33
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

            // Repeater {
            //     model: 8

            //     S4MK3.HotcuePoint {
            //         required property int index

            //         anchors.top: parent.top
            //         // anchors.left: parent.left
            //         anchors.bottom: parent.bottom

            //         number: this.index + 1
            //         type: this.index % (S4MK3.HotcuePoint.Type.LoopOut + 1)
            //         position: 0.1 + (this.index / 10)
            //     }
            // }
        }

        Item {
            id: waveformZoomed

            property real duration: samplesControl.value / sampleRateControl.value

            Layout.fillWidth: true
            Layout.fillHeight: true
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
                onValueChanged: (value) => {
                    if (value < 1) {
                        zoomControl.value = 1
                    }
                }
            }

            Item {
                id: waveformRender

                property real effectiveZoomFactor: rateRatioControl.value * zoomControl.value * 5

                width: waveformZoomed.duration * effectiveZoomFactor
                height: parent.height
                x: 0.5 * waveformZoomed.width - playPositionControl.value * width
                // visible: root.deckPlayer.isLoaded

                MixxxControls.WaveformShader {
                    group: root.group
                    anchors.fill: parent
                }

                Shape {
                    id: preroll

                    property real triangleHeight: waveformRender.height
                    property real triangleWidth: 0.25 * waveformRender.effectiveZoomFactor
                    property int numTriangles: Math.ceil(width / triangleWidth)

                    anchors.top: waveformRender.top
                    anchors.right: waveformRender.left
                    width: Math.max(0, waveformRender.x)
                    height: waveformRender.height

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

                    property real triangleHeight: waveformRender.height
                    property real triangleWidth: 0.25 * waveformRender.effectiveZoomFactor
                    property int numTriangles: Math.ceil(width / triangleWidth)

                    anchors.top: waveformRender.top
                    anchors.left: waveformRender.right
                    width: waveformZoomed.width / 2
                    height: waveformRender.height

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

                Repeater {
                    model: root.deckPlayer.beatsModel

                    Rectangle {
                        width: 1
                        height: waveformRender.height
                        x: (framePosition * 2 / samplesControl.value) * waveformRender.width
                        color: 'red'
                    }
                }
            }

            Shape {
                id: playMarkerShape

                anchors.fill: parent

                ShapePath {
                    id: playMarkerPath

                    startX: waveformZoomed.width / 2
                    startY: 0
                    strokeColor: 'red'
                    strokeWidth: 1

                    PathLine {
                        id: marker

                        x: playMarkerPath.startX
                        y: playMarkerShape.height
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
