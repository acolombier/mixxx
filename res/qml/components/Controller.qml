import QtQuick 2
import "."
import Mixxx 1.0 as Mixxx

Zone {
    id: root
    type: Mixxx.ControllerElement.Type.Controller
    resizeable: false
    drageable: false

    width: root.widthInMm / scale
    height: root.weightInMm / scale
    Rectangle {
        anchors.fill: parent
        border {
            width: 2
            color: "steelblue"
        }
        color: "grey"
    }

    function load() {
        let seed = root.seed()
        if (!seed) {
            return;
        }

        if (seed.width) {
            controller.width = seed.width
        }
        if (seed.height) {
            controller.height = seed.height
        }

        if (seed.children) {
            for (let child of seed.children) {
                let childChildren = child.children;
                if (child.type == Mixxx.ControllerElement.Type.Zone) {
                    child.components = root.components
                    delete child.children
                }
                let e = root.components[child.type].createObject(controller, child);
                e.selected.connect((item) => {
                        root.selected(item)
                })
                e.duplicated.connect(() => {
                        root.components[e.type].createObject(controller, e.duplicateProperty())
                })
                if (childChildren) {
                    e.load(childChildren)
                }
            }
        }
    }
}
