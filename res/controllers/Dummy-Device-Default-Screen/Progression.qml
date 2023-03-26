import QtQuick 2.15
import QtQuick.Window 2.15

import Mixxx 1.0 as Mixxx
import Mixxx.Controls 1.0 as MixxxControls

Item {
    id: root

    required property string group

    property real windowWidth: Window.width

    width: 0

    Mixxx.ControlProxy {
        group: root.group
        key: "playposition"
        onValueChanged: (value) => {
            root.width = value * (320 - 12);
        }
    }

    clip: true

    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: -border.width
        anchors.topMargin: -border.width
        anchors.bottomMargin: -border.width
        border.width: 2
        border.color:"black"
        color: Qt.rgba(0.39, 0.80, 0.96, 0.3)
    }
}
