import QtQuick 2.14
import QtQuick.Controls 2.15

import Mixxx 1.0 as Mixxx
import Mixxx.Controls 1.0 as MixxxControls

Rectangle {
    id: root

    required property string group

    property color timeColor: Qt.rgba(67/255,70/255,66/255, 1)
    property color beatjumpColor: 'yellow'

    enum Mode {
        RemainingTime,
        BeetjumpSize
    }

    property int mode: TimeAndBeatloopIndicator.Mode.RemainingTime

    radius: 6
    border.color: timeColor
    border.width: 2
    color: timeColor

    function update() {
        if (root.mode === TimeAndBeatloopIndicator.Mode.RemainingTime) {
            var seconds = ((1.0 - progression.value) * duration.value);
            var mins = parseInt(seconds / 60).toString();
            seconds = parseInt(seconds % 60).toString();

            indicator.text = `-${mins.padStart(2, '0')}:${seconds.padStart(2, '0')}`;
        } else {
            indicator.text = (beatjump.value < 1 ? `1/${1 / beatjump.value}` : `${beatjump.value}`);
        }
    }

    Text {
        id: indicator
        anchors.centerIn: parent
        text: "0.00"

        font.pixelSize: 46
        color: fontColor

        Mixxx.ControlProxy {
            id: progression
            group: root.group
            key: "playposition"
        }

        Mixxx.ControlProxy {
            id: duration
            group: root.group
            key: "duration"
        }

        Mixxx.ControlProxy {
            id: beatjump
            group: root.group
            key: "beatjump_size"
        }

        Mixxx.ControlProxy {
            id: endoftrack
            group: root.group
            key: "end_of_track"
            onValueChanged: (value) => {
                root.border.color = 'red'
                root.color = 'red'
            }
        }
    }

    Component.onCompleted: {
        progression.onValueChanged.connect(update)
        duration.onValueChanged.connect(update)
        beatjump.onValueChanged.connect(update)
        update()
    }

    states: State {
        name: "compacted"

        PropertyChanges {
            target: indicator
            font.pixelSize: 17
        }
    }

    onModeChanged: () => {
        border.color = root.mode == TimeAndBeatloopIndicator.Mode.BeetjumpSize ? beatjumpColor : timeColor
        color = root.mode == TimeAndBeatloopIndicator.Mode.BeetjumpSize ? beatjumpColor : timeColor
        indicator.color = root.mode == TimeAndBeatloopIndicator.Mode.BeetjumpSize ? 'black' : 'white'
    }
}
