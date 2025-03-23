import QtQuick
import "."
import Mixxx 1.0 as Mixxx

Base {
    id: root
    type: Mixxx.ControllerElement.Type.Fader

    property bool horizontal: false

    resizeable: true
    transform: Rotation { origin.x: width/2; origin.y: height/2; angle: root.properties.Vertical ? 90 : 0}

    property real value: 0.5

    width: 20
    height: root.attached ? 20 : 40

    // onModifiersChanged: {
    //     if (root.modifiers.length && root.modifiers[0].valueCount > 4) {
    //         root.value = Qt.binding(function(){ return root.values[0] / root.modifiers[0].valueCount; })
    //     }
    // }

    Rectangle {
        anchors {
            centerIn: parent
        }

        width: 1
        height: parent.height

        color: "#000000"
        radius: 2

        Rectangle {
            anchors {
                bottom: parent.bottom
                bottomMargin: (parent.height - height) * root.value
                horizontalCenter: parent.horizontalCenter
            }
            width: 20
            height: 5
            radius: 5
            color: "#CCCCCC"

            border {
                width: 1
                color: "#000000"
            }
        }
    }
}
