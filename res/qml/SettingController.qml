import "." as Skin
import Mixxx 1.0 as Mixxx
import QtQuick 2.12
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects
import "Theme"

import "./components/" as Components

FocusScope {
    Rectangle {
        id: root
        anchors.fill: parent
        color: '#0E0E0E'
        radius: 5

        ColumnLayout {
            anchors.fill: parent
            RowLayout {
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.margins: 15
                    text: "Reloop Terminal Mix 2"
                    color: '#D9d9d9'
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                }
            }

            RowLayout {
                Layout.margins: 15
                Text {
                    Layout.fillWidth: true
                    text: "Mapping name"
                    color: "#D9D9D9"
                    font.pixelSize: 14
                }
                RatioChoice {
                    options: [
                              "soundcard",
                              "network"
                    ]
                }
                Item {
                    Layout.preferredWidth: 70
                }
                Text {
                    Layout.fillWidth: true
                    text: "Author"
                    color: "#D9D9D9"
                    font.pixelSize: 14
                }
                RatioChoice {
                    options: [
                              "44100 hz",
                              "48000 hz",
                              "96000 hz"
                    ]
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                Layout.margins: 6
                color: '#626262'
            }

            Rectangle {
                id: designer
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 8

                clip: true

                color: '#292929'

                property var defaultComponents: {}

                // component rect: Rectangle {
                //     width: 20; height: 20
                //     color: "red"

                //     Drag.active: dragArea.drag.active
                //     Drag.hotSpot.x: 10
                //     Drag.hotSpot.y: 10

                //     MouseArea {
                //         id: dragArea
                //         anchors.fill: parent

                //         drag.target: parent
                //     }
                // }
                property var copiedItem: null
                property var selectedItem: null

                Component.onCompleted: () => {
                    let obj = new Object();
                    obj[Mixxx.ControllerElement.Type.Button] = Qt.createComponent("components/Button.qml");
                    obj[Mixxx.ControllerElement.Type.Knob] = Qt.createComponent("components/Knob.qml");
                    obj[Mixxx.ControllerElement.Type.Encoder] = Qt.createComponent("components/Encoder.qml");
                    obj[Mixxx.ControllerElement.Type.Fader] = Qt.createComponent("components/Fader.qml");
                    obj[Mixxx.ControllerElement.Type.Zone] = Qt.createComponent("components/Zone.qml");

                    let comp = new Object();

                    for (let [type, value] of Object.entries(obj)) {
                        if (value.status === Component.Ready) {
                            comp[type] = value
                        } else {
                            console.warn(value.errorString())
                        }
                    }

                    designer.defaultComponents = comp
                    console.log(`created ${designer.defaultComponents}`)
                    controller.load()
                }
                Rectangle {
                    id: toolbox
                    visible: !lock.checked
                    anchors {
                        right: parent.right
                        rightMargin: 5
                        bottom: lock.top
                        bottomMargin: 15
                    }
                    width: 28
                    height: toolboxContent.implicitHeight + 10
                    color: '#3F3F3F'
                    radius: 4
                    ColumnLayout {
                        anchors.centerIn: parent
                        id: toolboxContent
                        Repeater {
                            model: Object.keys(designer.defaultComponents)

                            Item {
                                id: holder
                                required property string modelData

                                Component.onCompleted: () => {
                                    let props = {attached: {v: holder.verticalCenter, h: holder.horizontalCenter}};
                                    if (Mixxx.ControllerElement.Type.Zone == modelData) {
                                        props = Object.assign({components: designer.defaultComponents, width: 20, height: 20}, props)
                                    }
                                    console.log(`creating ${modelData} ${props} ${designer.defaultComponents}`)
                                    let comp = designer.defaultComponents[modelData].createObject(holder, props);
                                    if (comp) {
                                        height = comp.height
                                        width = comp.width
                                    }
                                }
                            }
                        }
                    }
                }
                focus: true
                Keys.onPressed: (e) => {
                    if ((e.key == Qt.Key_C) && (e.modifiers & Qt.ControlModifier) && designer.selectedItem) {
                        copiedItem = designer.selectedItem
                        console.log(`copy ${designer.selectedItem}`)
                    } else if ((e.key == Qt.Key_V) && (e.modifiers & Qt.ControlModifier) && designer.copiedItem) {
                        copiedItem = designer.defaultComponents[copiedItem.type].createObject(controller, designer.copiedItem.duplicateProperty())
                        copiedItem.focus = true
                        console.log(`paste ${designer.copiedItem}`)
                    } else {
                        console.log(`Pressed: ${e.key} (${designer.selectedItem}))`)
                    }
                }
                ColumnLayout {
                    anchors.fill: parent
                    Item {
                        id: canvas

                        function onItemSelected(item) {
                            console.log(item)
                            if (item instanceof Components.Base || item == null) {
                                console.log(`selected ${item}`)
                                designer.selectedItem = item
                            } else if (item == null && designer.selectedItem != null) {
                                designer.selectedItem.focus = false
                                designer.selectedItem = null
                            }
                        }

                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        Rectangle {
                            id: itemOverlay
                            visible: !!designer.selectedItem
                            anchors.fill: parent
                            color: 'transparent'
                            z: 200

                            MouseArea {
                                anchors.fill: parent
                                onPressed: {
                                    designer.selectedItem = null
                                }
                            }

                            Repeater {
                                model: designer.selectedItem ? 1 : 0
                                Item {
                                    id: option
                                    x: designer.selectedItem ? designer.selectedItem.mapToItem(option, designer.selectedItem.width / 2, 0).x - 110 : 0
                                    y: designer.selectedItem ? designer.selectedItem.mapToItem(option, 0, designer.selectedItem.height).y : 0
                                    width: 220
                                    height: propertyArea.height + 30
                                    Item {
                                        id: content
                                        visible: false
                                        anchors.fill: parent
                                        height: propertyArea.height+30
                                        Shape {
                                            id: arrow
                                            width: 16
                                            height: 15
                                            anchors.top: parent.top
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            ShapePath {
                                                strokeColor: "transparent"
                                                fillColor: "#242424"
                                                startX: 8; startY: 0
                                                PathLine { x: 16; y: 15 }
                                                PathLine { x: 0; y: 15 }
                                                PathLine { x: 8; y: 0 }
                                            }
                                        }
                                        Rectangle {
                                            id: propertyFrame
                                            color: '#242424'
                                            radius: 8
                                            anchors {
                                                // bottom: parent.bottom
                                                top: arrow.bottom
                                                left: parent.left
                                                right: parent.right
                                            }
                                            height: propertyArea.height
                                        }
                                    }
                                    DropShadow {
                                        id: effect
                                        anchors.fill: parent
                                        source: content
                                        horizontalOffset: 0
                                        verticalOffset: 0
                                        radius: 8.0
                                        color: "#b0000000"
                                    }
                                    Rectangle {
                                        id: propertyArea
                                        color: "transparent"
                                        anchors {
                                            top: parent.top
                                            topMargin: 20
                                            leftMargin: 4
                                            left: content.left
                                            right: parent.right
                                        }
                                        // height: lockedColumn.item ? lockedColumn.item.implicitHeight:0 + unlockedColumn.item ? unlockedColumn.item.implicitHeight:0

                                        Repeater {
                                            id: lockedColumn
                                            model: designer.selectedItem.locked ? 1 : 0
                                            width: propertyArea.width
                                            ColumnLayout {
                                                Component.onCompleted: {
                                                    propertyArea.height = implicitHeight + 12
                                                }
                                                width: propertyArea.width - 8
                                                RowLayout {
                                                    Text {
                                                        Layout.fillWidth: true
                                                        text: "Name"
                                                        color: "#D9D9D9"
                                                        font.pixelSize: 14
                                                    }
                                                    Text {
                                                        text: "Left deck"
                                                        font.pixelSize: 10
                                                        color: "#8A8A8A"
                                                    }
                                                    Text {
                                                        text: "Hotcue 6"
                                                        font.pixelSize: 11
                                                        color: "#D9D9D9"
                                                    }
                                                }
                                                RowLayout {
                                                    Text {
                                                        Layout.fillWidth: true
                                                        text: "Type"
                                                        color: "#D9D9D9"
                                                        font.pixelSize: 14
                                                    }
                                                    Skin.ComboBox {
                                                        Layout.fillWidth: true
                                                        model: [
                                                                "Push button",
                                                                "Toggle",
                                                        ]
                                                    }
                                                }
                                                RowLayout {
                                                    Text {
                                                        text: "Action"
                                                        color: "#D9D9D9"
                                                        font.pixelSize: 14
                                                    }
                                                    Skin.ComboBox {
                                                        Layout.fillWidth: true
                                                        implicitWidth: 130
                                                        indicator.width: 20
                                                        spacing: 0
                                                        model: [
                                                                "Deck 1: Activate hotcue"
                                                        ]
                                                    }
                                                }
                                                RowLayout {
                                                    Item {
                                                        Layout.fillWidth: true
                                                    }
                                                    Skin.Button {
                                                        text: "Learn"
                                                        activeColor: "#7D3B3B"
                                                    }
                                                }
                                            }
                                        }

                                        Repeater {
                                            model: designer.selectedItem.locked ? 0 : 1
                                            id: unlockedColumn
                                            ColumnLayout {
                                                Layout.margins: 4
                                                Component.onCompleted: {
                                                    propertyArea.height = implicitHeight
                                                }
                                                RowLayout {
                                                    Text {
                                                        Layout.fillWidth: true
                                                        text: "Label"
                                                        color: "#D9D9D9"
                                                        font.pixelSize: 14
                                                    }
                                                    TextInput {
                                                        text: designer.selectedItem.label
                                                        width: 40
                                                        color: "#626262"
                                                    }
                                                }
                                                RowLayout {
                                                    Text {
                                                        Layout.fillWidth: true
                                                        text: "Width"
                                                        color: "#D9D9D9"
                                                        font.pixelSize: 14
                                                    }
                                                    SpinBox {
                                                        editable: true
                                                        stepSize: 1
                                                        to: 2000
                                                        textFromValue: function(value, locale) {
                                                            return `${value} mm`
                                                        }

                                                        valueFromText: function(text, locale) {
                                                            return text.split(' ')[0]
                                                        }
                                                        value: designer.selectedItem.widthInMm
                                                        onValueModified: {
                                                            designer.selectedItem.width = value / designer.selectedItem.mmPerPixel
                                                        }
                                                    }
                                                }
                                                RowLayout {
                                                    Text {
                                                        Layout.fillWidth: true
                                                        text: "Height"
                                                        color: "#D9D9D9"
                                                        font.pixelSize: 14
                                                    }
                                                    SpinBox {
                                                        editable: true
                                                        stepSize: 1
                                                        to: 2000
                                                        textFromValue: function(value, locale) {
                                                            return `${value} mm`
                                                        }

                                                        valueFromText: function(text, locale) {
                                                            return text.split(' ')[0]
                                                        }
                                                        value: designer.selectedItem.heightInMm
                                                        onValueModified: {
                                                            designer.selectedItem.height = value / designer.selectedItem.mmPerPixel
                                                        }
                                                    }
                                                }
                                                Repeater {
                                                    model: designer.selectedItem.hasOwnProperty("grid") ? 1 : 0
                                                    RowLayout {
                                                        Text {
                                                            Layout.fillWidth: true
                                                            text: "Grid"
                                                            color: "#D9D9D9"
                                                            font.pixelSize: 14
                                                        }
                                                        SpinBox {
                                                            editable: true
                                                            stepSize: 1
                                                            to: 2000
                                                            textFromValue: function(value, locale) {
                                                                return `${value} mm`
                                                            }

                                                            valueFromText: function(text, locale) {
                                                                return text.split(' ')[0]
                                                            }
                                                            value: designer.selectedItem.grid * designer.selectedItem.mmPerPixel
                                                            onValueModified: {
                                                                designer.selectedItem.grid = value / designer.selectedItem.mmPerPixel
                                                            }
                                                        }
                                                    }
                                                }
                                                RowLayout {
                                                    Text {
                                                        Layout.fillWidth: true
                                                        text: "Align on grid"
                                                        color: "#D9D9D9"
                                                        font.pixelSize: 14
                                                    }
                                                    RatioChoice {
                                                        options: [
                                                                  "on",
                                                                  "off"
                                                        ]
                                                        selected: options[designer.selectedItem.lockedOnGrid ? 0 : 1]
                                                        onSelectedChanged: {
                                                            designer.selectedItem.lockedOnGrid = selected == "on"
                                                        }
                                                    }
                                                }
                                                Repeater {
                                                    model: designer.selectedItem.hasOwnProperty("round") ? 1 : 0
                                                    RowLayout {
                                                        Text {
                                                            Layout.fillWidth: true
                                                            text: "Round"
                                                            color: "#D9D9D9"
                                                            font.pixelSize: 14
                                                        }
                                                        RatioChoice {
                                                            options: [
                                                                      "on",
                                                                      "off"
                                                            ]
                                                            selected: options[designer.selectedItem.round ? 0 : 1]
                                                            onSelectedChanged: {
                                                                designer.selectedItem.round = selected == "on"
                                                            }
                                                        }
                                                    }
                                                }
                                                Repeater {
                                                    model: designer.selectedItem.hasOwnProperty("vertical") ? 1 : 0
                                                    RowLayout {
                                                        Text {
                                                            Layout.fillWidth: true
                                                            text: "Orientation"
                                                            color: "#D9D9D9"
                                                            font.pixelSize: 14
                                                        }
                                                        RatioChoice {
                                                            options: [
                                                                      "horizontal",
                                                                      "vertical"
                                                            ]
                                                            selected: options[designer.selectedItem.vertical ? 0 : 1]
                                                            onSelectedChanged: {
                                                                designer.selectedItem.vertical = selected == "on"
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            Components.Controller {
                                id: controller
                                x: (parent.width - width) / 2
                                y: (parent.height - height) / 2
                                width: 440
                                height: 320
                                locked: lock.checked

                                onSelected: (item) => canvas.onItemSelected(item)

                                Image {
                                    id: controllerVisual
                                    width: parent.width
                                    height: parent.height
                                    fillMode: Image.PreserveAspectCrop
                                    source: 'images/controller_mapping.png'
                                }

                                Rectangle {
                                    id: overlay
                                    anchors.fill: parent
                                    // height: controllerVisual.height
                                    // width: controllerVisual.width
                                    color: '#b8aaaaaa'
                                    border.color: '#0E0E0E'
                                    border.width: 1
                                }

                                property real zoomFactor: 1.6
                                property point offset: Qt.point(controller.width/2, controller.height/2)

                                anchors.centerIn: parent
                                transform: Scale {
                                    origin {
                                        x: controller.offset.x
                                        y: controller.offset.y
                                        z: 0
                                    }
                                    xScale: controller.zoomFactor;
                                    yScale: controller.zoomFactor
                                }

                                components: designer.defaultComponents
                            }
                            // propagateComposedEvents: true
                            onWheel: (e) => {
                                canvas.onItemSelected(null)
                                if (e.angleDelta.y < 0) {
                                    if (e.modifiers & Qt.ControlModifier) {
                                        controller.zoomFactor -= 0.1
                                    } else if (e.modifiers & Qt.ShiftModifier) {
                                        controller.offset.x -= 20 / controller.zoomFactor
                                    } else {
                                        controller.offset.y -= 20 / controller.zoomFactor
                                    }
                                } else {
                                    if (e.modifiers & Qt.ControlModifier) {
                                        controller.zoomFactor += 0.1
                                    } else if (e.modifiers & Qt.ShiftModifier) {
                                        controller.offset.x += 20 / controller.zoomFactor
                                    } else {
                                        controller.offset.y += 20 / controller.zoomFactor
                                    }
                                }
                                console.log(`wheel: ${e.angleDelta} ${Object.keys(controller.transform)} ${controller.zoomFactor} ${controller.offset} ${e.modifiers}`)
                            }
                        }
                    }
                }
                Skin.Button {
                    id: lock

                    anchors {
                        bottom: parent.bottom
                        right: parent.right
                        bottomMargin: 5
                        rightMargin: 5
                    }

                    implicitWidth: implicitHeight

                    contentItem: Item {
                        Shape {
                            antialiasing: true
                            layer.enabled: true
                            layer.samples: 4
                            anchors.centerIn: parent
                            width: 13
                            height: 15
                            ShapePath {
                                strokeColor: '#D9D9D9'
                                fillColor: 'transparent'
                                startX: 2; startY: 7.5
                                // PathSvg { path: "M2.01074 8.06097C2.01074 -1.35374 11.0594 -1.35378 11.0594 8.0614" }
                                PathQuad {
                                    x: 6.5; y: 0
                                    controlX: 0; controlY: 0
                                }
                                PathQuad {
                                    x: 11; y: 7.5
                                    controlX: 15; controlY: 0
                                }
                            }
                            Rectangle {
                                color: '#D9D9D9'
                                anchors.bottom: parent.bottom
                                width: 13
                                height: 8
                            }
                        }
                        // Rectangle {
                        //     color: 'red'
                        //     anchors.centerIn: parent
                        //     width: 10
                        //     height: 10
                        // }
                    }

                    activeColor: Theme.white
                    checkable: true
                    // checked: true
                    onClicked: {
                        console.log("foo")
                        // Mixxx.PreferencesDialog.show();
                    }
                }
            }
        }

        function selectTab(tab) {
            console.log(tab)
        }
    }
}
