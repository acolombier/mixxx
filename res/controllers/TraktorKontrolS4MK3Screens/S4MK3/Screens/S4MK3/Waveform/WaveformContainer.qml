import '../../../' as CSI
import QtQuick 2.15

import '../../../Defines'
import '../../Defines'
import '../Widgets' as Widgets
import '../Overlays' as Overlays

import "../../../../../../qml/" as Skin

Item {
    id: view
    property int deckId: deckInfo.deckId
    property string deckSizeState: "large"
    property bool showLoopSize: false
    property bool isInEditMode: false
    property int	 playmarkerPosition: settings.waveformPlaymarkerPosition
    property string propertiesPath: ""
    property int zoomLevel: deckInfo.zoomLevel
    readonly property int minSampleWidth: 2048
    property int sampleWidth: minSampleWidth << zoomLevel
    property bool hideLoop: false
    property bool hideBPM: false
    property bool hideKey: false

    readonly property bool trackIsLoaded: (primaryKey.value > 0)

    property 			int 	stemStyle: deckInfo.stemSelected
    readonly property bool isStemDeck: (deckType.value == "Stem Deck")

  //--------------------------------------------------------------------------------------------------------------------

  // AppProperty     { id: primaryKey;        path: "app.traktor.decks."   + deckId + ".track.content.entry_key"  }
    QtObject {
        id: primaryKey
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty     { id: sampleRate;        path: "app.traktor.decks."   + deckId + ".track.content.sample_rate"; onValueChanged: { updateLooping(); } }
    QtObject {
        id: sampleRate
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty     { id: propFluxState;     path: "app.traktor.decks."   + deckId + ".flux.state"                 }
    QtObject {
        id: propFluxState
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty     { id: propFluxPosition;  path: "app.traktor.decks."   + deckId + ".track.player.flux_position" }
    QtObject {
        id: propFluxPosition
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }

  // If the playhead is in a loop, propIsLooping is TRUE and the loop becomes the active cue.
  // AppProperty   { id: propIsLooping;     path: "app.traktor.decks." + deckId + ".loop.is_in_active_loop";        onValueChanged: { updateLooping(); } }
    QtObject {
        id: propIsLooping
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty   { id: propLoopStart;     path: "app.traktor.decks." + deckId + ".track.cue.active.start_pos";    onValueChanged: { updateLooping(); } }
    QtObject {
        id: propLoopStart
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty   { id: propLoopLength;    path: "app.traktor.decks." + deckId + ".track.cue.active.length";       onValueChanged: { updateLooping(); } }
    QtObject {
        id: propLoopLength
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
    QtObject {
        id: deckType
        property string description: "Track Deck"
        property var value: 1
        property var valueRange: ({isDiscrete: true, steps: 1})
    }

  //--------------------------------------------------------------------------------------------------------------------
  // WAVEFORM Position
  //------------------------------------------------------------------------------------------------------------------

    function slicer_zoom_width()          { return  slicer.slice_width * slicer.slice_count / slicer.zoom_factor * sampleRate.value;          }
    function slicer_pos_to_waveform_pos() { return (slicer.slice_start - (0.5 * slicer.slice_width * slicer.zoom_factor)) * sampleRate.value; }

    function updateLooping() {
        if (propIsLooping.value) {
            var loopStart  = propLoopStart.value  * sampleRate.value;
            var loopLength = propLoopLength.value * sampleRate.value;
            wfPosition.clampPlayheadPos(loopStart, loopLength);
        }
        else wfPosition.unclampPlayheadPos();
    }

  // T.WaveformPosition {
    // id: wfPosition
  //   deckId: deckInfo.deckId-1
  //   followsPlayhead: !slicer.enabled && !beatgrid.editEnabled
  //   waveformPos:     beatgrid.editEnabled ? beatgrid.posOnEdit   : (slicer.enabled ? slicer_pos_to_waveform_pos() : (playheadPos -  0.5 * view.sampleWidth ))
  //   sampleWidth:     beatgrid.editEnabled ? beatgrid.widthOnEdit : (slicer.enabled ? slicer_zoom_width()          : view.sampleWidth)
  //   viewWidth:       singleWaveform.width

  //   Behavior on sampleWidth { PropertyAnimation { duration: 150; easing.type: Easing.OutCubic } }
  //   Behavior on waveformPos { PropertyAnimation { duration: 0; easing.type: Easing.OutCubic }  enabled: (slicer.enabled || beatgrid.editEnabled) }
  // }

  //--------------------------------------------------------------------------------------------------------------------
  // Single/DAW WAVEFORM
  //------------------------------------------------------------------------------------------------------------------

  // SingleWaveform {
  //   id: singleWaveform
  //   deckId:        view.deckId
  //   sampleWidth:   view.sampleWidth

  //   waveformPosition: wfPosition

  //   anchors.top:   view.top
  //   anchors.left:  view.left
  //   anchors.right: view.right

  //   anchors.leftMargin:   (slicer.enabled) ? 3 : 3 + playmarkerPosition
  //   anchors.rightMargin:  3
  //   anchors.bottomMargin: (slicer.enabled) ? 11 : 0

  //   clip:    true
  //   visible: !isStemDeck
  //   height:  view.height // changed in state

  //   Behavior on anchors.bottomMargin { PropertyAnimation {  duration: durations.deckTransition } }
  // }
    Skin.WaveformRow {
        id: singleWaveform
        group: `[Channel${view.deckId}]`
        x: 0
        width: 316
        // height: (settings.alwaysShowTempoInfo || deckInfo.adjustEnabled ? (settings.hideStripe ? content.waveformHeight + display.secondRowHeight-51 : content.waveformHeight-38) : (!deckInfo.showBPMInfo ? (settings.hideStripe ? content.waveformHeight + display.secondRowHeight-13 : content.waveformHeight) : (settings.hideStripe ? content.waveformHeight + display.secondRowHeight-51 : content.waveformHeight-38))) + (settings.hidePhase && settings.hidePhrase ? 16 : 0) + (!settings.hidePhase && !settings.hidePhrase ? -16 : 0)
        height: 90

        shader.axesColor: 'transparent'

        zoomControlRatio: 100
        Behavior on height { PropertyAnimation { duration: 90} }
      // anchors.left:         parent.left
      // anchors.top:		  phase.bottom
    }

    StemWaveforms {
        id: stemWaveform
        deckId: view.deckId
        sampleWidth: view.sampleWidth

    // waveformPosition: wfPosition

        anchors.top: singleWaveform.bottom
        anchors.left: view.left
        anchors.right: view.right
        anchors.bottom: view.bottom
        anchors.leftMargin: (slicer.enabled) ? 3 : 3 + playmarkerPosition
        anchors.rightMargin: 3
        anchors.bottomMargin: (isStemDeck & slicer.enabled) ? 15 : 0

        visible: isStemDeck

        Behavior on anchors.bottomMargin { PropertyAnimation { duration: durations.deckTransition } }
    }

  //--------------------------------------------------------------------------------------------------------------------
  //  Beatgrid
  //--------------------------------------------------------------------------------------------------------------------

  // BeatgridView {
  //   id: beatgrid
  //   anchors.fill:  parent
  //   anchors.leftMargin:  3 + playmarkerPosition
  //   anchors.rightMargin: 3

    // waveformPosition: wfPosition
  //   propertiesPath:   view.propertiesPath
  //   trackId:          primaryKey.value
  //   deckId:           parent.deckId-1
  //   visible:          settings.hideBeatgrid ? false : (!slicer.enabled || beatgrid.editEnabled)
  //   editEnabled:      view.isInEditMode && (deckSizeState != "small")
  //   clip: true
  // }

  //--------------------------------------------------------------------------------------------------------------------
  //  CuePoints
  //--------------------------------------------------------------------------------------------------------------------

  // WaveformCues {
  //   id: waveformCues
  //   anchors.fill: parent
  //   anchors.leftMargin:  3 + playmarkerPosition
  //   anchors.rightMargin: 3

  //   deckId:            view.deckId
  //   waveformPosition:  wfPosition
  //   forceHideLoop:     slicer.enabled || !trackIsLoaded
  // }

  //--------------------------------------------------------------------------------------------------------------------
  // Freeze/Slicer
  //--------------------------------------------------------------------------------------------------------------------

    Slicer {
        id: slicer
        anchors.fill: parent
        anchors.leftMargin: 3
        anchors.rightMargin: 3
        anchors.topMargin: 1
        deckId: view.deckId
    // opacity:           (beatgrid.editEnabled) ? 0 : 1
    }

  // T.WaveformTranslator {
  //   Rectangle {
  //     x:	slicer.enabled ? 0 : playmarkerPosition
  //     id: flux_marker
	//   y:      -4
  //     width: 3; height: view.height
  //     color:        colors.colorBluePlaymarker
  //     border.color: colors.colorBlack31
  //     border.width: 1
  //     visible:      (propFluxState.value == 2) // flux mode enabled & fluxing)
  //   }

  //   followFluxPosition: true
  //   relativeToPlayhead: true
  //   pos:                0
  //   followTarget:       wfPosition
  // }

  //--------------------------------------------------------------------------------------------------------------------
  //  PlayMarker
  //--------------------------------------------------------------------------------------------------------------------

  // T.WaveformTranslator {
  //   id: play_marker
  //   followTarget:       wfPosition
  //   pos:                0
  //   relativeToPlayhead: true
  //   visible:            view.trackIsLoaded

  //   Rectangle {
  //     property int sliceModeHeight: waveformContainer.height - 10
  //     x:	  slicer.enabled ? 0 : playmarkerPosition
  //     y:     -1
  //     width:  3
  //     height: (slicer.enabled && !beatgrid.editEnabled ) ? sliceModeHeight : waveformContainer.height + 2
  //     color:        colors.colorRedPlaymarker
  //     border.color: colors.colorBlack31
  //     border.width: 1
  //   }
  // }

  //--------------------------------------------------------------------------------------------------------------------
  // Stem Color Indicators (Rectangles)
  //--------------------------------------------------------------------------------------------------------------------

  // StemColorIndicators {
  //   id: stemColorIndicators
  //   deckId:          view.deckId
  //   anchors.fill:    stemWaveform
  //   anchors.rightMargin:	 309
  //   visible:         stemWaveform.visible
  //   indicatorHeight: !settings.hidePhase && !settings.hidePhrase ? (deckInfo.showBPMInfo ? (slicer.enabled && !beatgrid.editEnabled ) ? [17 , 17 , 17 , 17] : [19 , 19 , 19 , 20] : (slicer.enabled && !beatgrid.editEnabled ) ? [25 , 25 , 25 , 25] : [27 , 27 , 27 , 27]) : (deckInfo.showBPMInfo ? (slicer.enabled && !beatgrid.editEnabled ) ? [21 , 21 , 21 , 21] : [23 , 23 , 23 , 23] : (slicer.enabled && !beatgrid.editEnabled ) ? [29 , 29 , 29 , 29] : [31 , 31 , 31 , 31])
  // }

    Widgets.LoopSize {
        id: loopSize
        anchors.topMargin: 1
        anchors.fill: parent
        visible: (deckInfo.showLoopInfo || deckInfo.loopActive || settings.alwaysShowLoopSize) && !deckInfo.adjustEnabled && !hideLoop && (slicer.enabled == false)
    }

    Widgets.KeyDisplay {
        id: keyDisplay
        anchors.topMargin: 1
        anchors.fill: parent
        visible: !hideKey
    }

    Widgets.BpmDisplay {
        id: bpmDisplay
        anchors.bottomMargin: 1
        anchors.top: singleWaveform.bottom
        anchors.fill: parent
        visible: !hideBPM && (!deckInfo.showBPMInfo && !settings.alwaysShowTempoInfo && !deckInfo.adjustEnabled) || settings.hideWaveforms
    }

    Widgets.FaderStart {
        id: faderStart
        anchors.topMargin: deckInfo.breakEnabled && settings.showBreakWarning ? 20 : 1
        anchors.fill: parent
        visible: deckInfo.faderStart && settings.showFaderStartWarning
    }

    Widgets.BreakEnabled {
        id: breakEnabled
        anchors.topMargin: 1
        anchors.fill: parent
        visible: deckInfo.breakEnabled && settings.showBreakWarning
    }

  //--------------------------------------------------------------------------------------------------------------------
  // States
  //------------------------------------------------------------------------------------------------------------------
    state: isStemDeck ? "stem" : "single"
    states: [
        State {
            name: "single";
            PropertyChanges { target: singleWaveform; height: view.height; }
            PropertyChanges { target: stemWaveform; height: 0; }
        },
        State {
            name: "stem";
            PropertyChanges { target: singleWaveform; height: 0 }
            PropertyChanges { target: stemWaveform; height: view.height }
            PropertyChanges { target: stemWaveform; anchors.bottomMargin: (isStemDeck & slicer.enabled) ? 15 : 0 }
        }
    ]
    transitions: [
        Transition {
            from: "single"
            SequentialAnimation {
                PropertyAction { target: stemWaveform; property: "visible"; value: true; }
                ParallelAnimation {
                    NumberAnimation { target: singleWaveform; property: "height"; duration: durations.deckTransition; }
                    NumberAnimation { target: stemWaveform; property: "height"; duration: durations.deckTransition; }
                }
                PropertyAction { target: singleWaveform; property: "visible"; value: false; }
            }
        },
        Transition {
            from: "stem"
            SequentialAnimation {
                PropertyAction { target: singleWaveform; property: "visible"; value: true; }
                ParallelAnimation {
                    NumberAnimation { target: singleWaveform; property: "height"; duration: durations.deckTransition; }
                    NumberAnimation { target: stemWaveform; property: "height"; duration: durations.deckTransition; }
                }
                PropertyAction { target: stemWaveform; property: "visible"; value: false; }
            }
        }
    ]
}
