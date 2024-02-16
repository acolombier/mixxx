import "." as Skin
import Mixxx 1.0 as Mixxx
import Qt.labs.qmlmodels
import QtQml
import QtQuick
import QtQml.Models
import QtQuick.Layouts
import QtQuick.Controls 2.15
import QtQuick.Shapes 1.6
import "Theme"

Skin.LibraryPanel {
    Rectangle {
        id: treeView

        anchors.fill: parent

        color: 'transparent'

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            drag {
                target: parent
            }
        }
        Shape {
            anchors.fill: parent
            ShapePath {
                strokeColor: "#40ffffff"
                strokeWidth: 1
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap

                startX: 0
                startY: 0
                PathLine { x: width; y: 0 }
                PathLine { x: width; y: height }
                PathLine { x: 0; y: height }
                PathLine { x: 0; y: 0 }
                PathLine { x: width; y: height }
                PathLine { x: 0; y: height }
                PathLine { x: width; y: 0 }
            }
        }

        Text {
            anchors.centerIn: parent
            color: 'white'
            text: "PreviewDeck placeholder"
        }

        Drag.active: mouseArea.drag.active
        Drag.source: parent
        Drag.dragType: Drag.Automatic
        Drag.supportedActions: Qt.MoveAction
        Drag.hotSpot.x: mouseArea.mouseX
        Drag.hotSpot.y: mouseArea.mouseY
    }
}
