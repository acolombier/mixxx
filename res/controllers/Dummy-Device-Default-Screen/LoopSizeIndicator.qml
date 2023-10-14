import QtQuick 2.14
import QtQuick.Controls 2.15

import Mixxx 1.0 as Mixxx
import Mixxx.Controls 1.0 as MixxxControls

Rectangle {
    id: root

    required property string group

    property color loopOffBoxColor: Qt.rgba(67/255,70/255,66/255, 1)
    property color loopOffFontColor: "white"
    property color loopOnBoxColor: Qt.rgba(125/255,246/255,64/255, 1)
    property color loopOnFontColor: "black"

    property bool on: true

    radius: 6
    border.width: 2
    border.color: (loopSizeIndicator.on ? loopOnBoxColor : loopOffBoxColor)
    color: (loopSizeIndicator.on ? loopOnBoxColor : loopOffBoxColor)

    Text {
        id: indicator
        anchors.centerIn: parent
        font.pixelSize: 46
        color: (loopSizeIndicator.on ? loopOnFontColor : loopOffFontColor)

        Mixxx.ControlProxy {
            group: root.group
            key: "beatloop_size"
            onValueChanged: (value) => {
                indicator.text = (value < 1 ? `1/${1 / value}` : `${value}`);
            }
        }
    }

    Mixxx.ControlProxy {
        group: root.group
        key: "loop_enabled"
        onValueChanged: (value) => {
            root.on = value;
        }
    }

    states: State {
        name: "compacted"

        PropertyChanges {
            target: indicator
            font.pixelSize: 17
        }
    }
}
