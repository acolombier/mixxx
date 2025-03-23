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

    color: '#161616'

    required property var model

    LibraryControl {
        id: libraryControl

        onMoveVertical: (offset) => {
            view.selectionModel.moveSelectionVertical(offset);
        }
        onLoadSelectedTrack: (group, play) => {
            view.loadSelectedTrack(group, play);
        }
        onLoadSelectedTrackIntoNextAvailableDeck: (play) => {
            view.loadSelectedTrackIntoNextAvailableDeck(play);
        }
        onFocusWidgetChanged: {
            switch (focusWidget) {
                case FocusedWidgetControl.WidgetKind.LibraryView:
                    view.forceActiveFocus();
                    break;
            }
        }
    }

    HorizontalHeaderView {
        id: horizontalHeader

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 5
        syncView: view

        property int sortingColumn: -1
        property var sortingOrder: Qt.Descending

        delegate: Item {
            id: column
            required property string display
            required property int index

            implicitHeight: columnName.contentHeight + 5
            implicitWidth: columnName.contentWidth + 5

            // required property var label

            MouseArea {
                id: columnMouseHandler
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (event) => {
                    if (event.button === Qt.RightButton)
                        contextMenu.popup()
                    else {
                        if (horizontalHeader.sortingColumn == index) {
                            horizontalHeader.sortingOrder = horizontalHeader.sortingOrder == Qt.DescendingOrder ? Qt.AscendingOrder : Qt.DescendingOrder
                        } else {
                            horizontalHeader.sortingColumn = index
                            horizontalHeader.sortingOrder = Qt.AscendingOrder
                        }
                        console.log(horizontalHeader.sortingColumn, horizontalHeader.sortingOrder)
                        view.model.sourceModel.sort(horizontalHeader.sortingColumn, horizontalHeader.sortingOrder);
                        root.model.columnCount()
                    }
                }
                // onReleased: (event) => {
                //     columnDragHandler.persistentTranslation = Qt.vector2d(0,0)
                // }
                onPressAndHold: (event) => {
                    if (event.source === Qt.MouseEventNotSynthesized)
                        contextMenu.popup()
                }

                Menu {
                    id: contextMenu
                    // Repeater {
                    //     id: columnListMenu
                    //     model: view.model.columns
                    //     MenuItem {
                    //         required property int index
                    //         checkable: true
                    //         checked: (hidden.fillSpan > 0 || hidden.preferredWidth > 0) && !hidden.hidden
                    //         text: hidden.columnName
                    //         onCheckedChanged: {
                    //             model.hidden = !checked
                    //             view.model.updateColumnProperty()
                    //             contextMenu.close()
                    //             // view.forceLayout()
                    //         }
                    //     }
                    // }
                }
            }

            Text {
                id: columnName

                text: display
                anchors.fill: parent
                anchors.leftMargin: 15
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                font.family: Theme.fontFamily
                font.capitalization: Font.Capitalize
                font.pixelSize: 12
                font.weight: Font.Medium
                color: "#D9D9D9"
            }

            Item {
                anchors {
                    left: parent.left
                    leftMargin: 5
                    top: parent.top
                    bottom: parent.bottom
                }
                Label {
                    id: sortIndicator

                    visible: horizontalHeader.sortingColumn == index

                    text: "▶"
                    rotation: horizontalHeader.sortingOrder == Qt.AscendingOrder ? 90 : -90

                    anchors.centerIn: parent
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                    font.family: Theme.fontFamily
                    font.capitalization: Font.AllUppercase
                    font.bold: true
                    font.pixelSize: Theme.buttonFontPixelSize
                    color: "red"
                }
            }
            Rectangle {
                id: columnResizer
                color: '#202020'
                width: 1
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    right: parent.right
                }
                MouseArea {
                    id: columnResizeHandler

                    property int sizeOffset: 0

                    anchors.fill: parent
                    preventStealing: true
                    drag {
                        target: parent
                        axis: Drag.XAxis
                        threshold: 2
                        onActiveChanged: {
                            if (!drag.active && columnResizeHandler.sizeOffset !== 0) {
                                view.model.columns[index].preferredWidth = headerDlgt.width + sizeOffset
                                view.model.updateColumnProperty()
                                columnResizeHandler.sizeOffset = 0
                                // view.forceLayout()
                            }
                        }
                    }
                    cursorShape: Qt.SizeHorCursor
                    onMouseXChanged: {
                        if (drag.active) {
                            headerDlgt.width = headerDlgt.width + mouseX
                            sizeOffset = mouseX
                        }
                    }
                }
            }
        }
    }

    TableView {
        id: view

        function loadSelectedTrackIntoNextAvailableDeck(play) {
            const urls = this.selectionModel.selectedTrackUrls();
            if (urls.length == 0)
                return ;

            Mixxx.PlayerManager.loadLocationUrlIntoNextAvailableDeck(urls[0], play);
        }

        function loadSelectedTrack(group, play) {
            const urls = this.selectionModel.selectedTrackUrls();
            if (urls.length == 0)
                return ;

            player.loadTrackFromLocationUrl(urls[0], play);
        }

        anchors.top: horizontalHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 5
        clip: true
        reuseItems: true
        Keys.onUpPressed: this.selectionModel.moveSelectionVertical(-1)
        Keys.onDownPressed: this.selectionModel.moveSelectionVertical(1)
        Keys.onEnterPressed: this.loadSelectedTrackIntoNextAvailableDeck(false)
        Keys.onReturnPressed: this.loadSelectedTrackIntoNextAvailableDeck(false)
        model: root.model
        function updateColumnSize() {
            usedWidth = 0;
            dynamicColumnCount = 0;
            for (let c = 0; c < model.columns.length; c++) {
                if (model.columns[c].hidden) {
                    continue
                } else if (model.columns[c].preferredWidth > 0) {
                    usedWidth += model.columns[c].preferredWidth;
                } else {
                    dynamicColumnCount += model.columns[c].fillSpan || 1
                }
            }
        }
        Component.onCompleted: this.updateColumnSize()
        onModelChanged: this.updateColumnSize()

        property int usedWidth: 0
        property int dynamicColumnCount: 0

        columnWidthProvider: function(column) {
            const columnDef = view.model.columns[column]
            if (columnDef.hidden) {
                return 0;
            }
            if (columnDef.preferredWidth >= 0) {
                return columnDef.preferredWidth;
            } else {
                const span = columnDef.fillSpan || 1;
                return span * (view.width - view.usedWidth) / view.dynamicColumnCount;
            }
            return 100;
        }

        selectionModel: ItemSelectionModel {
            function selectRow(row) {
                const rowCount = this.model.rowCount();
                if (rowCount == 0) {
                    this.clear();
                    return ;
                }
                const newRow = Mixxx.MathUtils.positiveModulo(row, rowCount);
                this.select(this.model.index(newRow, 0), ItemSelectionModel.Rows | ItemSelectionModel.Select | ItemSelectionModel.Clear | ItemSelectionModel.Current);
            }

            function moveSelectionVertical(value) {
                if (value == 0)
                    return ;

                const selected = this.selectedIndexes;
                const oldRow = (selected.length == 0) ? 0 : selected[0].row;
                this.selectRow(oldRow + value);
            }

            function selectedTrackUrls() {
                return this.selectedIndexes.map((index) => {
                        return this.model.getUrl(index.row);
                });
            }
            model: view.model
        }

        delegate: Item {
            id: item
            required property bool selected
            required property color decoration
            required property var display
            required property var track
            required property string file_url
            required property url cover_art
            required property int row

            implicitHeight: 30

            Loader {
                id: loader
                anchors.fill: parent
                property bool selected: item.selected
                property color decoration: item.decoration
                property var display: item.display
                property var track: item.track
                property url file_url: item.file_url
                property url cover_art: item.cover_art
                property int row: item.row
                property var tableView: view
                property var model: root.model
                sourceComponent: delegate

                onLoaded: {
                    Mixxx.Library.analyze(track)
                }
            }
            TableView.onReused: {
                Mixxx.Library.analyze(track)
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: search.open
        onPressed: {
            search.open = false
        }
    }

    Rectangle {
        id: search

        property bool open: false

        color: '#D9D9D9'
        radius: 16
        width: search.open ? 504 : 280
        height: search.open ? 160 : 56
        anchors {
            bottom: parent.bottom
            right: parent.right
            bottomMargin: -16
            rightMargin: -16
        }
        TextInput {
            id: input
            visible: search.open
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                leftMargin: 16
                rightMargin: 16
                topMargin: 14
            }
            cursorVisible: true
            cursorDelegate: Rectangle {
                color: '#50808080'
                width: 2
                height: 18
            }
            text: ""
        }
        Label {
            id: instruction
            anchors {
                top: parent.top
                left: search.open ? undefined : parent.left
                leftMargin: search.open ? 0 : 16
                topMargin: 14
            }
            x: search.open ? input.cursorRectangle.right+16 : null
            text: search.open ? "Start typing to get suggestion" : "Search..."
            font.weight: search.open ? Font.ExtraLight : Font.DemiBold
            font.italic: search.open
            color: '#808080'
        }
        Rectangle {
            id: splitter
            width: parent.width
            height: 1
            color: '#757575'
            anchors {
                top: instruction.bottom
                topMargin: 12
            }
        }
        Rectangle {
            id: criteria
            anchors {
                top: splitter.bottom
                left: parent.left
                topMargin: 4
                leftMargin: 4
            }
            width: key.implicitWidth + value.implicitWidth + 16
            height: key.implicitHeight + 12
            color: '#2D4EA1'
            radius: 7
            Label {
                id: key
                anchors {
                    left: parent.left
                    leftMargin: 5
                    verticalCenter: parent.verticalCenter
                }
                color: "#D9D9D9"
                text: "Artist:"
            }
            Rectangle {
                color: '#D9D9D9'
                radius: 7
                width: value.implicitWidth + 5
                height: parent.height - 6
                anchors {
                    right: parent.right
                    rightMargin: 3
                    verticalCenter: parent.verticalCenter
                }
                Label {
                    id: value
                    anchors {
                        centerIn: parent
                    }
                    color: "#202020"
                    text: "..."
                }
            }
        }
        MouseArea {
            enabled: !search.open
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onPressed: {
                search.open = true
            }
        }
    }
}
