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

    signal activated(panel: Item)

    required property color color

    Rectangle {
        id: panel
        anchors.fill: parent

        DragHandler {
            id: dragHandler
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onPressed: {
                root.activated(root)
            }
        }

        // onWidthChanged: {
        //     tableView.forceLayout()
        // }

        Drag.active: dragHandler.active
        Drag.onActiveChanged: {
            if (Drag.active) {
                root.dragStart()
            } else {
                root.dragStop()
            }
        }
        Drag.source: parent
        Drag.dragType: Drag.Automatic
        Drag.supportedActions: Qt.MoveAction
        Drag.hotSpot.x: mouseArea.mouseX
        Drag.hotSpot.y: mouseArea.mouseY

        color: Theme.deckBackgroundColor

        LibraryControl {
            id: libraryControl

            onMoveVertical: (offset) => {
                tableView.selectionModel.moveSelectionVertical(offset);
            }
            onLoadSelectedTrack: (group, play) => {
                tableView.loadSelectedTrack(group, play);
            }
            onLoadSelectedTrackIntoNextAvailableDeck: (play) => {
                tableView.loadSelectedTrackIntoNextAvailableDeck(play);
            }
            onFocusWidgetChanged: {
                switch (focusWidget) {
                    case FocusedWidgetControl.WidgetKind.LibraryView:
                        tableView.forceActiveFocus();
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
            model: tableView.model.columns.length
            syncView: tableView

            delegate: DropArea {
                id: headerDlgt

                required property int index
                property Mixxx.TableFromListModelColumn modelData: tableView.model.columns[index]

                implicitHeight: columnName.contentHeight + 5
                implicitWidth: columnName.contentWidth + 5

                property int dragOffset: 0

                onEntered: function(drag) {
                    columnMouseHandler.hoverEnabled = true
                }

                onExited: function() {
                    columnMouseHandler.hoverEnabled = false
                }

                onPositionChanged: function(_) {
                    if (drag.x > width / 2 && drag.source.index < index && dragOffset >= 0) {
                        drag.source.dragOffset+=1;
                        x -= drag.source.width
                        drag.source.x += width
                    } else if (drag.x < width / 2 && drag.source.index > index && dragOffset <= 0) {
                        drag.source.dragOffset-=1;
                        x += drag.source.width
                        drag.source.x -= width
                    }
                }

                Item {

                    anchors.fill: parent

                    z: columnDragHandler.active || columnResizeHandler.drag.active ? 100 : 0

                    onWidthChanged: {
                        headerDlgt.modelData = tableView.model.columns[index]
                    }

                    DragHandler {
                        id: columnDragHandler
                        dragThreshold: 0
                        cursorShape: Qt.DragMoveCursor
                        yAxis.enabled: false
                        onActiveChanged: {
                            if (active) {
                                headerDlgt.dragOffset = 0
                            } else if (headerDlgt.dragOffset) {
                                for (let i = 0; i < headerDlgt.dragOffset; i++) {
                                    tableView.model.columns[index + i] = tableView.model.columns[index + i + 1]
                                }
                                tableView.model.columns[index + headerDlgt.dragOffset] = headerDlgt.modelData;
                                tableView.model.moveColumn(tableView.index(0, 0), index, tableView.index(0, 0), index + headerDlgt.dragOffset)
                                tableView.forceLayout()
                            }
                        }
                    }

                    Drag.active: columnDragHandler.active
                    Drag.source: parent
                    Drag.dragType: Drag.Automatic
                    Drag.supportedActions: Qt.MoveAction
                    Drag.hotSpot.x: parent.implicitWidth / 2

                    BorderImage {
                        anchors.fill: parent
                        horizontalTileMode: BorderImage.Stretch
                        verticalTileMode: BorderImage.Stretch
                        source: Theme.imgPopupBackground

                        border {
                            top: 10
                            left: 20
                            right: 20
                            bottom: 10
                        }
                    }

                    MouseArea {
                        id: columnMouseHandler
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked: (event) => {
                            if (event.button === Qt.RightButton)
                                contextMenu.popup()
                        }
                        onReleased: (event) => {
                            columnDragHandler.persistentTranslation = Qt.vector2d(0,0)
                        }
                        onPressAndHold: (event) => {
                            if (event.source === Qt.MouseEventNotSynthesized)
                                contextMenu.popup()
                        }

                        Menu {
                            id: contextMenu
                            Repeater {
                                id: columnListMenu
                                model: tableView.model.columns.length
                                MenuItem {
                                    required property int index
                                    property Mixxx.TableFromListModelColumn modelData: tableView.model.columns[index]
                                    checkable: true
                                    checked: (modelData.fillSpan > 0 || modelData.prefferedWidth > 0) && !modelData.hidden
                                    text: modelData.columnName
                                    onTriggered: {
                                        tableView.model.columns[index].hidden = !checked
                                        tableView.model.updateColumnProperty()
                                        tableView.forceLayout()
                                    }
                                }
                            }
                        }
                    }

                    Text {
                        id: columnName

                        text: headerDlgt.modelData.columnName
                        anchors.fill: parent
                        anchors.margins: 5
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.family: Theme.fontFamily
                        font.capitalization: Font.AllUppercase
                        font.bold: true
                        font.pixelSize: Theme.buttonFontPixelSize
                        color: Theme.buttonNormalColor
                    }

                    Text {
                        id: sortIndicator

                        anchors.fill: parent
                        anchors.margins: 5
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        font.family: Theme.fontFamily
                        font.capitalization: Font.AllUppercase
                        font.bold: true
                        font.pixelSize: Theme.buttonFontPixelSize
                        color: Theme.buttonNormalColor
                    }
                }
                Rectangle {
                    id: columnResizer
                    color: 'transparent'
                    width: 6
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
                                    tableView.model.columns[index].prefferedWidth = headerDlgt.width + sizeOffset
                                    tableView.model.updateColumnProperty()
                                    columnResizeHandler.sizeOffset = 0
                                    tableView.forceLayout()
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
            id: tableView

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
            focus: true
            reuseItems: false
            Keys.onUpPressed: this.selectionModel.moveSelectionVertical(-1)
            Keys.onDownPressed: this.selectionModel.moveSelectionVertical(1)
            Keys.onEnterPressed: this.loadSelectedTrackIntoNextAvailableDeck(false)
            Keys.onReturnPressed: this.loadSelectedTrackIntoNextAvailableDeck(false)
            columnWidthProvider: function(column) {
                const columnDef = tableView.model.columns[column]
                if (columnDef.hidden) {
                    return 0;
                }
                if (columnDef.prefferedWidth >= 0) {
                    return columnDef.prefferedWidth;
                } else {
                    const span = columnDef.fillSpan || 1;
                    return span * (tableView.width - tableView.model.usedWidth) / tableView.model.dynamicColumnCount;
                }
            }

            model: Mixxx.TableFromListModel {
                sourceModel: Mixxx.Library.model

                property int dynamicColumnCount: 0
                property int usedWidth: 0

                Mixxx.TableFromListModelColumn {
                    id: colorColumnModel

                    readonly property string columnName: "Color"
                    property bool hidden: false
                    property int fillSpan: 0
                    property int prefferedWidth: 30

                    decoration: "color"
                    edit: "fileUrl"
                }

                Mixxx.TableFromListModelColumn {
                    id: coverColumnModel

                    readonly property string columnName: "Cover"
                    property bool hidden: false
                    property int fillSpan: 0
                    property int prefferedWidth: 50

                    display: "coverArtUrl"
                    decoration: "coverArtColor"
                    edit: "fileUrl"
                }

                Mixxx.TableFromListModelColumn {
                    readonly property string columnName: "Title"
                    property bool hidden: false
                    property int fillSpan: 3
                    property int prefferedWidth: -1

                    display: "title"
                    edit: "fileUrl"
                }

                Mixxx.TableFromListModelColumn {
                    readonly property string columnName: "Artist"
                    property bool hidden: false
                    property int fillSpan: 2
                    property int prefferedWidth: -1

                    display: "artist"
                    edit: "fileUrl"
                }

                Mixxx.TableFromListModelColumn {
                    readonly property string columnName: "Album"
                    property bool hidden: false
                    property int fillSpan: 1
                    property int prefferedWidth: -1

                    display: "album"
                    edit: "fileUrl"
                }

                Mixxx.TableFromListModelColumn {
                    readonly property string columnName: "Year"
                    property bool hidden: false
                    property int fillSpan: 0
                    property int prefferedWidth: 80

                    display: "year"
                    edit: "fileUrl"
                }

                Mixxx.TableFromListModelColumn {
                    readonly property string columnName: "Bpm"
                    property bool hidden: false
                    property int fillSpan: 0
                    property int prefferedWidth: 60

                    display: "bpm"
                    edit: "fileUrl"
                }

                Mixxx.TableFromListModelColumn {
                    readonly property string columnName: "Key"
                    property bool hidden: false
                    property int fillSpan: 0
                    property int prefferedWidth: 70

                    display: "key"
                    edit: "fileUrl"
                }

                Mixxx.TableFromListModelColumn {
                    readonly property string columnName: "File Type"
                    property bool hidden: false
                    property int fillSpan: 0
                    property int prefferedWidth: 70

                    display: "fileType"
                    edit: "fileUrl"
                }

                Mixxx.TableFromListModelColumn {
                    id: bitrateColumModel
                    readonly property string columnName: "Bitrate"
                    property bool hidden: false
                    property int fillSpan: 0
                    property int prefferedWidth: 70

                    display: "bitrate"
                    edit: "fileUrl"
                }

                Component.onCompleted: updateColumnProperty()

                function updateColumnProperty() {
                    usedWidth = 0;
                    dynamicColumnCount = 0;
                    for (let c = 0; c < tableView.model.columns.length; c++) {
                        if (tableView.model.columns[c].hidden) {
                            continue
                        } else if (tableView.model.columns[c].prefferedWidth > 0) {
                            usedWidth += tableView.model.columns[c].prefferedWidth;
                        } else {
                            dynamicColumnCount += tableView.model.columns[c].fillSpan || 1
                        }
                    }
                }

                function indexOfColumn(column) {
                    for (let c = 0; c < tableView.model.columns.length; c++) {
                        if (tableView.model.columns[c] == column) return c;
                    }
                    return -1
                }
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
                            return this.model.sourceModel.get(index.row).fileUrl;
                    });
                }

                model: tableView.model
            }

            delegate: DelegateChooser {
                DelegateChoice {
                    column: 0

                    Rectangle {
                        id: trackColorDelegate

                        required property bool selected
                        required property color decoration

                        implicitHeight: 30
                        color: trackColorDelegate.decoration
                    }
                }

                DelegateChoice {
                    column: 1

                    Rectangle {
                        id: coverArtDelegate

                        required property color decoration
                        required property url display

                        implicitHeight: 30
                        color: coverArtDelegate.decoration

                        Image {
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectCrop
                            source: coverArtDelegate.display
                            clip: true
                            asynchronous: true
                        }
                    }
                }

                DelegateChoice {
                    Rectangle {
                        id: itemDelegate

                        required property int row
                        required property bool selected
                        required property string display

                        color: selected ? '#2c454f' : (row % 2 == 0 ? 'transparent' : '#0a0a0a')

                        implicitHeight: 30

                        Text {
                            anchors.fill: parent
                            text: itemDelegate.display
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                            color: itemDelegate.selected ? Theme.white : '#e7eaeb'
                        }

                        Image {
                            id: dragItem

                            Drag.active: dragArea.drag.active
                            Drag.dragType: Drag.Automatic
                            Drag.supportedActions: Qt.CopyAction
                            Drag.mimeData: {
                                "text/uri-list": edit,
                                "text/plain": edit
                            }
                            anchors.fill: parent
                        }

                        MouseArea {
                            id: dragArea

                            anchors.fill: parent
                            drag.target: dragItem
                            onPressed: {
                                tableView.selectionModel.selectRow(itemDelegate.row);
                                parent.grabToImage((result) => {
                                        dragItem.Drag.imageSource = result.url;
                                });
                            }
                            onDoubleClicked: {
                                tableView.selectionModel.selectRow(itemDelegate.row);
                                tableView.loadSelectedTrackIntoNextAvailableDeck(false);
                            }
                        }
                    }
                }
            }
        }
    }
}
