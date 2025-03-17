import "." as Skin
import Mixxx 1.0 as Mixxx
import Qt.labs.qmlmodels
import QtQml
import QtQuick
import QtQml.Models
import QtQuick.Layouts
import QtQuick.Controls 2.15
import "Theme"

Skin.LibraryPanel {
    id: root

    signal selected(feature: color)

    Mixxx.LibrarySourceTree {
        id: librarySources
        Mixxx.LibraryPlaylistSource {
            label: "Playlist"
            icon: "images/library_playlist.svg"
        }
        Mixxx.LibraryPlaylistSource {
            label: "Playlist"
            icon: "images/library_playlist.svg"
        }
        // Mixxx.LibraryCrateSource {
        //     label: "Crate"
        //     icon: "images/library_crate.svg"
        // }
        Mixxx.LibraryExplorerSource {
            label: "Explorer"
            icon: "images/library_explorer.svg"
        }
    }

    Rectangle {
        id: treeView

        anchors.fill: parent

        color: '#242424'

        // MouseArea {
        //     id: mouseArea
        //     anchors.fill: parent
        //     drag {
        //         target: parent
        //     }
        // }

        // Drag.active: mouseArea.drag.active
        // Drag.source: parent
        // Drag.dragType: Drag.Automatic
        // Drag.supportedActions: Qt.MoveAction
        // Drag.hotSpot.x: mouseArea.mouseX
        // Drag.hotSpot.y: mouseArea.mouseY

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 7
            anchors.leftMargin: 7
            anchors.rightMargin: 25
            anchors.bottomMargin: 40
            color: '#0E0E0E'

            ColumnLayout {
                anchors.fill: parent
                spacing: 0
                Rectangle {
                    Layout.fillWidth: true
                    height: searchBar.implicitHeight + 24

                    color: "#676767"

                    TextInput {
                        id: searchBar
                        anchors.fill: parent
                        anchors.topMargin: 12
                        anchors.leftMargin: 30
                        anchors.rightMargin: 30
                        anchors.bottomMargin: 12

                        text: "All..."
                        cursorVisible: true
                        color: "#D9D9D9"
                    }
                }
                ScrollView {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    // Layout.preferredHeight: contentHeight

                    // FIXME(ac) - Unsupported in Qt 6.2 - Use Jan's LibrarySidebar
                    TreeView {
                        id: featureView
                        // Layout.fillHeight: true

                        focus: true
                        clip: true

                        Component.onCompleted: {
                            console.log(Mixxx.TreeFromListModel)
                        }

                        // model: Mixxx.Library.sidebar
                        model: librarySources.model()

                        selectionModel: ItemSelectionModel {}

                        delegate: Item {

                            required property string label
                            required property var icon

                            readonly property real indentation: 40
                            readonly property real padding: 5

                            // Assigned to by TreeView:
                            required property TreeView treeView
                            required property bool isTreeNode
                            required property bool expanded
                            required property int hasChildren
                            required property int depth
                            required property int row
                            required property int column
                            required property bool current

                            Component.onCompleted: {
                                console.warn(depth, padding + (depth * indentation), icon)
                            }

                            implicitWidth: treeView.width
                            implicitHeight: depth == 0 ? 42 : 35

                            // Rotate indicator when expanded by the user
                            // (requires TreeView to have a selectionModel)
                            property Animation indicatorAnimation: NumberAnimation {
                                target: indicator
                                property: "rotation"
                                from: expanded ? 0 : 90
                                to: expanded ? 90 : 0
                                duration: 100
                                easing.type: Easing.OutQuart
                            }
                            TableView.onPooled: indicatorAnimation.complete()
                            TableView.onReused: if (current) indicatorAnimation.start()
                            onExpandedChanged: indicator.rotation = expanded ? 90 : 0

                            Rectangle {
                                id: background
                                anchors.fill: parent
                                color: depth == 0 ? "#212121" : 'transparent'
                                // color: row === treeView.currentRow ? palette.highlight : "black"
                                // opacity: (treeView.alternatingRows && row % 2 !== 0) ? 0.3 : 0.1

                                Item {
                                    width: 25
                                    anchors.leftMargin: 10 + 15 * depth
                                    anchors.verticalCenter: parent.verticalCenter

                                    Image {
                                        id: lineIcon
                                        anchors.left: parent.left
                                        visible: depth == 0
                                        source: icon ? `images/library_${icon}.png` : null
                                        height: 25
                                        width: 25
                                    }

                                    Label {
                                        id: indicator
                                        Layout.preferredWidth: indicator.implicitWidth
                                        visible: isTreeNode && hasChildren
                                        color: "#D9D9D9"
                                        text: "▶"

                                        anchors {
                                            left: parent.left
                                            verticalCenter: lineIcon.bottom
                                        }
                                    }

                                    Label {
                                        id: labelItem
                                        anchors.left: lineIcon.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        clip: true
                                        font.weight: depth == 0 ? Font.Bold : Font.Medium
                                        font.pixelSize: 14
                                        text: label
                                        color: "#D9D9D9"
                                    }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                                    onClicked: isTreeNode && hasChildren ? treeView.toggleExpanded(row) : null
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
