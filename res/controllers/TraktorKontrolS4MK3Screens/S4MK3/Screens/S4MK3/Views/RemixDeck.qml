import QtQuick 2.5
import QtQuick.Layouts 1.1
import '../Widgets' as Widgets
import '../Overlays' as Overlays

//----------------------------------------------------------------------------------------------------------------------
//  Remix Deck View - UI of the screen for remix decks
//----------------------------------------------------------------------------------------------------------------------

Item {
    id: display
    Colors {id: colors}
    Dimensions {id: dimensions}

  // MODEL PROPERTIES //
    property var deckInfo: ({})

    width: 320
    height: 240

  // LAYOUT + DESIGN //
    property color timeColor: colors.defaultTextColor

    property real infoBoxesWidth: dimensions.infoBoxesWidth
    property real firstRowHeight: dimensions.firstRowHeight
    property real secondRowHeight: dimensions.secondRowHeight
    property real remixCellWidth: dimensions.thirdRowHeight
    property real screenTopMargin: dimensions.screenTopMargin
    property real screenLeftMargin: dimensions.screenLeftMargin

    property real boxesRadius: 5
    property real cellSpacing: dimensions.spacing
    property real textMargin: 13

    property variant lightGray: colors.colorDeckGrey
    property variant darkGray: colors.colorDeckDarkGrey

    Rectangle {
        id: background
        color: colors.defaultBackground
        anchors.fill: parent
    }

    ColumnLayout {
        spacing: display.cellSpacing
        anchors.top: parent.top
        anchors.topMargin: display.screenTopMargin
        anchors.left: parent.left
        anchors.leftMargin: display.screenLeftMargin

        RowLayout {
            spacing: display.cellSpacing

    // DECK HEADER //
    // Widgets.DeckHeader
    // {
    //   id: deckHeader

    //   height: display.firstRowHeight
    //   width:  2*display.infoBoxesWidth + display.cellSpacing - 30
    //   title:  deckInfo.titleString

    //   backgroundColor: deckInfo.isSequencerRecOn ? colors.colorRed : colors.defaultBackground
    //   visible: (deckInfo.remixActiveSlot > 0 && !deckInfo.remixSampleBrowsing) ? false : true
    // }

      //SOURCE DISPLAY//
            Rectangle {
                id: sourceBox

                height: display.firstRowHeight
                width: 25

                border.width: 1
                color: (deckInfo.remixActiveSlot > 0 && !deckInfo.remixSampleBrowsing) ? "black" : deckInfo.shift ? display.lightGray : display.darkGray
                radius: display.boxesRadius

                Text {
                    text: deckInfo.sourceString
                    font.pixelSize: 24
                    font.family: "Roboto"
                    font.weight: Font.Normal
                    color: (deckInfo.remixActiveSlot > 0 && !deckInfo.remixSampleBrowsing) ? "black" : "white"
                    anchors.fill: parent
                    anchors.leftMargin: display.textMargin
                    anchors.rightMargin: display.textMargin
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        RowLayout {
            spacing: display.cellSpacing

      // BPM DISPLAY //
            Rectangle {
                id: bpmBox

                height: display.firstRowHeight
                width: display.infoBoxesWidth

                border.width: 1
                border.color: (deckInfo.remixActiveSlot > 0 && !deckInfo.remixSampleBrowsing) ? "black" : display.darkGray
                color: "black"
                radius: display.boxesRadius

                Text {
                    text: deckInfo.bpmString
                    font.pixelSize: 24
                    font.family: "Roboto"
                    font.weight: Font.Normal
                    color: (deckInfo.remixActiveSlot > 0 && !deckInfo.remixSampleBrowsing) ? "black" : "white"
                    anchors.fill: parent
                    anchors.leftMargin: display.textMargin
                    anchors.rightMargin: display.textMargin
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

      // Quant*** DISPLAY //
            Rectangle {
                id: quant

                height: display.firstRowHeight
                width: display.infoBoxesWidth

                color: (deckInfo.remixActiveSlot > 0 && !deckInfo.remixSampleBrowsing) ? "black" : deckInfo.shift ? display.lightGray : display.darkGray
                radius: display.boxesRadius

                Text {
                    id: quantText
                    text: deckInfo.rmxQuantizeIndex
                    font.pixelSize: 24
                    font.family: "Roboto"
                    font.weight: Font.Normal
                    color: (deckInfo.remixActiveSlot > 0 && !deckInfo.remixSampleBrowsing) ? "black" : "white"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

        //quantization of/off display (circle)
                Text {
                    visible: deckInfo.rmxQuantizeOn
                    text: "\u25CF"
                    font.pixelSize: 24
                    font.family: "Roboto"
                    font.weight: Font.Normal
                    color: (deckInfo.remixActiveSlot > 0 && !deckInfo.remixSampleBrowsing) ? "black" : colors.hotcue.hotcue
                    anchors.left: quantText.right
                    anchors.leftMargin: 3
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        RowLayout {
            spacing: display.cellSpacing

      // BEAT POSITION DISPLAY //
            Item {
                id: beatPosition
                width: display.infoBoxesWidth
                height: display.secondRowHeight

                Rectangle {
                    anchors.fill: parent
                    color: (deckInfo.remixActiveSlot > 0 && !deckInfo.remixSampleBrowsing) ? "black" : colors.grayBackground
                    radius: display.boxesRadius
                }

                Text {
                    text: deckInfo.beatPositionString
                    font.pixelSize: 45
                    font.family: "Roboto"
                    font.weight: Font.Medium
                    color: (deckInfo.remixActiveSlot > 0 && !deckInfo.remixSampleBrowsing) ? "black" : "white"
                    anchors.fill: parent
                    anchors.leftMargin: display.textMargin
                    anchors.rightMargin: display.textMargin
                    fontSizeMode: Text.HorizontalFit
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

      // LOOP DISPLAY //
            Item {
                id: loopBox
                width: display.infoBoxesWidth
                height: display.secondRowHeight

                Rectangle {
                    anchors.fill: parent
                    color: (deckInfo.remixActiveSlot > 0 && !deckInfo.remixSampleBrowsing) ? "black" : deckInfo.loopActive ? (deckInfo.shift ? colors.loopActiveDimmedColor : colors.loopActiveColor ) : (deckInfo.shift ? display.darkGray : display.lightGray)
                    radius: display.boxesRadius
                }

                Text {
                    text: deckInfo.loopSizeString
                    font.pixelSize: 45
                    font.family: "Roboto"
                    font.weight: Font.Medium
                    color: (deckInfo.remixActiveSlot > 0 && !deckInfo.remixSampleBrowsing) ? "black" : deckInfo.loopActive ? "black" : colors.defaultTextColor
                    anchors.fill: parent
                    anchors.leftMargin: display.textMargin
                    anchors.rightMargin: display.textMargin
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

    // LOOP DISPLAY //
        Row {
            spacing: display.cellSpacing

            Repeater {
                model: deckInfo.slots
                Widgets.RemixCell {
            //store activeCell locally so that we don't have to
            //fetch it every time
                    property var activeCell: modelData.getActiveCell();

                    deckInfo 					: display.deckInfo
                    cellColor: activeCell.color
                    isLoop: activeCell.isLooped
                    cellRadius: display.boxesRadius
                    cellSize: display.remixCellWidth
                    withIcon: !activeCell.isEmpty
                }
            }
        }
    }

    Widgets.RemixOverlay {
        id: remixOverlay
        deckInfo: display.deckInfo
        anchors.top: parent.top
        anchors.left: parent.left
        deckId: deckInfo.deckId
        slotId: deckInfo.remixActiveSlot > 0 ? deckInfo.remixActiveSlot : 1
        visible: deckInfo.remixActiveSlot > 0 && !deckInfo.remixSampleBrowsing
    }

    Widgets.RemixBrowsingOverlay {
        id: remixBrowsingOverlay
        deckInfo: display.deckInfo
        anchors.top: parent.top
        anchors.left: parent.left
        slotId: deckInfo.remixActiveSlot > 0 ? deckInfo.remixActiveSlot : 1
        visible: deckInfo.remixActiveSlot > 0 && deckInfo.remixSampleBrowsing
    }

    Overlays.TopControls {
        id: fx1
        fxUnit: 0
        showHideState: deckInfo.showFx1 && settings.fxOverlays ? "show" : "hide"
    }

    Overlays.TopControls {
        id: fx2
        fxUnit: 1
        showHideState: deckInfo.showFx2 && settings.fxOverlays ? "show" : "hide"
    }

    Overlays.TopControls {
        id: fx3
        fxUnit: 2
        showHideState: deckInfo.showFx3 && settings.fxOverlays ? "show" : "hide"
    }

    Overlays.TopControls {
        id: fx4
        fxUnit: 3
        showHideState: deckInfo.showFx4 && settings.fxOverlays ? "show" : "hide"
    }

    function isLeftScreen() {
        return deckInfo.deckId == 1 || deckInfo.deckId == 3;
    }
}
