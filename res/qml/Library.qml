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

Item {
    id: root

    Item {

        id: panelRoot
        property Item activePanel: null
        anchors.fill: parent

        component ColumnCreator: DropArea {
            required property int columnIndex
            width: 50
            property bool isRightSplitter: false
            onDropped: function moveToNewColumn(drag) {
                let cell = null
                let preferredWidth = 0
                let fillWidth = true
                let usedWidth = 0, expandedColumn = 1;
                for (let i = 0; i < rootPanelModel.count; i++) {
                    usedWidth += rootPanelModel.get(i).preferredWidth;
                    if (!rootPanelModel.get(i).preferredWidth) {
                        expandedColumn++;
                    }
                }
                preferredWidth = (splitView.width - usedWidth) / expandedColumn;

                if (drag.action == Qt.CopyAction && drag.source.element instanceof Object) {
                    cell = {
                        "type": "TrackList",
                        "preferredHeight": 0 ,
                        "fillHeight": true,
                    };
                } else if ((drag.source.columnIndex != root.columnIndex || drag.source.rowIndex != root.rowIndex ) && drag.source instanceof LibraryPanel) {
                    cell = rootPanelModel.get(drag.source.columnIndex).rows.get(drag.source.rowIndex)
                    cell = JSON.parse(JSON.stringify(cell))

                    rootPanelModel.get(drag.source.columnIndex).rows.remove(drag.source.rowIndex)
                    if (rootPanelModel.get(drag.source.columnIndex).rows.count == 0) {
                        preferredWidth = rootPanelModel.get(drag.source.columnIndex).preferredWidth
                        rootPanelModel.remove(drag.source.columnIndex)
                    } else if (rootPanelModel.get(drag.source.columnIndex).preferredWidth) {
                        preferredWidth = rootPanelModel.get(drag.source.columnIndex).preferredWidth
                        fillWidth = false
                    }
                }

                if (cell == null) return;

                rootPanelModel.insert(columnIndex + isRightSplitter, {
                        "rows": [
                            cell
                        ],
                        "fillWidth": false,
                        "preferredWidth": preferredWidth
                })
                drag.acceptProposedAction()
                splitPanel.visible = false
                removePanel.visible = false
            }

            onEntered: function(drag) {
                if (drag.action == Qt.MoveAction && (drag.source.columnIndex == undefined || (drag.source.columnIndex == columnIndex + isRightSplitter && rootPanelModel.get(drag.source.columnIndex).rows.count == 1))) return;
                splitPanel.visible = true
            }

            onExited: function() {
                splitPanel.visible = false
            }

            Rectangle  {
                id: splitPanel
                color: 'white'
                opacity: 0.4
                visible: false
                anchors.fill: parent
            }
        }

        function panelActivate(panel) {
            panelRoot.activePanel = panel
        }
        function panelSelected(selection) {
            if (!panelRoot.activePanel) {
                return;
            }
            panelRoot.activePanel.color = selection
        }
        function panelDragStart() {
            let panelCount = 0
            for (let i = 0; i < rootPanelModel.count; i++) {
                for (let j = 0; j < rootPanelModel.get(i).rows.count; j++) {
                    if (rootPanelModel.get(i).rows.get(j).type == "TrackList") {
                        panelCount++;
                    }
                }
            }
            removePanel.visible = panelCount > 1
        }
        function panelDragStop() {
            removePanel.visible = false
        }

        SplitView {
            id: splitView

            anchors.fill: parent

            Component.onCompleted: {
                panelRoot.activePanel = rootPanelModel.get(0).rows.get(0)
            }

            handle: Rectangle {
                id: handleDelegate
                implicitWidth: 8
                implicitHeight: 8
                color: Theme.libraryPanelSplitterBackground
                clip: true
                property color handleColor: SplitHandle.pressed || SplitHandle.hovered ? Theme.libraryPanelSplitterHandleActive : Theme.libraryPanelSplitterHandle
                property int handleSize: SplitHandle.pressed || SplitHandle.hovered ? 6 : 5

                ColumnLayout {
                    anchors.centerIn: parent
                    Repeater {
                        model: 3
                        Rectangle {
                            width: handleSize
                            height: handleSize
                            radius: handleSize
                            color: handleColor
                        }
                    }
                }

                containmentMask: Item {
                    x: (handleDelegate.width - width) / 2
                    width: 8
                    height: splitView.height
                }
            }

            Repeater {
                model: DelegateModel {
                    model: ListModel {
                        id: rootPanelModel
                        ListElement {
                            preferredWidth: 300
                            fillWidth: false
                            rows: [
                                ListElement {
                                    preferredHeight: 100
                                    type: "PreviewDeck"
                                    fillHeight: false
                                },
                                ListElement {
                                    preferredHeight: 500
                                    type: "Browser"
                                    fillHeight: true
                                },
                                ListElement {
                                    preferredHeight: 300
                                    type: "CoverPreview"
                                    fillHeight: false
                                }
                            ]
                        }
                        ListElement {
                            preferredWidth: 0
                            fillWidth: true
                            rows: [
                                ListElement {
                                    preferredHeight: 100
                                    type: "TrackList"
                                    fillHeight: true
                                }
                            ]
                        }
                    }
                    delegate: Item {
                        id: columnView

                        required property var rows
                        required property real preferredWidth
                        required property bool fillWidth
                        property int index: DelegateModel.itemsIndex

                        SplitView.preferredWidth: preferredWidth
                        SplitView.fillWidth: fillWidth

                        SplitView {

                            orientation: Qt.Vertical

                            anchors.fill: parent

                            handle: Rectangle {
                                id: handleDelegate
                                implicitWidth: 8
                                implicitHeight: 8
                                color: Theme.libraryPanelSplitterBackground
                                clip: true
                                property color handleColor: SplitHandle.pressed || SplitHandle.hovered ? Theme.libraryPanelSplitterHandleActive : Theme.libraryPanelSplitterHandle
                                property int handleSize: SplitHandle.pressed || SplitHandle.hovered ? 6 : 5

                                RowLayout {
                                    anchors.centerIn: parent
                                    Repeater {
                                        model: 3
                                        Rectangle {
                                            width: handleSize
                                            height: handleSize
                                            radius: handleSize
                                            color: handleColor
                                        }
                                    }
                                }

                                containmentMask: Item {
                                    x: (handleDelegate.width - width) / 2
                                    width: 8
                                    height: splitView.height
                                }
                            }

                            Repeater {
                                model: rows

                                DelegateChooser {

                                    id: loader

                                    role: "type"

                                    DelegateChoice {
                                        roleValue: "Browser"
                                        LibraryBrowser {
                                            required property int index

                                            required property real preferredHeight
                                            required property bool fillHeight

                                            SplitView.fillHeight: fillHeight
                                            SplitView.preferredHeight: preferredHeight
                                            columnIndex: columnView.index
                                            rowIndex: index
                                            panelModel: rootPanelModel

                                            onSelected: panelRoot.panelSelected()
                                        }
                                    }
                                    DelegateChoice {
                                        roleValue: "TrackList"
                                        LibraryTrackList {
                                            required property int index

                                            required property real preferredHeight
                                            required property bool fillHeight

                                            SplitView.fillHeight: fillHeight
                                            SplitView.preferredHeight: preferredHeight

                                            color: 'transparent'
                                            columnIndex: columnView.index
                                            rowIndex: index
                                            panelModel: rootPanelModel

                                            onActivated: panelRoot.panelActivate(this)
                                            onDragStart: panelRoot.panelDragStart()
                                            onDragStop: panelRoot.panelDragStop()
                                        }
                                    }
                                    DelegateChoice {
                                        roleValue: "PreviewDeck"

                                        Skin.LibraryPreviewDeck {
                                            required property int index

                                            required property real preferredHeight
                                            required property bool fillHeight

                                            SplitView.fillHeight: fillHeight
                                            SplitView.preferredHeight: preferredHeight

                                            columnIndex: columnView.index
                                            rowIndex: index
                                            panelModel: rootPanelModel
                                        }
                                    }
                                    DelegateChoice {
                                        roleValue: "CoverPreview"
                                        Skin.LibraryPanel {
                                            required property int index

                                            required property real preferredHeight
                                            required property bool fillHeight

                                            SplitView.fillHeight: fillHeight
                                            SplitView.preferredHeight: preferredHeight

                                            columnIndex: columnView.index
                                            rowIndex: index
                                            panelModel: rootPanelModel

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
                                                    text: "CovertArt placeholder"
                                                }

                                                Drag.active: mouseArea.drag.active
                                                Drag.source: parent
                                                Drag.dragType: Drag.Automatic
                                                Drag.supportedActions: Qt.MoveAction
                                                Drag.hotSpot.x: mouseArea.mouseX
                                                Drag.hotSpot.y: mouseArea.mouseY
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        ColumnCreator {
                            columnIndex: columnView.index
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                        }
                        ColumnCreator {
                            columnIndex: columnView.index
                            isRightSplitter: true
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                        }
                    }
                }
            }
        }

        DropArea {
            id: removePanel
            visible: false
            height: 40
            width: 40
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10;
            anchors.horizontalCenter: parent.horizontalCenter
            onDropped: function(drag) {
                if (drag.source.columnIndex == undefined) return;

                rootPanelModel.get(drag.source.columnIndex).rows.remove(drag.source.rowIndex)
                if (rootPanelModel.get(drag.source.columnIndex).rows.count == 0) {
                    rootPanelModel.remove(drag.source.columnIndex)
                }
                drag.acceptProposedAction()
                visible = false
            }

            property Item itemToRemove

            onEntered: function(drag) {
                if (drag.source.columnIndex == undefined) return;
                deleteIndicator.hovered = true
                drag.source.opacity = 0.5
                itemToRemove = drag.source
                drag.acceptProposedAction()
            }

            onExited: function() {
                itemToRemove.opacity = 1
                deleteIndicator.hovered = false
                itemToRemove = null
            }

            Rectangle  {
                id: deleteIndicator

                property bool hovered: false

                radius: 20
                clip: true
                color: Qt.alpha(hovered ? '#ff7f7f' : '#ffffff', 0.5)
                opacity: hovered ? 0.6 : 0.4

                anchors.fill: parent

                Shape {
                    anchors.fill: parent
                    ShapePath {
                        strokeColor: "#ffffff"
                        strokeWidth: 2
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap

                        startX: 10
                        startY: 10
                        PathLine { x: 30; y: 30 }
                        PathLine { x: 20; y: 20 }
                        PathLine { x: 10; y: 30 }
                        PathLine { x: 30; y: 10 }
                    }
                }
            }
        }
    }
}
