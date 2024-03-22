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

        Drag.active: mouseArea.drag.active
        Drag.source: parent
        Drag.dragType: Drag.Automatic
        Drag.supportedActions: Qt.MoveAction
        Drag.hotSpot.x: mouseArea.mouseX
        Drag.hotSpot.y: mouseArea.mouseY

        ColumnLayout {
            anchors.fill: parent
            spacing: 5
            Rectangle {
                Layout.fillWidth: true
                height: searchBar.implicitHeight

                border.color: 'red'

                TextInput {
                    id: searchBar

                    anchors.fill: parent

                    text: "Search..."
                    cursorVisible: true
                }
            }
            ScrollView {
                Layout.fillHeight: true
                Layout.fillWidth: true
                // Layout.preferredHeight: contentHeight

                // FIXME(ac) - Unsupported in Qt 6.2 - Use Jan's LibrarySidebar
                // TreeView {
                //     id: featureView
                //     // Layout.fillHeight: true

                //     focus: true
                //     clip: true

                //     Component.onCompleted: {
                //         console.log(Mixxx.TreeFromListModel)
                //     }

                //     model: Mixxx.Library.sidebar

                //     selectionModel: ItemSelectionModel {}

                //     delegate: Item {
                //         id: featureDelegate

                //         required property string label
                //         required property string icon

                //         readonly property real indentation: 10
                //         readonly property real padding: 5

                //         // Assigned to by TreeView:
                //         required property int index
                //         required property TreeView treeView
                //         required property bool isTreeNode
                //         required property bool expanded
                //         required property int hasChildren
                //         required property int depth
                //         required property int row
                //         required property int column
                //         required property bool current

                //         // height: featureLabel.implicitHeight // + 6 + (featureDelegate.expanded && options.count ? featureOptionView.contentHeight + 6 : 0)

                //         // implicitWidth: padding + featureLabel.x + featureLabel.implicitWidth + padding
                //         implicitWidth: treeView.width
                //         implicitHeight: featureLabel.implicitHeight * 1.5

                //         Behavior on height {
                //             NumberAnimation { duration: 200 }
                //         }

                //         MouseArea {
                //             id: mouseArea
                //             anchors.fill: parent
                //             drag {
                //                 target: !hasChildren ? parent : null
                //             }
                //         }

                //         Drag.active: mouseArea.drag.active
                //         Drag.dragType: Drag.Automatic
                //         Drag.supportedActions: Qt.CopyAction
                //         Drag.hotSpot.x: mouseArea.mouseX
                //         Drag.hotSpot.y: mouseArea.mouseY

                //         // Rotate indicator when expanded by the user
                //         // (requires TreeView to have a selectionModel)
                //         property Animation indicatorAnimation: NumberAnimation {
                //             target: indicator
                //             property: "rotation"
                //             from: expanded ? 0 : 90
                //             to: expanded ? 90 : 0
                //             duration: 100
                //             easing.type: Easing.OutQuart
                //         }
                //         TableView.onPooled: indicatorAnimation.complete()
                //         TableView.onReused: if (current) indicatorAnimation.start()
                //         onExpandedChanged: indicator.rotation = expanded ? 90 : 0

                //         Rectangle {
                //             id: background
                //             anchors.fill: parent
                //             color: row === treeView.currentRow ? palette.highlight : "black"
                //             opacity: (treeView.alternatingRows && row % 2 !== 0) ? 0.3 : 0.1
                //         }

                //         RowLayout {
                //             anchors {
                //                 leftMargin: padding + (depth * indentation)
                //                 fill: parent
                //             }

                //             Label {
                //                 id: indicator
                //                 Layout.preferredWidth: indicator.implicitWidth
                //                 opacity: isTreeNode && hasChildren ? 1 : 0
                //                 text: "▶"

                //                 TapHandler {
                //                     onSingleTapped: {
                //                         let index = treeView.index(row, column)
                //                         console.log(`${index} ${row} ${column}`)
                //                         treeView.selectionModel.setCurrentIndex(index, ItemSelectionModel.NoUpdate)
                //                         treeView.toggleExpanded(row)
                //                         treeView.forceLayout()
                //                     }
                //                 }
                //             }

                //             // Label {
                //             //     id: label
                //             //     x: padding + (isTreeNode ? (depth + 1) * indentation : 0)
                //             //     anchors.verticalCenter: parent.verticalCenter
                //             //     width: parent.width - padding - x
                //             //     clip: true
                //             //     text: model.label
                //             // }

                //             Item {
                //                 id: icon
                //                 height: 14
                //                 Layout.preferredWidth: 14

                //                 Image {
                //                     anchors.fill: parent
                //                     source: `../../res/images/library/ic_library_${featureDelegate.icon}.svg`
                //                 }
                //             }

                //             Text {
                //                 id: featureLabel
                //                 Layout.fillWidth: true

                //                 font.weight: Font.Bold
                //                 text: featureDelegate.label
                //                 color: 'white'
                //             }
                //         }
                //     }
                // }
            }
        }
    }
}
