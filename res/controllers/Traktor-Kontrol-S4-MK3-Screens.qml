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
            root.deckPlayer = Mixxx.PlayerManager.getPlayer(root.group)

            onAir.group = root.group
            onAir.deckPlayer = root.deckPlayer
            onAir.deckPlayer.artistChanged.connect(onAir.update)
            onAir.deckPlayer.titleChanged.connect(onAir.update)
            onAir.update()

            keyIndicator .group = root.group
            bpmIndicator.group = root.group
            timeIndicator.group = root.group
            waveform.group = root.group
            waveformZoomed.group = root.group
            progression.group = root.group
            keyboard.group = root.group

            console.log(`Changed group for screen ${root.screenId} to ${root.group}`);
        }
        if (typeof data.zoomedWaveform === "object") {
            deckInfo.state = data.zoomedWaveform[root.group] ? "compacted" : ""
            waveformZoomed.visible = data.zoomedWaveform[root.group]
        }
        if (typeof data.keyboardMode === "object") {
            deckInfo.state = data.keyboardMode[root.group] ? "compacted" : ""
            keyboard.visible = !!data.keyboardMode[root.group]
        }
        if (typeof data.displayBeatloopSize === "object") {
            timeIndicator.mode = data.displayBeatloopSize[root.screenId] ? S4MK3.TimeAndBeatloopIndicator.Mode.BeetjumpSize : S4MK3.TimeAndBeatloopIndicator.Mode.RemainingTime
            timeIndicator.update()
        }
    }

    Component.onCompleted: {
        onAir.deckPlayer.artistChanged.connect(onAir.update)
        onAir.deckPlayer.titleChanged.connect(onAir.update)
        onAir.update()

        engine.onRuntimeDataUpdate(onRuntimeDataUpdate)

        onRuntimeDataUpdate(engine.getRuntimeData())
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
                    deckPlayer: root.deckPlayer
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

            Item {
                id: waveformZoomed

                property var group: root.group

                visible: false
                anchors.fill: parent

                MixxxControls.WaveformDisplay {
                    anchors.fill: parent
                    group: waveformZoomed.group
                }

                Rectangle {
                    color: "white"
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    x: 153
                    width: 2
                }
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
