import QtQuick 2.14
import QtQuick.Controls 2.15

import Mixxx 1.0 as Mixxx
import Mixxx.Controls 1.0 as MixxxControls

Rectangle {
    id: root

    required property string group
    required property color borderColor

    property real value: 0

    color: "transparent"
    radius: 6
    border.color: smallBoxBorder
    border.width: 2

    Text {
        id: inidcator
        text: value.toFixed(2)
        font.pixelSize: 17
        color: fontColor
        anchors.centerIn: parent

        Mixxx.ControlProxy {
            group: root.group
            key: "bpm"
            onValueChanged: (value) => {
                inidcator.text = value.toFixed(2);
            }
        }
    }

    Text {
        id: range
        font.pixelSize: 9
        color: fontColor
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.rightMargin: 5

        Mixxx.ControlProxy {
            group: root.group
            key: "rateRange"
            onValueChanged: (value) => {
                range.text = `-/+ \n${(value * 100).toFixed()}%`;
            }
        }
    }

    states: State {
        name: "compacted"

        PropertyChanges {
            target: range
            visible: false
        }
    }
}
