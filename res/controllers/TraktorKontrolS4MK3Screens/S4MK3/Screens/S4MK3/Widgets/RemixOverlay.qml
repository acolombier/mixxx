import QtQuick 2.5
import QtQuick.Layouts 1.1
import '../Views'

//----------------------------------------------------------------------------------------------------------------------
//  Remix Deck Overlay - for sample volume and filter value editing
//----------------------------------------------------------------------------------------------------------------------

Item {
    id: display
    Colors {id: colors}
    Dimensions {id: dimensions}

  // MODEL PROPERTIES //
    property var deckInfo: ({})
    property int slotId: 1 //should be always a valid slot
    property int deckId: 1

  // fetch data
    property var slot: deckInfo.getSlot(slotId)
    property var activeCellIdx: slot.activeCellIdx
    property var activeCell: slot.getCell(activeCellIdx)

    width: 320
    height: 240

  // LAYOUT + DESIGN //

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

    DeckHeader {
        id: header
        anchors.top: parent.top
        anchors.topMargin: display.screenTopMargin
        anchors.left: parent.left
        anchors.leftMargin: display.screenLeftMargin

        title: display.activeCell.name
        height: display.firstRowHeight
        width: 2*display.infoBoxesWidth + display.cellSpacing - 90
    }

    Rectangle {
        id: keylockLabel
        anchors.top: parent.top
        anchors.topMargin: display.screenTopMargin
        anchors.left: header.right
        anchors.leftMargin: display.screenLeftMargin

        height: display.firstRowHeight
        width: 40

        color: deckInfo.remixLock == true ? !display.slot.muted ? display.activeCell.midColor : colors.darkerColor(display.activeCell.midColor, 0.5) : colors.colorDeckDarkGrey
        radius: display.boxesRadius

        Text {
            id: keylockText
            text: "Key"
            font.pixelSize: 24
            font.family: "Roboto"
            font.weight: Font.Normal
            color: !display.slot.muted ? "white" : "grey"
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    Rectangle {
        id: fxLabel
        anchors.top: parent.top
        anchors.topMargin: display.screenTopMargin
        anchors.left: keylockLabel.right
        anchors.leftMargin: display.screenLeftMargin

        height: display.firstRowHeight
        width: 40

        color: deckInfo.remixFx == true ? !display.slot.muted ? display.activeCell.midColor : colors.darkerColor(display.activeCell.midColor, 0.5) : colors.colorDeckDarkGrey
        radius: display.boxesRadius

        Text {
            id: fxText
            text: "FX"
            font.pixelSize: 24
            font.family: "Roboto"
            font.weight: Font.Normal
            color: !display.slot.muted ? "white" : "grey"
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

      // VOLUME LABEL //
    Rectangle {
        id: volumeLabel
        anchors.top: header.bottom
        anchors.topMargin: display.screenTopMargin
        anchors.left: parent.left
        anchors.leftMargin: display.screenLeftMargin

        height: display.firstRowHeight
        width: display.infoBoxesWidth

        color: !display.slot.muted ? display.activeCell.midColor : colors.darkerColor(display.activeCell.midColor, 0.5)
        radius: display.boxesRadius

        Text {
            text: "Volume"
            font.pixelSize: 24
            font.family: "Roboto"
            font.weight: Font.Normal
            color: !display.slot.muted ? "white" : "grey"
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

      // FILTER LABEL //
    Rectangle {

        id: filterLabel
        anchors.top: header.bottom
        anchors.topMargin: display.screenTopMargin
        anchors.left: volumeLabel.right
        anchors.leftMargin: 6

        height: display.firstRowHeight
        width: display.infoBoxesWidth

        color: display.slot.filterOn ? display.activeCell.midColor : colors.darkerColor(display.activeCell.midColor, 0.5)
        radius: display.boxesRadius

        Text {
            text: "Filter"
            font.pixelSize: 24
            font.family: "Roboto"
            font.weight: Font.Normal
            color: display.slot.filterOn ? "white" : "grey"
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: display.textMargin
            anchors.leftMargin: display.textMargin
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

      // VOLUME SLIDER //
    Slider {
        id: volumeSlider
        anchors.top: volumeLabel.bottom
        anchors.topMargin: -5
        anchors.left: parent.left
        anchors.leftMargin: display.screenLeftMargin
        radius: display.boxesRadius

        width: display.infoBoxesWidth
        height: 25
        min: 0
        max: 1
        value: display.slot.volume

        backgroundColor: !display.slot.muted ? display.activeCell.midColor : colors.darkerColor(display.activeCell.midColor, 0.5)
        sliderColor: !display.slot.muted ? display.activeCell.brightColor : display.activeCell.midColor
        cursorColor: !display.slot.muted ? "white" : "grey"
    }

      // FILTER SLIDER //
    Slider {
        id: filterSlider
        anchors.top: filterLabel.bottom
        anchors.topMargin: -5
        anchors.left: volumeSlider.right
        anchors.leftMargin: 6
        radius: display.boxesRadius

        width: display.infoBoxesWidth
        height: 25

        value: display.slot.filterValue
        min: 0
        max: 1
        centered: true

        backgroundColor: display.slot.filterOn ? display.activeCell.midColor : colors.darkerColor(display.activeCell.midColor, 0.5)
        sliderColor: display.slot.filterOn ? display.activeCell.brightColor : display.activeCell.midColor
        cursorColor: display.slot.filterOn ? "white" : "grey"
        centerColor: colors.defaultBackground
    }

    Rectangle {
        id: gainLabel
        anchors.top: volumeSlider.bottom
        anchors.topMargin: 6
        anchors.left: parent.left
        anchors.leftMargin: display.screenLeftMargin

        height: display.firstRowHeight
        width: display.infoBoxesWidth

        color: !display.slot.muted ? display.activeCell.midColor : colors.darkerColor(display.activeCell.midColor, 0.5)
        radius: display.boxesRadius

        Text {
            text: "Gain"
            font.pixelSize: 24
            font.family: "Roboto"
            font.weight: Font.Normal
            color: !display.slot.muted ? "white" : "grey"
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    Slider {
        id: gainSlider
        anchors.top: pitchLabel.bottom
        anchors.topMargin: -5
        anchors.left: display.left
        anchors.leftMargin: 6
        radius: display.boxesRadius

        width: display.infoBoxesWidth
        height: 25

        value: (deckInfo.remixGain)
        min: 0
        max: 1
        centered: false

        backgroundColor: display.slot.filterOn ? display.activeCell.midColor : colors.darkerColor(display.activeCell.midColor, 0.5)
        sliderColor: display.slot.filterOn ? display.activeCell.brightColor : display.activeCell.midColor
        cursorColor: display.slot.filterOn ? "white" : "grey"
        centerColor: colors.defaultBackground
    }

    Rectangle {
        id: pitchLabel
        anchors.top: volumeSlider.bottom
        anchors.topMargin: 6
        anchors.left: volumeSlider.right
        anchors.leftMargin: display.screenLeftMargin

        height: display.firstRowHeight
        width: display.infoBoxesWidth

        color: !display.slot.muted ? display.activeCell.midColor : colors.darkerColor(display.activeCell.midColor, 0.5)
        radius: display.boxesRadius

        Text {
            text: "Pitch"
            font.pixelSize: 24
            font.family: "Roboto"
            font.weight: Font.Normal
            color: !display.slot.muted ? "white" : "grey"
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    Slider {
        id: pitchSlider
        anchors.top: pitchLabel.bottom
        anchors.topMargin: -5
        anchors.left: volumeSlider.right
        anchors.leftMargin: display.screenLeftMargin

        radius: display.boxesRadius

        width: display.infoBoxesWidth
        height: 25

        value: (deckInfo.remixPitch+1)
        min: 0
        max: 2
        centered: true

        backgroundColor: display.slot.filterOn ? display.activeCell.midColor : colors.darkerColor(display.activeCell.midColor, 0.5)
        sliderColor: display.slot.filterOn ? display.activeCell.brightColor : display.activeCell.midColor
        cursorColor: display.slot.filterOn ? "white" : "grey"
        centerColor: colors.defaultBackground
    }
}
