import QtQuick
import "."
import Mixxx 1.0 as Mixxx

Base {
    id: root
    type: Mixxx.ControllerElement.Type.Encoder

    property real value: 0
    property bool pressed: false
    property bool touched: false

    width: 20
    height: 20

    transform: Rotation { origin.x: root.width/2; origin.y: root.height/2; angle: root.value * 360}

    onValueChanged: {
        console.log(root.value)
    }

    // onModifiersChanged: {
    //     if (!root.modifiers.length){
    //         return;
    //     }
    //     let maxValue = root.modifiers.reduce(
    //         (accumulator, currentValue) => Math.max(accumulator, currentValue.valueCount),
    //         0,
    //     );

    //     let valueIdx = -1;
    //     if (maxValue > 3) {
    //         for (let i = 0; i < root.modifiers.length; i++){
    //             if (root.modifiers[i].valueCount != maxValue) continue;
    //             root.value = Qt.binding(function(){ return root.values[i] / root.modifiers[i].valueCount;})
    //             valueIdx = i;
    //             break
    //         }
    //     }
    //     let attachedPressed = false;
    //     let attachedTouched = false;
    //     if (root.modifiers.length > 1 || valueIdx == -1){
    //         for (let i = 0; i < root.modifiers.length && (!attachedTouched || !attachedPressed); i++){
    //             if (i == valueIdx) continue;

    //             if (!attachedPressed){
    //                 root.pressed = Qt.binding(function(){ return root.values[i] & 0x1;})
    //                 attachedPressed = true
    //                 if (root.modifiers[i].valueCount > 2 && !attachedTouched){
    //                     root.touched = Qt.binding(function(){ return root.values[i] & 0x2;})
    //                     attachedTouched = true
    //                 }
    //             } else {
    //                 root.touched = Qt.binding(function(){ return root.values[i];})
    //                 attachedTouched = true
    //             }
    //         }
    //     }

    //     // for (let modifier in modifiers) {
    //     // if (root.modifiers.length && root.modifiers[0].valueCount > 4) {
    //     //     root.value = Qt.binding(function(){ return root.values[0] / root.modifiers[0].valueCount;})
    //     // }
    // }

    Rectangle {
        anchors.fill: parent
        radius: parent.width
        color: root.pressed ? "red" : "#CCCCCC"

        border {
            width: 1
            color: root.touched ? "green" : "black"
        }

        Rectangle {
            anchors {
                topMargin: parent.height / 4
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }
            width: 2
            height: 10
            radius: 2
            color: "black"
        }
    }
}
