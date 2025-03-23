import QtQuick 2.12
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    radius: 15
    color: '#3F3F3F'

    signal connect(var entity)
    signal disconnect(var entity)

    required property string name
    required property string group
    property list<QtObject> gateways: []
    implicitHeight: 40 + 24 * gateways.length
    implicitWidth: 135

    property alias handleSource: handleSourceEdge
    property alias handleSink: handleSinkEdge

    property var metaType: null
    Rectangle {
        id: edge
        visible: root.metaType != null
        property var entity: root
        property string type: root.metaType
        property string group: root.group

        property var connection: null

        anchors.horizontalCenter: root.metaType == "source" ? parent.right : parent.left
        anchors.verticalCenter: parent.verticalCenter
        color: edge.connection ? edge.connection.state == "impossible" ? '#7D3B3B' : '#D9D9D9' : '#626262'
        width: 10
        height: 10
        radius: 5
        MouseArea {
            hoverEnabled: edge.connection != null
            anchors.fill: parent
            onPressed: {
                if (edge.connection && edge.connection.state == "impossible") {
                    root.disconnect(parent)
                } else if (edge.connection == null) {
                    root.connect(parent)
                }
            }
            onEntered: {
                if (edge.connection) {
                    edge.connection.state = "impossible"
                }
            }
            onExited: {
                if (edge.connection) {
                    edge.connection.state = "set"
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent

        Label {
            id: nameLabel
            horizontalAlignment: Text.AlignHCenter
            Layout.margins: 9
            Layout.preferredWidth: 112
            text: name
            color: '#D9D9D9'
            elide: Text.ElideRight
            font.pixelSize: 15
            fontSizeMode: Text.Fit
        }

        Repeater {
            model: root.gateways
            Item {
                required property int index
                required property string label
                required property string type
                property bool required

                Layout.bottomMargin: index != gateways.length - 1 ? 8 : 12
                Layout.fillWidth: true
                implicitHeight: inputLabel.implicitHeight
                id: node
                Label {
                    anchors {
                        left: parent.left
                        leftMargin: 15
                    }
                    id: inputLabel
                    text: label
                    color: '#D9D9D9'
                    font.pixelSize: 10
                }
                Rectangle {
                    id: edge
                    property var entity: root
                    property string type: node.type
                    property string group: root.group

                    property var connection: null

                    anchors.horizontalCenter: parent.type == "source" ? parent.right : parent.left
                    color: (edge.connection && edge.connection.state == "impossible" || node.required) ? '#7D3B3B' : edge.connection ? '#D9D9D9' : '#626262'
                    width: 10
                    height: 10
                    radius: 5
                    MouseArea {
                        hoverEnabled: edge.connection != null
                        anchors.fill: parent
                        onPressed: {
                            if (edge.connection && edge.connection.state == "impossible") {
                                root.disconnect(parent)
                            } else if (edge.connection == null) {
                                root.connect(parent)
                            }
                        }
                        onEntered: {
                            if (edge.connection) {
                                edge.connection.state = "impossible"
                            }
                        }
                        onExited: {
                            if (edge.connection) {
                                edge.connection.state = "set"
                            }
                        }
                    }
                }
            }
        }
    }
    AudioEntityEdge {
        id: handleSourceEdge

        entity: root
        type: "source"

        anchors.horizontalCenter: handleSourceEdge.vertical ? parent.horizontalCenter : parent.right
        anchors.verticalCenter: handleSourceEdge.vertical ? parent.bottom : undefined
        anchors.top: handleSourceEdge.vertical ? undefined :parent.top
        anchors.topMargin: handleSourceEdge.vertical ? 0 :16
    }
    AudioEntityEdge {
        id: handleSinkEdge
        entity: root
        type: "sink"

        anchors.horizontalCenter: handleSinkEdge.vertical ? parent.horizontalCenter : parent.left
        anchors.verticalCenter: handleSinkEdge.vertical ? parent.top : parent.verticalCenter
    }
}
