import "." as Skin
import Mixxx 1.0 as Mixxx
import Qt.labs.qmlmodels
import QtQml
import QtQuick
import QtQml.Models
import QtQuick.Layouts
import QtQuick.Controls 2.15
import "Theme"

Rectangle {
    id: root

    signal allModel()

    required property var model
    readonly property var featureSelection: ItemSelectionModel {}

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

                color: featureSelection.currentIndex.valid ? "#212121" : "#676767"

                Label {
                    id: searchBar
                    anchors.fill: parent
                    anchors.topMargin: 12
                    anchors.leftMargin: 30
                    anchors.rightMargin: 30
                    anchors.bottomMargin: 12

                    text: "All"
                    color: "#D9D9D9"
                    TapHandler {
                        onTapped: {
                            featureSelection.clearCurrentIndex()
                            root.allModel()
                        }
                    }
                }
            }
            ScrollView {
                Layout.fillHeight: true
                Layout.fillWidth: true

                TreeView {
                    id: featureView
                    Layout.fillWidth: true

                    clip: true

                    model: root.model

                    selectionModel: featureSelection

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
                        readonly property var index: treeView.modelIndex(column, row) // FIXME this seems to become "row,column" in future version of Qt (after 6.4). Update to `index` when upgradeing

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

                            Rectangle {
                                width: 25
                                anchors.left: parent.left
                                anchors.leftMargin: 10 + 15 * depth
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                anchors.right: parent.right
                                color: current ? "#676767" : 'transparent'

                                Image {
                                    id: lineIcon
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
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
                                    anchors.left: parent.left
                                    anchors.leftMargin: 34
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
                                onClicked: {
                                    treeView.model.activate(index)
                                    console.log(treeView.modelIndex(column, row))
                                    if (isTreeNode && hasChildren) {
                                        treeView.toggleExpanded(row)
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
