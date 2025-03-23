import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    readonly property alias dragImage: dragImageEffect

    anchors.fill: parent

    color: selected ? '#2c454f' : (row % 2 == 0 ? '#0C0C0C' : '#272727')

    Drag.dragType: Drag.Automatic
    Drag.supportedActions: Qt.CopyAction
    Drag.mimeData: {
        "text/uri-list": file_url,
        "text/plain": file_url
    }
    Item {
        id: dragImageSource
        width: 190
        height: 85
        visible: false
        Rectangle {
            color: '#0C0C0C'
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                bottom: parent.bottom
                margins: 5
            }
            radius: 12
            RowLayout {
                anchors.fill: parent
                Image {
                    id: cover
                    Layout.fillHeight: true
                    Layout.preferredWidth: cover_art ? 75 : 0
                    fillMode: Image.PreserveAspectFit
                    source: cover_art
                    clip: true
                    asynchronous: true
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Text {
                        text: track ? track.title : 'Unknown title'
                        color: '#D9D9D9'
                    }
                    Text {
                        text: track ? track.title : 'Unknown artist'
                        color: '#626262'
                    }
                }
            }
            Rectangle {
                width: 20
                anchors {
                    top: parent.top
                    right: parent.right
                    bottom:parent.bottom
                }
                gradient: Gradient {
                    orientation: Gradient.Horizontal

                    GradientStop {
                        position: 1
                        color: '#000000'
                    }

                    GradientStop {
                        position: 0
                        color: '#00000000'
                    }
                }
            }
        }
    }
    DropShadow {
        id: dragImageEffect
        visible: false
        anchors.fill: dragImageSource
        source: dragImageSource
        horizontalOffset: 0
        verticalOffset: 0
        radius: 10.0
        color: "#80000000"
    }

    Rectangle {
        id: border
        color: '#202020'
        width: 1
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }
    }
}
