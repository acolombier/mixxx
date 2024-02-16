import "." as Skin
import Mixxx 1.0 as Mixxx
import Qt.labs.qmlmodels
import QtQml
import QtQuick
import QtQml.Models
import QtQuick.Layouts
import QtQuick.Controls 2.15
import "Theme"

DropArea {
    id: root

    required property int columnIndex
    required property int rowIndex
    required property var panelModel

    signal dragStart()
    signal dragStop()

    onDropped: function(drag) {
        if (!splitPreview.visible) {
            return
        }

        let isBottomSplitter = splitPreview.anchors.bottomMargin == 0

        if (drag.action == Qt.CopyAction && drag.source.element instanceof Object) {
            let currentItemHeight = height;
            let newPanelElement = drag.source.element;

            if (newPanelElement.preferredHeight == 0 || newPanelElement.fillHeight) {
                currentItemHeight /= 2;
                newPanelElement.preferredHeight = currentItemHeight;
            } else if (newPanelElement.preferredHeight > 0) {
                currentItemHeight -= newPanelElement.preferredHeight;
            }

            panelModel.get(columnIndex).rows.setProperty(rowIndex, "preferredHeight", currentItemHeight)
            panelModel.get(columnIndex).rows.insert(rowIndex + ((drag.y > height / 2) ? 1 : 0), newPanelElement)
        } else if ((drag.source.columnIndex != root.columnIndex || drag.source.rowIndex != root.rowIndex ) && drag.source instanceof LibraryPanel) {
            if (drag.source.columnIndex != columnIndex) {
                let model = panelModel.get(drag.source.columnIndex).rows.get(drag.source.rowIndex)

                panelModel.get(columnIndex).rows.insert(root.rowIndex + isBottomSplitter, model)
                panelModel.get(drag.source.columnIndex).rows.remove(drag.source.rowIndex)

                if (!model.preferredHeight || model.fillHeight) {
                    panelModel.get(columnIndex).rows.setProperty(rowIndex, "preferredHeight", height / 2)
                    panelModel.get(columnIndex).rows.setProperty(rowIndex + 1, "preferredHeight", height / 2)
                }
            } else {
                panelModel.get(drag.source.columnIndex).rows.move(drag.source.rowIndex, rowIndex, 1)
            }

            if (panelModel.get(drag.source.columnIndex).rows.count == 0) {
                panelModel.remove(drag.source.columnIndex)
            }
            root.dragStop()
        }
        splitPreview.visible = false
    }

    onExited: function() {
        splitPreview.visible = false
    }

    onPositionChanged: function(drag) {
        if (drag.action == Qt.MoveAction && drag.source.columnIndex == root.columnIndex && drag.source.rowIndex == root.rowIndex) {
            splitPreview.visible = false
            return;
        }
        if (drag.y > height / 2) {
            if (drag.action == Qt.MoveAction && drag.source.columnIndex == root.columnIndex && drag.source.rowIndex == root.rowIndex + 1) {
                splitPreview.visible = false
                return;
            }
            splitPreview.anchors.topMargin = height / 2
            splitPreview.anchors.bottomMargin = 0
        } else {
            if (drag.action == Qt.MoveAction && drag.source.columnIndex == root.columnIndex && drag.source.rowIndex + 1 == root.rowIndex) {
                splitPreview.visible = false
                return;
            }
            splitPreview.anchors.topMargin = 0
            splitPreview.anchors.bottomMargin = height / 2
        }
        splitPreview.visible = true
    }

    Rectangle {
        id: splitPreview
        z: 1000
        anchors.fill: parent
        color: 'white'
        opacity: 0.4
        visible: false
    }
}
