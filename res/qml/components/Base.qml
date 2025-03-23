import QtQuick
import Mixxx 1.0 as Mixxx

Mixxx.ControllerElement {
    id: root

    property var attached: null
    property bool resizeable: false
    property bool drageable: true
    property int rulersSize: 15
    property real mmPerPixel: 0.5

    property string label: ""
    property bool lockedOnGrid: true
    property bool locked: false

    onLockedChanged: {
        for (let child of children) {
            child.locked = locked
        }
    }

    property real widthInMm: Math.round(width*mmPerPixel)
    property real heightInMm: Math.round(height*mmPerPixel)

    signal selected(var item)
    signal duplicated()

    readonly property bool resizing: bottomHandle.drag.active || topHandle.drag.active || leftHandle.drag.active || rightHandle.drag.active

    anchors {
        verticalCenter: attached ? attached.v : undefined
        horizontalCenter: attached ? attached.h : undefined
    }

    // onWidthChanged:{
    //     root.properties = Object.assign({
    //         "Width": `${Math.round(width*mmPerPixel)} mm`
    //     }, root.properties)
    // }

    component Handle: Rectangle {
        id: delegate
        visible: targetElement.resizeable && !targetElement.locked && !targetElement.attached && targetElement.focus
        width: rulersSize
        height: rulersSize
        radius: rulersSize
        z: 100
        // anchors.horizontalCenter: parent.right
        // anchors.verticalCenter: parent.verticalCenter

        required property var resizerCallback
        required property var targetElement
        property var cursor: Qt.SizeHorCursor
        property var axis: Drag.XAxis
        property alias drag: resizer.drag

        MouseArea {
            property var origin: null
            id: resizer
            anchors.fill: parent
            drag {
                threshold: 1
                target: parent
                axis: delegate.axis
            }
            cursorShape: delegate.cursor
            hoverEnabled: true
            onPressedChanged: {
                console.log("pressed", pressed)
                origin = pressed ? Qt.point(mouseX, mouseY) : null
            }
            onPositionChanged: {
                if (pressed) {
                    let tl = root.mapToGlobal(0, 0)
                    let br = root.mapToGlobal(root.width, root.height)
                    let ratio = (br.x - tl.x) / root.width
                    resizerCallback(Qt.point(mouseX - origin.x, mouseY - origin.y))
                }
            }
        }

        border {
            width: resizer.containsMouse ? 1 : 0
            color: "black"
        }
        color: resizer.pressed ? "red" : "steelblue"
    }

    Drag.dragType: Drag.Automatic
    Drag.supportedActions: attached ? Qt.CopyAction : Qt.MoveAction

    Drag.mimeData: {
        "demo/type": root.type
    }

    DragHandler {
        id: dragHandler
        enabled: !root.locked
        onActiveChanged: {
            if (!parent.drageable || parent.locked) {
                return
            } else if (active) {
                parent.focus = false
                let tl = parent.mapToGlobal(0, 0)
                let br = parent.mapToGlobal(parent.width, parent.height)
                let ratio = (br.x - tl.x) / parent.width
                parent.Drag.hotSpot.x =  mouseArea.mouseX * ratio
                parent.Drag.hotSpot.y =  mouseArea.mouseY * ratio
                parent.grabToImage(function(result) {
                        parent.Drag.imageSource = result.url
                        parent.Drag.active = true
                    }, Qt.size(parent.width * ratio, parent.height * ratio))
                console.log("attached", root.attached)
                if (!root.attached) {
                    root.visible = false
                }
            } else {
                // parent.Drag.active = false
                // root.visible = true
                parent.focus = true
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        acceptedButtons: Qt.LeftButton | Qt.RightButton
        preventStealing: false

        drag {
            filterChildren: true
            threshold: 1
        }

        onDoubleClicked: {
            if (!root.locked) {
                root.duplicated()
            }
        }

        onClicked: (mouse)=> {
            console.log("locked", root.locked)
            if (mouse.button == Qt.RightButton && root.drageable && !root.locked) {
                parent.destroy()        // destroy component
                return
            } else if (root.focus || root.locked) {
                root.selected(root)
            } else if (!root.attached) {
                root.focus = true
                root.z = 50
            }
            mouse.accepted = false
        }
        Rectangle {
            anchors.fill: parent
            color: 'transparent'

            border {
                width: !root.attached && root.focus && !root.locked ? root.resizeable ? 2 : 1 : 0
                color: "steelblue"
            }
        }
    }

    Handle {
        id: leftHandle

        anchors.horizontalCenter: parent.left
        anchors.verticalCenter: parent.verticalCenter
        targetElement: root
        resizerCallback: (p) => {
            console.log("RESIZE", p)
            root.width -= p.x
            root.x += p.x
        }
    }

    Handle {
        id: rightHandle

        anchors.horizontalCenter: parent.right
        anchors.verticalCenter: parent.verticalCenter
        targetElement: root
        resizerCallback: (p) => {
            root.width += p.x
        }
    }

    Handle {
        id: topHandle

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.top
        anchors.verticalCenterOffset: 5

        axis: Drag.YAxis
        cursor: Qt.SizeVerCursor

        targetElement: root
        resizerCallback: (p) => {
            root.height -= p.y
            root.y += p.y
        }
    }

    Handle {
        id: bottomHandle
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.bottom

        axis: Drag.YAxis
        cursor: Qt.SizeVerCursor

        targetElement: root
        resizerCallback: (p) => {
            root.height += p.y
        }
    }

    // states: [
    //     State {
    //         when: root.Drag.active && attached != undefined
    //         AnchorChanges {
    //             target: root
    //             anchors {
    //                 verticalCenter: undefined
    //                 horizontalCenter: undefined
    //             }
    //         }
    //     },
    //     State {
    //         when: !root.Drag.active && attached == undefined
    //         PropertyChanges {
    //             target: root
    //             x: { Math.round(root.x / 10) * 10 }
    //             y: { Math.round(root.y / 10) * 10 }
    //         }
    //     }
    // ]

    function duplicateProperty(props) {
        if (props === undefined) props = {}
        return Object.assign({
                x: root.x + 10,
                y: root.y + 10,
            // properties: Object.assign(properties, {}),
                width: width,
                height: height,
            }, props);
    }
}
