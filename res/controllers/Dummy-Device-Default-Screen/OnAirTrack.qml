import QtQuick 2.14
import QtQuick.Controls 2.15

import Mixxx 1.0 as Mixxx
import Mixxx.Controls 1.0 as MixxxControls

Item {
    id: root

    required property string group
    property var deckPlayer: Mixxx.PlayerManager.getPlayer(root.group)

    enum TimerStatus {
        Forward,
        Cooldown,
        Backward
    }

    property string fullText
    property int index

    Component.onCompleted: {
        deckPlayer.artistChanged.connect(onAir.update)
        deckPlayer.titleChanged.connect(onAir.update)
        update()

        onDeckPlayerChanged: () => {
            deckPlayer.artistChanged.connect(onAir.update)
            deckPlayer.titleChanged.connect(onAir.update)
        }
    }

    Rectangle {
        id: frame
        anchors.top: root.top
        anchors.bottom: root.bottom
        width: 1000
        color: 'transparent'
        Text {
            id: text
            text: qsTr("No Track Loaded")
            font.pixelSize: 24
            font.family: "Noto Sans"
            font.letterSpacing: -1
            color: fontColor
        }
    }

    Mixxx.ControlProxy {
        id: trackLoadedControl

        group: root.group
        key: "track_loaded"

        onValueChanged: (value) => {
            timer.stop()
            frame.x = 0
            timer.status = OnAirTrack.TimerStatus.Cooldown
            root.update()
        }
    }

    function update() {
        text.text = `${root.deckPlayer.title} - ${root.deckPlayer.artist}`
        frame.width = text.text.length * 12
        if (text.text.length > 29) {
            timer.start()
        } else {
        }
        if (text.text.trim() == "-") {
            text.text = trackLoadedControl.value ? `Unknown for ${root.group}` : qsTr("No Track Loaded")
        }
    }

    Timer {
        id: timer

        property int status: OnAirTrack.TimerStatus.Cooldown
        property bool backward: false

        interval: 2000
        repeat: true
        running: false

        onTriggered: {
            if (status == OnAirTrack.TimerStatus.Cooldown) {
                status += backward ? -1 : 1
                interval = 100
            }
            frame.x -= backward ? -10 : 10;
            // root.text = `${index}${root.fullText.slice(root.index, root.index+29)}`
            if (-frame.x >= (text.text.length - 29) * 11) {
                backward = true
                status = OnAirTrack.TimerStatus.Cooldown
                interval = 2000
            } else if (frame.x >= 0) {
                backward = false
                status = OnAirTrack.TimerStatus.Cooldown
                interval = 2000
            }
        }
    }
}
