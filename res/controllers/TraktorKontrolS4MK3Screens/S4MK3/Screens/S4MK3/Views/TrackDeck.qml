import QtQuick 2.5
import QtQuick.Layouts 1.1
import '../../../' as CSI
import '../Waveform' as WF
import '../Overlays' as Overlays

import '../Widgets' as Widgets

//----------------------------------------------------------------------------------------------------------------------
//  Track Screen View - UI of the screen for track
//----------------------------------------------------------------------------------------------------------------------

Item {
    id: display
    Dimensions {id: dimensions}

  // MODEL PROPERTIES //
    property var deckInfo: ({})
    property int deckId: 1
    property real boxesRadius: dimensions.cornerRadius
    property real infoBoxesWidth: dimensions.infoBoxesWidth +4
    property real firstRowHeight: dimensions.firstRowHeight
    property real secondRowHeight: dimensions.secondRowHeight
    property real spacing: dimensions.spacing-3
    property real screenTopMargin: dimensions.screenTopMargin
    property real screenLeftMargin: dimensions.screenLeftMargin-2

    width: 320
    height: 240

    Rectangle {
        id: displayBackground
        anchors.fill: parent
        color: settings.enableLogo ? settings.backgroundColour : colors.defaultBackground
    }

    Image {
        id: emptyTrackDeckImage
        anchors.fill: parent
        anchors.bottomMargin: settings.bottom
        anchors.topMargin: settings.top
        visible: deckInfo.showLogo && settings.enableLogo

        source: engine.getSetting("idleBackground") == "mask" ? "../../Images/logo.png" : "../../../../../../images/templates/logo_mixxx.png"
        fillMode: Image.PreserveAspectFit
    }

    ColumnLayout {
        id: content
        spacing: display.spacing

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: display.screenTopMargin
        anchors.leftMargin: display.screenLeftMargin

	// FIRST ROW //
        RowLayout {
            id: firstRow

            spacing: 1

		// DECK HEADER //
            Widgets.DeckHeader {
                id: deckHeader

                title: deckInfo.headerEnabled ? deckInfo.headerTextShort : deckInfo.titleString
                artist: deckInfo.headerEnabled ? deckInfo.headerTextLong : deckInfo.artistString

                height: display.firstRowHeight-6
                width: deckInfo.headerEnabled ? 4*(display.infoBoxesWidth/2+1)+1 : 3*(display.infoBoxesWidth/2+1)+3
            }

	  // TIME DISPLAY //
            Item {
                id: timeBox2
                width: (display.infoBoxesWidth/2+1)
                height: display.firstRowHeight-6

                Rectangle {
                    anchors.fill: parent
                    color: trackEndBlinkTimer2.blink ? colors.colorRed : colors.colorDeckGrey
                    radius: display.boxesRadius
                    visible: !deckInfo.headerEnabled
                }

                Text {
                    text: settings.timeBox == 0 ? deckInfo.remainingTimeString : settings.timeBox == 1 ? deckInfo.elapsedTimeString : settings.timeBox == 2 ? deckInfo.timeToCue : settings.timeBox == 3 ? deckInfo.beats : settings.timeBox == 4 ? deckInfo.beatsAlt : settings.timeBox == 5 ? deckInfo.beatsToCue : settings.timeBox == 6 ? deckInfo.beatsToCueAlt : deckInfo.remainingTimeString
                    font.pixelSize: 22
                    font.family: "Roboto"
                    font.weight: Font.Medium
                    color: settings.timeTextColourChange && trackEndBlinkTimer2.blink ? "black" : "white"
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    visible: !deckInfo.shift && !deckInfo.headerEnabled
                }

                Text {
                    text: settings.timeBoxShift == 0 ? deckInfo.remainingTimeString : settings.timeBoxShift == 1 ? deckInfo.elapsedTimeString : settings.timeBoxShift == 2 ? deckInfo.timeToCue : settings.timeBoxShift == 3 ? deckInfo.beats : settings.timeBoxShift == 4 ? deckInfo.beatsAlt : settings.timeBoxShift == 5 ? deckInfo.beatsToCue : settings.timeBoxShift == 6 ? deckInfo.beatsToCueAlt : deckInfo.remainingTimeString
                    font.pixelSize: 22
                    font.family: "Roboto"
                    font.weight: Font.Medium
                    color: settings.timeTextColourChange && trackEndBlinkTimer2.blink ? "black" : "white"
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    visible: deckInfo.shift && !deckInfo.headerEnabled
                }

                Timer {
                    id: trackEndBlinkTimer2
                    property bool blink: false

                    interval: 500
                    repeat: true
                    running: deckInfo.trackEndWarning

                    onTriggered: {
                        blink = !blink;
                    }

                    onRunningChanged: {
                        blink = running;
                    }
                }
            }
        }

    // PHASE METER //
        Widgets.PhaseMeter {
            id: phase
            height: settings.hidePhase ? 0 : 16
            width: 317
    //   anchors.left: parent.left
	  // anchors.top: phrase.bottom
	  // anchors.topMargin: 0
            visible: deckInfo.isLoaded

            phase: deckInfo.phase
        }

	// PHRASE METER //
        Widgets.PhraseMeter {
            id: phrase
            height: settings.hidePhrase ? 0 : 16
            width: 317
    //   anchors.left: parent.left
	  // anchors.top: firstRow.bottom
	  // anchors.topMargin: 0

            deck: deckInfo.beatSingle
            master: deckInfo.masterBeatSingle
            deckId: deckInfo.deckId
            masterId: deckInfo.masterDeck
            visible: deckInfo.isLoaded
        }

	//WAVEFORM

        property string deckSizeState: "large"
        readonly property int waveformHeight: 129
        property bool isInEditMode: false
        property bool showLoopSize: true
        property string propertiesPath: ""

        WF.WaveformContainer {
            id: waveformContainer

            deckId: deckInfo.deckId
            deckSizeState: content.deckSizeState
            propertiesPath: content.propertiesPath

      // anchors.left:         parent.left
            width: 316
      // anchors.top:		  phase.bottom
            showLoopSize: content.showLoopSize
            isInEditMode: content.isInEditMode

      // the height of the waveform is defined as the remaining space of deckHeight - stripe.height - spacerWaveStripe.height
            height: (settings.alwaysShowTempoInfo || deckInfo.adjustEnabled ? (settings.hideStripe ? content.waveformHeight + display.secondRowHeight-51 : content.waveformHeight-38) : (!deckInfo.showBPMInfo ? (settings.hideStripe ? content.waveformHeight + display.secondRowHeight-13 : content.waveformHeight) : (settings.hideStripe ? content.waveformHeight + display.secondRowHeight-51 : content.waveformHeight-38))) + (settings.hidePhase && settings.hidePhrase ? 16 : 0) + (!settings.hidePhase && !settings.hidePhrase ? -16 : 0)
            visible: deckInfo.isLoaded && !settings.hideWaveforms

            Behavior on height { PropertyAnimation { duration: 90} }
        }
    }

    WF.WaveformOverview {
    // color: "green"
        height: settings.hideWaveforms ? 150 : display.secondRowHeight-13
        width: 314
        anchors.left: parent.left
        anchors.leftMargin: 6
        anchors.top: display.top
        anchors.topMargin: settings.hideWaveforms ? 90 : 178
    }

    // STRIPE //
    // Widgets.Stripe
    // {

    //   deckId:  deckInfo.deckId - 1 // stripe uses zero based indices.
    //   visible: settings.shiftStripe ? (!deckInfo.shift && deckInfo.isLoaded ? (settings.hideStripe == true ? false : true) : false) : (deckInfo.isLoaded ? (settings.hideStripe == true ? false : true) : false)

    //   // we apply -3 on the height and +3 on the topMargin,
    //   //because Widgets.Stripes has elements (the cues) that are
    //   //not taken into the height of the Stripe. They are 3pix outside
    //   //of the stripe.
    //   height : settings.hideWaveforms ? 150 : display.secondRowHeight-13
    //   width: 314
    //   anchors.left: parent.left
	  // anchors.leftMargin: 6
	  // anchors.top: display.top
	  // anchors.topMargin: settings.hideWaveforms ? 90 : 178

    //   hotcuesModel: deckInfo.hotcues
    //   trackLength:  deckInfo.trackLength
    //   elapsedTime:  deckInfo.elapsedTime
    //   audioStreamKey: ["PrimaryKey", deckInfo.primaryKey]
    // }

	// STRIPE //
    // Widgets.Stripe
    // {
    //   deckId:  (deckInfo.deckId == 1 ? 2 : (deckInfo.deckId == 2 ? 3 : (deckInfo.deckId == 3 ? 0 : (deckInfo.deckId == 4 ? 1 : (5)))))
    //   visible: deckInfo.shift && settings.shiftStripe && !settings.shiftStripeMaster ? (settings.hideStripe == true ? false : true) : false

    //   // we apply -3 on the height and +3 on the topMargin,
    //   //because Widgets.Stripes has elements (the cues) that are
    //   //not taken into the height of the Stripe. They are 3pix outside
    //   //of the stripe.
    //   height: settings.hideWaveforms ? 150 : display.secondRowHeight-13
    //   width: 314
    //   anchors.left: parent.left
	  // anchors.leftMargin: 6
	  // anchors.top: display.top
	  // anchors.topMargin: settings.hideWaveforms ? 90 : 178

    //   hotcuesModel:  (deckInfo.deckId == 1 ? deckInfo.hotcues3 : (deckInfo.deckId == 2 ? deckInfo.hotcues4 : (deckInfo.deckId == 3 ? deckInfo.hotcues1 : (deckInfo.deckId == 4 ? deckInfo.hotcues2 : (deckInfo.hotcues)))))
    //   trackLength:   (deckInfo.deckId == 1 ? deckInfo.trackLength3 : (deckInfo.deckId == 2 ? deckInfo.trackLength4 : (deckInfo.deckId == 3 ? deckInfo.trackLength1 : (deckInfo.deckId == 4 ? deckInfo.trackLength2 : (deckInfo.trackLength)))))
    //   elapsedTime:   (deckInfo.deckId == 1 ? deckInfo.elapsedTime3 : (deckInfo.deckId == 2 ? deckInfo.elapsedTime4 : (deckInfo.deckId == 3 ? deckInfo.elapsedTime1 : (deckInfo.deckId == 4 ? deckInfo.elapsedTime2 : (deckInfo.hotcues)))))
    //   audioStreamKey:(deckInfo.deckId == 1 ? ["PrimaryKey", deckInfo.primaryKey3] : (deckInfo.deckId == 2 ? ["PrimaryKey", deckInfo.primaryKey4] : (deckInfo.deckId == 3 ? ["PrimaryKey", deckInfo.primaryKey1] : (deckInfo.deckId == 4 ? ["PrimaryKey", deckInfo.primaryKey2] : (["PrimaryKey", deckInfo.primaryKey])))))
    // }

	// STRIPE //
    // Widgets.Stripe
    // {
    //   deckId:  (deckInfo.masterDeck == 1) ? "0" : ((deckInfo.masterDeck == 2) ? "1" : ((deckInfo.masterDeck == 3) ? "2" : ((deckInfo.masterDeck == 4) ? "3" : ""))) // stripe uses zero based indices.
    //   visible: deckInfo.shift && settings.shiftStripe && settings.shiftStripeMaster ? (settings.hideStripe == true ? false : true) : false

    //   // we apply -3 on the height and +3 on the topMargin,
    //   //because Widgets.Stripes has elements (the cues) that are
    //   //not taken into the height of the Stripe. They are 3pix outside
    //   //of the stripe.
    //   height: settings.hideWaveforms ? 150 : display.secondRowHeight-13
    //   width: 314
    //   anchors.left: parent.left
	  // anchors.leftMargin: 6
	  // anchors.top: display.top
	  // anchors.topMargin: settings.hideWaveforms ? 90 : 178

    //   hotcuesModel:  deckInfo.hotcuesMaster
    //   trackLength:   deckInfo.trackLengthMaster
    //   elapsedTime:   deckInfo.elapsedTimeMaster
    //   audioStreamKey:  ["PrimaryKey", deckInfo.primaryKeyMaster]
    // }

    Overlays.TopControls {
        id: fx1
        fxUnit: 0
        showHideState: (deckInfo.showFx1 && settings.fxOverlays) || (!settings.hideOverlayInRemixPads ? (deckInfo.padsModeFx1 && (settings.fx1unit == 1)) : false) || (!settings.hideOverlayInRemixPads ? (deckInfo.padsModeFx2 && (settings.fx2unit == 1)) : false) ? "show" : "hide"
    }

    Overlays.TopControls {
        id: fx2
        fxUnit: 1
        showHideState: deckInfo.showFx2 && settings.fxOverlays || (!settings.hideOverlayInRemixPads ? (deckInfo.padsModeFx1 && (settings.fx1unit == 2)) : false) || (!settings.hideOverlayInRemixPads ? (deckInfo.padsModeFx2 && (settings.fx2unit == 2)) : false) ? "show" : "hide"
    }

    Overlays.TopControls {
        id: fx3
        fxUnit: 2
        showHideState: deckInfo.showFx3 && settings.fxOverlays || (!settings.hideOverlayInRemixPads ? (deckInfo.padsModeFx1 && (settings.fx1unit == 3)) : false) || (!settings.hideOverlayInRemixPads ? (deckInfo.padsModeFx2 && (settings.fx2unit == 3)) : false) ? "show" : "hide"
    }

    Overlays.TopControls {
        id: fx4
        fxUnit: 3
        showHideState: !deckInfo.breakEnabled && (deckInfo.showFx4 && settings.fxOverlays || (!settings.hideOverlayInRemixPads ? (deckInfo.padsModeFx1 && (!settings.fx1unit == 4)) : false) || (settings.hideOverlayInRemixPads ? (deckInfo.padsModeFx2 && (settings.fx2unit == 4)) : false)) ? "show" : "hide"
    }

    Overlays.BreakControls {
        id: breakFX
        fxUnit: 3
        showHideState: !deckInfo.adjustEnabled && deckInfo.breakEnabled && settings.fxOverlays ? "show" : "hide"
    }

    Widgets.TempoAdjust {
        id: tempoInfo
        deckId: deckInfo.deckId
        height: 38
        y: settings.hideStripe ? 197 : 140
        visible: (deckInfo.isLoaded ? (settings.alwaysShowTempoInfo || deckInfo.adjustEnabled ? true : deckInfo.showBPMInfo) : false) && !settings.hideWaveforms
    }

    Widgets.TempoAdjust {
        id: tempoInfo2
        deckId: deckInfo.deckId
        height: 38
        y: 50
        visible: settings.hideWaveforms
    }
}
