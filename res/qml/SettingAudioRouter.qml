import "." as Skin
import Mixxx 1.0 as Mixxx
import QtQuick 2.12
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects
import "Theme"

Rectangle {
    id: root
    color: '#0E0E0E'
    radius: 5

    property var connections: new Set()
    property var selectedTab: ""
    property var newConnection: null

    MouseArea {
        enabled: root.newConnection != null
        anchors.fill: parent
        hoverEnabled: true
        onPositionChanged: (mouse) => {
            if (root.newConnection) {
                root.newConnection.target = Qt.point(mouse.x, mouse.y)
            }
        }
        onExited: {
            if (root.newConnection) {
                root.newConnection.destroy();
                root.newConnection = null
            }
        }
        onPressed: {
            if (root.newConnection) {
                root.newConnection.destroy();
                root.newConnection = null
            }
        }
    }

    function entityOnConnect(edge) {
        if (root.newConnection!= null) {
            if (edge.type == root.newConnection.source.type || edge.group == root.newConnection.source.group || edge.entity == root.newConnection.source.entity) {
                root.newConnection.state = "impossible"
                return;
            }
            if (root.newConnection.source == edge) {
                root.newConnection.destroy();
            } else {
                root.newConnection.sink = edge
                root.connections.add(root.newConnection)
            }
            root.newConnection = null
        } else {
            root.newConnection = connectionEdge.createObject(root, {"router": root, "source": edge});
        }
    }

    function entityOnDisconnect(edge) {
        if (edge.connection == null) {
            return
        }
        var sink = edge.connection.sink;
        var source = edge.connection.source;
        root.connections.delete(edge.connection)
        edge.connection.destroy()

        if (source != null) {
            source.connection = null
        }

        if (sink != null) {
            sink.connection = null
        }
    }

    Component {
        id: connectionEdge
        Item {
            id: edge

            required property var source
            required property var router
            property var sink: null
            property var target: source.mapToItem(router, source.width/2, source.height/2)

            property bool system: false
            property bool vertical: false

            states: [
                State {
                    name: "system"
                    when: edge.system

                    PropertyChanges {
                        target: line
                        strokeColor: "#2B2B2B"
                    }
                },
                State {
                    name: "setting"
                    when: edge.sink == null

                    PropertyChanges {
                        target: line
                        strokeColor: "#696968"
                    }
                },
                State {
                    name: "set"
                    when: edge.sink != null

                    PropertyChanges {
                        target: line
                        strokeColor: "#3a60be"
                    }
                },
                State {
                    name: "impossible"

                    PropertyChanges {
                        target: line
                        strokeColor: "#7D3B3B"
                    }
                }
            ]

            x: source.mapToItem(router, source.width/2, source.height/2).x
            y: source.mapToItem(router, source.width/2, source.height/2).y
            width: Math.max(2, Math.abs(source.mapToItem(router, source.width/2, source.height/2).x - (target ?? sink.mapToItem(router, sink.width/2, sink.height/2)).x))
            height: Math.max(2, Math.abs(source.mapToItem(router, source.width/2, source.height/2).y - (target ?? sink.mapToItem(router, sink.width/2, sink.height/2)).y))

            onSinkChanged: {
                if (sink != null && source != null) {
                    target = null
                    sink.connection = edge
                    source.connection = edge
                }
            }
            onSourceChanged: {
                if (sink != null && source != null) {
                    target = null
                    sink.connection = edge
                    source.connection = edge
                }
            }
            onTargetChanged: {
                if (!system)
                    state = "setting"
                if (!source)
                    return
                scale.xScale = source.mapToItem(router, source.width/2, source.height/2).x > (edge.target ?? sink.mapToItem(router, sink.width/2, sink.height/2)).x ? -1 : 1
                scale.yScale = source.mapToItem(router, source.width/2, source.height/2).y > (edge.target ?? sink.mapToItem(router, sink.width/2, sink.height/2)).y ? -1 : 1
            }

            Shape {
                anchors.fill: parent
                // anchors.centerIn: parent
                antialiasing: true
                layer.enabled: true
                layer.samples: 4
                layer.textureMirroring: ShaderEffectSource.MirrorHorizontally
                ShapePath {
                    id: line
                    strokeColor: "#696968"
                    strokeWidth: 2
                    fillColor: "transparent"
                    capStyle: ShapePath.RoundCap
                    joinStyle: ShapePath.BevelJoin

                    startX: 0
                    startY: 0
                    PathQuad { x: edge.width * 0.5; y: edge.height * 0.5; controlX: edge.width * (edge.vertical ? 0 : 0.3); controlY : edge.height * (edge.vertical ? 0.3 : 0) }
                    PathQuad { x: edge.width; y: edge.height; controlX: edge.width * (edge.vertical ? 1 : 0.7); controlY : edge.height * (edge.vertical ? 0.7 : 1) }
                }
            }
            transform: Scale {
                id: scale
            }
            // FIXME binding
            // Connections {
            //     target: source
            //     function onXChanged(){
            //         edge.x = source.mapToItem(router, source.width/2, source.height/2).x
            //         edge.y = source.mapToItem(router, source.width/2, source.height/2).y
            //         edge.width = Math.max(2, Math.abs(source.mapToItem(router, source.width/2, source.height/2).x - (target ?? sink.mapToItem(router, sink.width/2, sink.height/2)).x))
            //         edge.height = Math.max(2, Math.abs(source.mapToItem(router, source.width/2, source.height/2).y - (target ?? sink.mapToItem(router, sink.width/2, sink.height/2)).y))

            //         scale.xScale = source.mapToItem(router, source.width/2, source.height/2).x > (edge.target ?? sink.mapToItem(router, sink.width/2, sink.height/2)).x ? -1 : 1
            //         scale.yScale = source.mapToItem(router, source.width/2, source.height/2).y > (edge.target ?? sink.mapToItem(router, sink.width/2, sink.height/2)).y ? -1 : 1

            //     }
            // }
        }
    }

    RowLayout {
        anchors.fill: parent

        ColumnLayout {
            Layout.fillHeight: true
            Layout.preferredWidth: 165
            Text {
                Layout.alignment: Qt.AlignHCenter
                Layout.margins: 15
                text: "Inputs"
                color: '#626262'
                font.pixelSize: 14
            }

            Item {
                Layout.fillHeight: true
            }

            AudioEntity {
                Layout.margins: 15

                name: "HAD Intel PCH"
                group: "input"
                gateways: [
                    QtObject {
                        property string label: "ALC289 Analog"
                        property string type: "source"
                    }
                ]

                onConnect: (point) => root.entityOnConnect(point)
                onDisconnect: (point) => root.entityOnDisconnect(point)
            }
            Item {
                Layout.fillHeight: true
            }
            AudioEntity {
                Layout.margins: 15

                name: "Targus USB3 DV4K DOCK w PD100W"
                group: "input"
                gateways: [
                    QtObject {
                        property string label: "USB Audio"
                        property string type: "source"
                    }
                ]

                onConnect: (point) => root.entityOnConnect(point)
                onDisconnect: (point) => root.entityOnDisconnect(point)
            }

            Item {
                Layout.fillHeight: true
            }
        }
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            width: 1
            color: '#626262'
        }
        ColumnLayout {
            RowLayout {
                Item {
                    Layout.fillWidth: true
                }
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ColumnLayout {
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            bottom: parent.bottom
                            rightMargin: 80
                            margins: 16
                        }
                        // Layout.fillWidth: true
                        // Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                        Repeater {
                            id: decks
                            model: 4
                            AudioEntity {
                                required property int index

                                Layout.margins: 7

                                name: `Deck ${index+1}`
                                group: "core"
                                gateways: [
                                    QtObject {
                                        property var label: "Output"
                                        property var type: "source"
                                    },
                                    QtObject {
                                        property var label: "Vinyl Control"
                                        property var type: "sink"
                                    }
                                ]

                                onConnect: (point) => root.entityOnConnect(point)
                                onDisconnect: (point) => root.entityOnDisconnect(point)
                            }
                        }
                    }
                }
                Item {
                    Layout.fillWidth: true
                }
                AudioEntity {
                    id: mixer

                    name: "Mixer"
                    group: "core"
                    gateways: [
                        QtObject {
                            property var label: "PFL"
                            property var type: "source"
                        },
                        QtObject {
                            property var label: "Main"
                            property var type: "source"
                        },
                        QtObject {
                            property var label: "Booth"
                            property var type: "source"
                        },
                        QtObject {
                            property var label: "Axillary"
                            property var type: "sink"
                        },
                        QtObject {
                            property var label: "Microphone"
                            property var type: "sink"
                        }
                    ]

                    handleSource.vertical: true

                    onConnect: (point) => root.entityOnConnect(point)
                    onDisconnect: (point) => root.entityOnDisconnect(point)
                }
                ColumnLayout {
                    Layout.leftMargin: 60
                    Item {
                        Layout.fillHeight: true
                    }
                    AudioEntity {
                        id: record

                        Layout.bottomMargin: 70

                        name: "Record/Broadcast"
                        group: "core"
                        metaType: "sink"

                        handleSink.vertical: true

                        onConnect: (point) => root.entityOnConnect(point)
                        onDisconnect: (point) => root.entityOnDisconnect(point)
                    }
                }
                Item {
                    Layout.fillWidth: true
                }
            }
            RowLayout {
                Layout.bottomMargin: 3
                RatioChoice {
                    normalizedWidth: false
                    options: [
                              "experimental",
                              "default",
                              "disabled"
                    ]
                }
                Text {
                    text: "Sound Clock"
                    color: "#D9D9D9"
                    font.pixelSize: 14
                }
                Item {
                    Layout.fillWidth: true
                }
                Text {
                    text: "Sound API"
                    color: "#D9D9D9"
                    font.pixelSize: 14
                }
                RatioChoice {
                    options: [
                              "alsa",
                              "oss",
                              "jack"
                    ]
                }
            }
        }
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            width: 1
            color: '#626262'
        }

        ColumnLayout {
            Layout.fillHeight: true
            Layout.preferredWidth: 165
            Text {
                Layout.alignment: Qt.AlignHCenter
                Layout.margins: 15
                text: "Outputs"
                color: '#626262'
                font.pixelSize: 14
            }

            Item {
                Layout.fillHeight: true
            }

            AudioEntity {
                Layout.margins: 15

                name: "Targus USB3 DV4K DOCK w PD100W"
                group: "output"
                gateways: [
                    QtObject {
                        property string label: "ALC289 Analog"
                        property string type: "sink"
                    },
                    QtObject {
                        property string label: "HDMI 0"
                        property string type: "sink"
                    },
                    QtObject {
                        property string label: "HDMI 1"
                        property string type: "sink"
                    },
                    QtObject {
                        property string label: "HDMI 2"
                        property string type: "sink"
                    },
                    QtObject {
                        property string label: "HDMI 3"
                        property string type: "sink"
                    }
                ]

                onConnect: (point) => root.entityOnConnect(point)
                onDisconnect: (point) => root.entityOnDisconnect(point)
            }

            AudioEntity {
                Layout.margins: 15

                name: "Targus USB3 DV4K DOCK w PD100W"
                group: "output"
                gateways: [
                    QtObject {
                        property string label: "USB Audio"
                        property string type: "sink"
                    }
                ]

                onConnect: (point) => root.entityOnConnect(point)
                onDisconnect: (point) => root.entityOnDisconnect(point)
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }

    Component.onCompleted: {
        for (let deckIdx = 0; deckIdx < decks.model; deckIdx++) {
            root.connections.add(connectionEdge.createObject(root, {
                        "router": root,
                        "source": decks.itemAt(deckIdx).handleSource,
                        "sink": mixer.handleSink,
                        "system": true
            }))
        }
        root.connections.add(connectionEdge.createObject(root, {
                    "router": root,
                    "source": mixer.handleSource,
                    "sink": record.handleSink,
                    "system": true,
                    "vertical": true
        }))
    }
}
