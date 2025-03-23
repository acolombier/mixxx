import QtQuick
import "."
import Mixxx 1.0 as Mixxx

Base {
    id: root
    type: Mixxx.ControllerElement.Type.Button
    width: 20
    height: 20

    property bool round: false

    property bool pressed: false

    // onModifiersChanged: {
    //     if (root.modifiers.length && root.modifiers[0].valueCount) {
    //         root.pressed = Qt.binding(function(){ return root.values[0]})
    //     }
    // }

    Rectangle {
        anchors.fill: parent

        radius: root.round ? width : 4

        color: root.pressed ? "red" : "#CCCCCC"

        border {
            width: 1
            color: "black"
        }
    }
}
