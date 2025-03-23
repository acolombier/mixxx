import QtQuick
import "."
import Mixxx 1.0 as Mixxx

Base {
    id: root
    type: Mixxx.ControllerElement.Type.Knob
    property real value: 0.5

    width: 20
    height: 20

    transform: Rotation { origin.x: root.width/2; origin.y: root.height/2; angle: root.value * 270 - 135}

    // onModifiersChanged: {
    //     if (root.modifiers.length && root.modifiers[0].valueCount > 4) {
    //         root.value = Qt.binding(function(){ return root.values[0] / root.modifiers[0].valueCount;})
    //     }
    // }

    Rectangle {
        anchors.fill: parent
        radius: parent.width
        color: "#CCCCCC"

        border {
            width: 1
            color: "#000000"
        }

        Rectangle {
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }
            width: 1
            height: 10
            radius: 2
            color: "#000000"
        }
    }
}
