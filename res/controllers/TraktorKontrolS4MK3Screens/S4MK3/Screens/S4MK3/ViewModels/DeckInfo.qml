import QtQuick 2.5
import '../../../CSI' as CSI
import '../../Defines' as Defines

import Mixxx 1.0 as Mixxx

//----------------------------------------------------------------------------------------------------------------------
//  Track Deck Model - provide data for the track deck view
//----------------------------------------------------------------------------------------------------------------------

Item {
    id: viewModel

    readonly property string group: `[Channel${viewModel.deckId}]`
    readonly property var deckPlayer: Mixxx.PlayerManager.getPlayer(viewModel.group)

    function isLeftScreen(deckId) {
        return deckId == 1 || deckId == 3;
    }

    function deckLetter(deckId) {
        if (deckId == 1) {return "A"};
        if (deckId >= 2) {return "B"};
        if (deckId == 3) {return "C"};
        if (deckId == 4) {return "D"};
    }

    function tempoNeeded(master, current) {
        if (master > current) {

            return (1-(current/master))*100;

        } else if (master < current) {

            return ((master/current)-1)*100;
        }
    }

    function toInt_round(val) { return parseInt(val+0.5); }

    function computeBeatCounterStringFromPosition(beat) {
        var phraseLen = 4;
        var curBeat  = parseInt(beat);

        if (beat < 0.0)
            curBeat = curBeat*-1;

        var value1 = parseInt(((curBeat/4)/phraseLen)+1);
        var value2 = parseInt(((curBeat/4)%phraseLen)+1);
        var value3 = parseInt( (curBeat%4)+1);

        if (beat < 0.0)
            return "-" + value1.toString() + "." + value2.toString() + "." + value3.toString();

        return value1.toString() + "." + value2.toString() + "." + value3.toString();
    }

    function computeBeatCounterStringFromPositionSingle(beat) {
        var phraseLen = 4;
        var curBeat  = parseInt(beat);

        if (beat < 0.0)
            curBeat = curBeat*-1;

        var value3 = parseInt( (curBeat%4)+1);

        return value3.toString();
    }

    function computeBeatCounterStringFromPositionAlt(beat) {
        var phraseLen = 4;
        var curBeat  = parseInt(beat);

        if (beat < 0.0)
            curBeat = curBeat*-1;

        var value1 = parseInt(((curBeat)/phraseLen)+1);
        var value2 = parseInt( (curBeat%4)+1);

        if (beat < 0.0)
            return "-" + value1.toString() + "." + value2.toString();

        return value1.toString() + "." + value2.toString();
    }

  ////////////////////////////////////
  /////// Track info properties //////
  ////////////////////////////////////

    property int deckId: 1
    readonly property bool trackEndWarning: propTrackEndWarning.value
    readonly property bool shift: propShift.value
    readonly property string artistString: isLoaded ? propArtist.value : "v3.5 By Joe Easton"
    readonly property string bpmString: isLoaded ? propBPM.value.toFixed(2).toString() : "0.00"
    readonly property double cuePos: (propNextCuePoint.value >= 0) ? propNextCuePoint.value : propTrackLength.value*1000
    readonly property string beats: 	 computeBeatCounterStringFromPosition(((propElapsedTime.value*1000-propGridOffset.value)*propMixerBpm.value)/60000.0)
    readonly property string beatSingle: computeBeatCounterStringFromPositionSingle(((propElapsedTime.value*1000-propGridOffset.value)*propMixerBpm.value)/60000.0)
    readonly property string beatsAlt: computeBeatCounterStringFromPositionAlt(((propElapsedTime.value*1000-propGridOffset.value)*propMixerBpm.value)/60000.0)
    readonly property string beatsToCue: computeBeatCounterStringFromPosition(((propElapsedTime.value*1000-cuePos)*propMixerBpm.value)/60000.0)
    readonly property string timeToCue:			 utils.convertToTimeString(Math.floor(((propElapsedTime.value*1000-cuePos)*propMixerBpm.value)/60000.0)/2)
    readonly property string beatsToCueAlt: computeBeatCounterStringFromPositionAlt(((propElapsedTime.value*1000-cuePos)*propMixerBpm.value)/60000.0)
    readonly property int 	masterDeck: 		 propSyncMasterDeck.value+1
    readonly property int 	masterDeckId: 		 propSyncMasterDeck.value
    readonly property string 	masterDeckLetter: 	 (masterDeck == 1) ? "A" : ((masterDeck >= 2) ? "B" : ((masterDeck == 3) ? "C" : ((masterDeck == 4) ? "D" : "-")))
    readonly property string masterBPM: isLoaded ? propMasterBPM.value : 0.00
    readonly property string masterBPMShort: isLoaded ? propMasterBPM.value.toFixed(2).toString() : 0.00
  // readonly property string  masterBPMFooter:      isLoaded ? propMasterBPM.value.toFixed(2).toString() + " BPM" : ""
    readonly property string masterBPMFooter2: isLoaded ? propMasterBPM.value.toFixed(2).toString() + "BPM" : ""
    readonly property string bpmOffset: isLoaded ? (bpmString - masterBPM).toFixed(2).toString() : "0.00"
    readonly property string tempoString:		 isLoaded ? ((propTempo.value-1)*100).toFixed(2).toString() : "0.00"
    readonly property string tempoRange:		 	 toInt_round(propTempoRange.value*100).toString() + "%"
    readonly property string tempoStringPer:		 tempoString+'%'
  // readonly property string  tempoNeededVal:	      tempoNeeded(masterBPMShort, bpmString).toFixed(2).toString()
  // readonly property string  tempoNeededString:	  isLoaded ? (tempoNeededVal == 0) ?  "0.00" : (tempoNeededVal < 0) ?  tempoNeededVal + "%" : "+" + tempoNeededVal + "%" : "0.00"
    readonly property string tempoAbsolute: propMixerStableTempo.value
    readonly property string songBPM: propSongBPM.value.toFixed(3).toString()
    readonly property real elapsedTime: propElapsedTime.value
    readonly property real elapsedTime1: propElapsedTime1.value
    readonly property real elapsedTime2: propElapsedTime2.value
    readonly property real elapsedTime3: propElapsedTime3.value
    readonly property real elapsedTime4: propElapsedTime4.value
    readonly property real elapsedTimeMaster: propElapsedTimeMaster.value
    readonly property bool hightlightLoop: !shift
    readonly property bool hightlightKey: shift
    readonly property int isLoaded: (propTrackLength.value > 0) // || (deckType === DeckType.Remix)
    readonly property bool	showLogo:			 propTrackLength.value == 0 ? true : false
    readonly property string keyString: propKeyForDisplay.value
    readonly property string masterKey: propMasterKey.value
    readonly property int keyIndex: propFinalKeyId.value
    readonly property int masterKeyIndex: propMasterKeyId.value
    readonly property bool hasKey: isLoaded && keyIndex >= 0
    readonly property bool hasTempo: isLoaded && !!propTempo.value
    readonly property bool isKeyLockOn: propKeyLockOn.value
    readonly property bool isSyncOn: 	 propIsInSync.value
    readonly property bool isStemDeck: (propIsStemDeck.value >= 2) ? true : false
    readonly property bool loopActive: propLoopActive.value
    readonly property bool loopActiveLoop: propLoopActiveLoop.value
    readonly property string loopSizeString: propLoopSize.value < 1 ? `1/${1 / propLoopSize.value}` : `${propLoopSize.value}`
    readonly property string loopSizeInt: propLoopSize.value
    readonly property string primaryKey: propPrimaryKey.value
    readonly property string primaryKey1: propPrimaryKey1.value
    readonly property string primaryKey2: propPrimaryKey2.value
    readonly property string primaryKey3: propPrimaryKey3.value
    readonly property string primaryKey4: propPrimaryKey4.value
    readonly property string primaryKeyMaster: propPrimaryKeyMaster.value
    readonly property string remainingTimeString: (!isLoaded) ? "00:00" : utils.computeRemainingTimeString(propTrackLength.value, propElapsedTime.value)
    readonly property string elapsedTimeString: (!isLoaded) ? "00:00" : utils.convertToTimeString(Math.floor(propElapsedTime.value))
    readonly property string titleString: isLoaded ? propTitle.value : "Load a Track to Deck " + deckLetter(deckId)
    readonly property int trackLength: propTrackLength.value
    readonly property int trackLength1: propTrackLength1.value
    readonly property int trackLength2: propTrackLength2.value
    readonly property int trackLength3: propTrackLength3.value
    readonly property int trackLength4: propTrackLength4.value
    readonly property int trackLengthMaster: propTrackLengthMaster.value
    readonly property real phase: isPlaying && leaderGroup != group ? propPhase.value : 0
    readonly property bool touchKey: false // TODO map shift encoder touch event
    readonly property bool touchTime: false // TODO map shift encoder touch event
    readonly property bool touchLoop: false // TODO map shift encoder touch event
    readonly property string headerPropertyNumber: 			 propCover.value
    readonly property int deckType: propDeckType.value
    readonly property string keyAdjustString: (keyAdjustVal < 0 ? "" : "+") + (keyAdjustVal).toFixed(0).toString()
    readonly property real keyAdjustVal: propKeyAdjust.value*12
    readonly property variant loopSizeText: ["1/32", "1/16", "1/8", "1/4", "1/2", "1", "2", "4", "8", "16", "32"]
    readonly property bool 	slicerEnabled: 	 propEnabled.value
    readonly property int 	slicerNo: 	 	 propSlicerNo.value
    readonly property int		slicerSize:		 	 propSlicerSize.value

    readonly property bool headerEnabled: propHeaderEnabled.value
    readonly property string headerText: propHeaderText.value
    readonly property string headerTextLong: propHeaderTextLong.value
    readonly property int		sampleRate:			propSampleRate.value

    readonly property bool		isPlaying:			propIsPlaying.value

    readonly property bool		is1Playing:			propIs1Playing.value
    readonly property bool		is2Playing:			propIs2Playing.value
    readonly property bool		is3Playing:			propIs3Playing.value
    readonly property bool		is4Playing:			propIs4Playing.value

    readonly property int 	currentHotcue: 		propCurrentHotcue.value

    readonly property real volume: volumeProp.value

    readonly property string masterBeatSingle: computeBeatCounterStringFromPositionSingle(((propElapsedTimeMaster.value*1000-propGridOffsetMaster.value)*propMixerBpmMaster.value)/60000.0)

  // AppProperty { id: propSampleRate;        			path: "app.traktor.decks." + deckId + ".track.content.sample_rate"; }
    Mixxx.ControlProxy {
        group: viewModel.group
        key: "track_samplerate"
        id: propSampleRate
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
    Mixxx.ControlProxy {
        group: viewModel.leaderGroup
        key: "track_samplerate"
        id: propLeaderSampleRate
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propNextCuePoint;           path: "app.traktor.decks." + deckId + ".track.player.next_cue_point"; }
    QtObject {
        id: propNextCuePoint
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propTempoRange;       		path: "app.traktor.decks." + deckId + ".tempo.range_value" }
    Mixxx.ControlProxy {
        group: viewModel.group
        id: propTempoRange
        key: "rateRange"
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propEnabled; 	  			path: "app.traktor.decks." + deckId + ".freeze" + ".enabled" }
    QtObject {
        id: propEnabled
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propSlicerNo; 	  			path: "app.traktor.decks." + deckId + ".freeze" + ".current_slice" }
    QtObject {
        id: propSlicerNo
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propSlicerSize; 	  			path: "app.traktor.decks." + deckId + ".freeze.slice_count" }
    QtObject {
        id: propSlicerSize
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propDeckType;               path: "app.traktor.decks." + deckId + ".type" }
    QtObject {
        id: propDeckType
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propIsPlaying;               path: "app.traktor.decks." + deckId + ".play" }
    Mixxx.ControlProxy {
        group: viewModel.group
        key: "play"
        id: propIsPlaying
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }

    Mixxx.ControlProxy {
        group: "[Channel1]"
        id: propIs1Leader
        key: "sync_mode"
    }

    Mixxx.ControlProxy {
        group: "[Channel2]"
        id: propIs2Leader
        key: "sync_mode"
    }

    Mixxx.ControlProxy {
        group: "[Channel3]"
        id: propIs3Leader
        key: "sync_mode"
    }

    Mixxx.ControlProxy {
        group: "[Channel4]"
        id: propIs4Leader
        key: "sync_mode"
    }

    readonly property string leaderGroup: propIs1Leader.value >= 2 ? `[Channel1]` : propIs2Leader.value >= 2 ? `[Channel2]` : propIs3Leader.value >= 2 ? `[Channel3]` : propIs4Leader.value >= 2 ? `[Channel4]` : viewModel.group

  // AppProperty { id: propIs1Playing;               path: "app.traktor.decks.1.play" }
    Mixxx.ControlProxy {
        group: "[Channel1]"
        key: "play"
        id: propIs1Playing
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propIs2Playing;               path: "app.traktor.decks.2.play" }
    Mixxx.ControlProxy {
        group: "[Channel2]"
        key: "play"
        id: propIs2Playing
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propIs3Playing;               path: "app.traktor.decks.3.play" }
    Mixxx.ControlProxy {
        group: "[Channel3]"
        key: "play"
        id: propIs3Playing
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propIs4Playing;               path: "app.traktor.decks.4.play" }
    Mixxx.ControlProxy {
        group: "[Channel4]"
        key: "play"
        id: propIs4Playing
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }

  // AppProperty { id: propTitle;                  path: "app.traktor.decks." + deckId + ".content.title" }
    QtObject {
        id: propTitle
        property string description: "Description"
        property var value: viewModel.deckPlayer ? viewModel.deckPlayer.title : null
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propArtist;                 path: "app.traktor.decks." + deckId + ".content.artist" }
    QtObject {
        id: propArtist
        property string description: "Description"
        property var value: viewModel.deckPlayer ? viewModel.deckPlayer.artist : null
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propSongBPM;                 path: "app.traktor.decks." + deckId + ".content.bpm" }
    Mixxx.ControlProxy {
        group: viewModel.group
        id: propSongBPM
        key: "file_bpm"
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }

    Mixxx.ControlProxy {
        group: viewModel.group
        id: propKey
        key: "key"
    }
  // AppProperty { id: propKeyForDisplay;          path: "app.traktor.decks." + deckId + ".track.key.resulting.quantized" }
    QtObject {
        id: propKeyForDisplay
        property string description: "Description"
        property var value: [
                             "No key",
                             "1d",
                             "8d",
                             "3d",
                             "10d",
                             "5d",
                             "12d",
                             "7d",
                             "2d",
                             "9d",
                             "4d",
                             "11d",
                             "6d",
                             "10m",
                             "5m",
                             "12m",
                             "7m",
                             "2m",
                             "9m",
                             "4m",
                             "11m",
                             "6m",
                             "1m",
                             "8m",
                             "3m"
                             ][propKey.value]
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propMasterKey;          	path: "app.traktor.decks." + masterDeck + ".track.key.resulting.quantized" }
    QtObject {
        id: propMasterKey
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propMixerBpm;               path: "app.traktor.decks." + deckId + ".tempo.base_bpm" }
    QtObject {
        id: propMixerBpm
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propMixerBpmMaster;               path: "app.traktor.decks." + masterDeck + ".tempo.base_bpm" }
    QtObject {
        id: propMixerBpmMaster
        property string description: "Description"
        property var value: 160
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFinalKeyId;             path: "app.traktor.decks." + deckId + ".track.key.final_id" }
    QtObject {
        id: propFinalKeyId
        property string description: "Description"
        property var value: propKey.value
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propMasterKeyId;             path: "app.traktor.decks." + masterDeck + ".track.key.final_id" }
    Mixxx.ControlProxy {
        group: viewModel.leaderGroup
        id: propMasterKeyId
        key: "key"
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propKeyAdjust;              path: "app.traktor.decks." + deckId + ".track.key.adjust" }
    QtObject {
        id: propKeyAdjust
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propGridOffset;     	    path: "app.traktor.decks." + deckId + ".content.grid_offset" }
    QtObject {
        id: propGridOffset
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propGridOffsetMaster;     	    path: "app.traktor.decks." + masterDeck + ".content.grid_offset" }
    QtObject {
        id: propGridOffsetMaster
        property string description: "Description"
        property var value: 10000
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propKeyLockOn;              path: "app.traktor.decks." + deckId + ".track.key.lock_enabled" }

    Mixxx.ControlProxy {
        group: viewModel.group
        id: propKeyLockOn
        key: "keylock"
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propBPM;                    path: "app.traktor.decks." + deckId + ".tempo.true_bpm" }
    Mixxx.ControlProxy {
        group: viewModel.group
        key: "bpm"
        id: propBPM
    }
  // AppProperty { id: propMasterBPM;                    path: "app.traktor.masterclock.tempo" }
    Mixxx.ControlProxy {
        group: viewModel.leaderGroup
        key: "bpm"
        id: propMasterBPM
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propCurrentHotcue;			path: "app.traktor.decks." + deckId + ".track.cue.select_or_set_hotcue"; }
    QtObject {
        id: propCurrentHotcue
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: volumeProp; 				path: "app.traktor.mixer.channels." + deckId + ".volume"; }
    QtObject {
        id: volumeProp
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }

  // AppProperty { id: propTempo;            		path: "app.traktor.decks." + deckId + ".tempo.tempo_for_display" }
    Mixxx.ControlProxy {
        group: viewModel.group
        key: "visual_bpm"
        id: propTempo
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propTempoAbsolute;    		path: "app.traktor.decks." + deckId + ".tempo.absolute" }
    QtObject {
        id: propTempoAbsolute
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }

    Mixxx.ControlProxy {
        group: viewModel.group
        key: "beat_closest"
        id: propBeatClosest
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
    Mixxx.ControlProxy {
        group: viewModel.group
        key: "track_samples"
        id: propSample
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
    QtObject {
        id: propBeatSample
        property var value: (propSampleRate.value * 60) / propBPM.value
    }
    QtObject {
        id: propBeatSampleOffset
        property var value: propBeatClosest.value % propBeatSample.value
    }
    QtObject {
        id: propBeat
        property var value: (propTrackPosition.value * propSample.value / 2) / propBeatSample.value
    }
    Mixxx.ControlProxy {
        group: viewModel.leaderGroup
        key: "beat_closest"
        id: propLeaderBeatClosest
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
    Mixxx.ControlProxy {
        group: viewModel.leaderGroup
        key: "track_samples"
        id: propLeaderSample
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
    QtObject {
        id: propLeaderBeatSample
        property var value: (propLeaderSampleRate.value * 60) / propMasterBPM.value
    }
    QtObject {
        id: propLeaderBeatSampleOffset
        property var value: propLeaderBeatClosest.value % propLeaderBeatSample.value
    }
    QtObject {
        id: propLeaderBeat
        property var value: (propLeaderTrackPosition.value * propLeaderSample.value / 2) / propLeaderBeatSample.value
    }
  // AppProperty { id: propPhase;                  path: "app.traktor.decks." + deckId + ".tempo.phase"; }
    QtObject {
        id: propPhase
        property string description: "Description"
        property var value: (propLeaderBeat.value-propBeat.value - 0.5) % 1 - 0.5
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propLoopSizeIdx;            path: "app.traktor.decks." + deckId + ".loop.size" }
    Mixxx.ControlProxy {
        group: viewModel.group
        key: "beatloop_size"
        id: propLoopSize
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propLoopActive;             path: "app.traktor.decks." + deckId + ".loop.active"; }
    Mixxx.ControlProxy {
        group: viewModel.group
        id: propLoopActive
        property string description: "Description"
        key: "loop_enabled"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propLoopActiveLoop;         path: "app.traktor.decks." + deckId + ".loop.is_in_active_loop"; }
    QtObject {
        id: propLoopActiveLoop
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propTrackLength;            path: "app.traktor.decks." + deckId + ".track.content.track_length"; }
    Mixxx.ControlProxy {
        id: propTrackLength
        group: viewModel.group
        key: "duration"
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propTrackLength1;            path: "app.traktor.decks." + 1 + ".track.content.track_length"; }
    QtObject {
        id: propTrackLength1
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propTrackLength2;            path: "app.traktor.decks." + 2 + ".track.content.track_length"; }
    QtObject {
        id: propTrackLength2
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propTrackLength3;            path: "app.traktor.decks." + 3 + ".track.content.track_length"; }
    QtObject {
        id: propTrackLength3
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propTrackLength4;            path: "app.traktor.decks." + 4 + ".track.content.track_length"; }
    QtObject {
        id: propTrackLength4
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propTrackLengthMaster;            path: "app.traktor.decks." + masterDeck + ".track.content.track_length"; }
    QtObject {
        id: propTrackLengthMaster
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propElapsedTime;            path: "app.traktor.decks." + deckId + ".track.player.elapsed_time"; }
    Mixxx.ControlProxy {
        id: propTrackPosition
        group: viewModel.group
        key: "playposition"
    }
    Mixxx.ControlProxy {
        id: propLeaderTrackPosition
        group: viewModel.leaderGroup
        key: "playposition"
    }
    QtObject {
        id: propElapsedTime
        property string description: "Description"
        property var value: parseInt(propTrackPosition.value * propTrackLength.value)
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propElapsedTime1;            path: "app.traktor.decks." + 1 + ".track.player.elapsed_time"; }
    QtObject {
        id: propElapsedTime1
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propElapsedTime2;            path: "app.traktor.decks." + 2 + ".track.player.elapsed_time"; }
    QtObject {
        id: propElapsedTime2
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propElapsedTime3;            path: "app.traktor.decks." + 3 + ".track.player.elapsed_time"; }
    QtObject {
        id: propElapsedTime3
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propElapsedTime4;            path: "app.traktor.decks." + 4 + ".track.player.elapsed_time"; }
    QtObject {
        id: propElapsedTime4
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propElapsedTimeMaster;            path: "app.traktor.decks." + masterDeck + ".track.player.elapsed_time"; }
    QtObject {
        id: propElapsedTimeMaster
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propMixerStableTempo; 		path: "app.traktor.decks." + deckId + ".tempo.true_tempo" }
    QtObject {
        id: propMixerStableTempo
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propertyCover;              path: "app.traktor.decks." + deckId + ".content.cover_md5" }
    QtObject {
        id: propertyCover
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propPrimaryKey;             path: "app.traktor.decks." + deckId + ".track.content.entry_key"; }
    QtObject {
        id: propPrimaryKey
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propPrimaryKey1;             path: "app.traktor.decks." + 1 + ".track.content.entry_key"; }
    QtObject {
        id: propPrimaryKey1
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propPrimaryKey2;             path: "app.traktor.decks." + 2 + ".track.content.entry_key"; }
    QtObject {
        id: propPrimaryKey2
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propPrimaryKey3;             path: "app.traktor.decks." + 3 + ".track.content.entry_key"; }
    QtObject {
        id: propPrimaryKey3
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propPrimaryKey4;             path: "app.traktor.decks." + 4 + ".track.content.entry_key"; }
    QtObject {
        id: propPrimaryKey4
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propPrimaryKeyMaster;             path: "app.traktor.decks." + masterDeck + ".track.content.entry_key"; }
    QtObject {
        id: propPrimaryKeyMaster
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propTrackEndWarning;        path: "app.traktor.decks." + deckId + ".track.track_end_warning" }
    Mixxx.ControlProxy {
        group: viewModel.group
        key: `end_of_track`
        id: propTrackEndWarning
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propCover;        			path: "app.traktor.decks." + deckId + ".content.cover_md5" }
    QtObject {
        id: propCover
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }

  // AppProperty { id: favProp;        			path: "app.traktor.browser.favorites.select" }
    QtObject {
        id: favProp
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
    readonly property int favId: favProp.value

  // AppProperty { id: propHeaderEnabled;        			path: "app.traktor.informer.deck_loading_warnings." + deckId + ".active" }
    QtObject {
        id: propHeaderEnabled
        property string description: "Description"
        property var value: false
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propHeaderText;        			path: "app.traktor.informer.deckheader_message." + deckId + ".short" }
    QtObject {
        id: propHeaderText
        property string description: "Description"
        property var value: "HeaderText"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propHeaderTextLong;        			path: "app.traktor.informer.deckheader_message." + deckId + ".long" }
    QtObject {
        id: propHeaderTextLong
        property string description: "Description"
        property var value: "HeaderTextLong"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }

  // AppProperty { id: propIsStemDeck;       path: "app.traktor.decks." + deckId + ".type"; }
    QtObject {
        id: propIsStemDeck
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }

  // MappingProperty { id: propAdjust;     path: "mapping.state." + (isLeftScreen(deckId) ? "left." : "right.") + deckId + ".grid_adjust" }
    QtObject {
        id: propAdjust
        property string description: "Description"
        property var value: false
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
    readonly property bool adjustEnabled: settings.showBPMGridAdjust ? propAdjust.value : false

  // MappingProperty { id: propPadsMode;     path: "mapping.state." + (isLeftScreen(deckId) ? "left" : "right") + ".pads_mode" }
    QtObject {
        id: propPadsMode
        property string description: "Description"
        property var value: 1
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
    property bool padsModeJump: propPadsMode.value == 8 ? true : false
    property bool padsModeLoop: propPadsMode.value == 5 ? true : false
    property bool padsModeRoll: propPadsMode.value == 7 ? true : false
    property bool padsModeTone: propPadsMode.value == 11 ? true : false
    property bool padsModeFx1: propPadsMode.value == 9 ? true : false
    property bool padsModeFx2: propPadsMode.value == 10 ? true : false
    property bool padsModeBank1: propPadsMode.value == 12 ? true : false
    property bool padsModeBank2: propPadsMode.value == 13 ? true : false
    property bool padsModeBank3: propPadsMode.value == 14 ? true : false
    property bool padsModeBank4: propPadsMode.value == 15 ? true : false

  // AppProperty { id: propTick; path: "app.traktor.decks." + deckId + ".track.grid.tick"}
    QtObject {
        id: propTick
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propTap; path: "app.traktor.decks." + deckId + ".track.grid.tap"}
    QtObject {
        id: propTap
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }

    readonly property bool tick: propTick.value
    readonly property bool tap: propTap.value

  // AppProperty { id: propIsInSync;       path: "app.traktor.decks." + deckId + ".sync.enabled"; }
    QtObject {
        id: propIsInSync
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propSyncMasterDeck; path: "app.traktor.masterclock.source_id" }
    QtObject {
        id: propSyncMasterDeck
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }

  // AppProperty { id: propBrowser; 		path: "app.traktor.browser.full_screen" }
    QtObject {
        id: propBrowser
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
    readonly property bool 	isInBrowserMode: 	 propBrowser.value

  // MappingProperty { id: propShift;     path: "mapping.state." + (isLeftScreen(deckId) ? "left" : "right") + ".shift" }
    QtObject {
        id: propShift
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // MappingProperty { id: propZoom;     path: "mapping.state." + deckId + ".zoom_level" }
    QtObject {
        id: propZoom
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }

    readonly property int zoomLevel: propZoom.value

  // AppProperty { id: waveZoomProp; path: "app.traktor.decks." + deckId + ".track.waveform_zoom" }
    QtObject {
        id: waveZoomProp
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
    property string waveZoom: waveZoomProp.value

  //fx and overlays
    property var fxModel: Mixxx.EffectsManager.visibleEffectsModel

  // AppProperty { id: propFx1Type;        			path: "app.traktor.fx.1.type" }
    QtObject {
        id: propFx1Type
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
    readonly property int fx1Type:	propFx1Type.value

  // AppProperty { id: propFx2Type;        			path: "app.traktor.fx.2.type" }
    QtObject {
        id: propFx2Type
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
    readonly property int fx2Type:	propFx2Type.value

  // AppProperty { id: propFx3Type;        			path: "app.traktor.fx.3.type" }
    QtObject {
        id: propFx3Type
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
    readonly property int fx3Type:	propFx3Type.value

  // AppProperty { id: propFx4Type;        			path: "app.traktor.fx.4.type" }
    QtObject {
        id: propFx4Type
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
    readonly property int fx4Type:	propFx4Type.value

  // AppProperty { id: propFx1DryWet;        			path: "app.traktor.fx.1.dry_wet" }
    Mixxx.ControlProxy {
        group: "[EffectRack1_EffectUnit1]"
        key: `mix`
        id: propFx1DryWet
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx2DryWet;        			path: "app.traktor.fx.2.dry_wet" }
    Mixxx.ControlProxy {
        group: "[EffectRack1_EffectUnit2]"
        key: `mix`
        id: propFx2DryWet
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx1Knob1;        			path: "app.traktor.fx.1.knobs.1" }
    Mixxx.ControlProxy {
        group: "[EffectRack1_EffectUnit1_Effect1]"
        key: `meta`
        id: propFx1Knob1
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx1Knob2;        			path: "app.traktor.fx.1.knobs.2" }
    Mixxx.ControlProxy {
        group: "[EffectRack1_EffectUnit1_Effect2]"
        key: `meta`
        id: propFx1Knob2
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx1Knob3;        			path: "app.traktor.fx.1.knobs.3" }
    Mixxx.ControlProxy {
        group: "[EffectRack1_EffectUnit1_Effect3]"
        key: `meta`
        id: propFx1Knob3
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx2Knob1;        			path: "app.traktor.fx.2.knobs.1" }
    Mixxx.ControlProxy {
        group: "[EffectRack1_EffectUnit2_Effect1]"
        key: `meta`
        id: propFx2Knob1
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx2Knob2;        			path: "app.traktor.fx.2.knobs.2" }
    Mixxx.ControlProxy {
        group: "[EffectRack1_EffectUnit2_Effect2]"
        key: `meta`
        id: propFx2Knob2
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx2Knob3;        			path: "app.traktor.fx.2.knobs.3" }
    Mixxx.ControlProxy {
        group: "[EffectRack1_EffectUnit2_Effect3]"
        key: `meta`
        id: propFx2Knob3
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }

  // AppProperty { id: propFx1Knob1Name;        		path: "app.traktor.fx.1.knobs.1.name" }
    QtObject {
        id: propFx1Knob1Name

        property Mixxx.EffectSlotProxy slot: Mixxx.EffectsManager.getEffectSlot(1, 1)
        property string description: "Description"
        property var value: "---"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
    Mixxx.ControlProxy {
        group: "[EffectRack1_EffectUnit1_Effect1]"
        key: `loaded_effect`
        onValueChanged: {
            propFx1Knob1Name.value = Mixxx.EffectsManager.visibleEffectsModel.get(value).display
        }
    }
  // AppProperty { id: propFx1Knob2Name;        		path: "app.traktor.fx.1.knobs.2.name" }
    QtObject {
        id: propFx1Knob2Name

        property Mixxx.EffectSlotProxy slot: Mixxx.EffectsManager.getEffectSlot(1, 1)
        property string description: "Description"
        property var value: "---"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
    Mixxx.ControlProxy {
        group: "[EffectRack1_EffectUnit1_Effect2]"
        key: `loaded_effect`
        onValueChanged: {
            propFx1Knob2Name.value = Mixxx.EffectsManager.visibleEffectsModel.get(value).display
        }
    }
  // AppProperty { id: propFx1Knob3Name;        		path: "app.traktor.fx.1.knobs.3.name" }
    QtObject {
        id: propFx1Knob3Name
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx2Knob1Name;        		path: "app.traktor.fx.2.knobs.1.name" }
    QtObject {
        id: propFx2Knob1Name
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx2Knob2Name;        		path: "app.traktor.fx.2.knobs.2.name" }
    QtObject {
        id: propFx2Knob2Name
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx2Knob3Name;        		path: "app.traktor.fx.2.knobs.3.name" }
    QtObject {
        id: propFx2Knob3Name
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }

  // AppProperty { id: propFx1Enabled;        			path: "app.traktor.fx.1.enabled" }
    Mixxx.ControlProxy {
        group: "[EffectRack1_EffectUnit1]"
        key: "enabled"
        id: propFx1Enabled
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx2Enabled;        			path: "app.traktor.fx.2.enabled" }
    Mixxx.ControlProxy {
        group: "[EffectRack1_EffectUnit2]"
        key: `enabled`
        id: propFx2Enabled
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx1Button1;        			path: "app.traktor.fx.1.buttons.1" }
    Mixxx.ControlProxy {
        group: "[EffectRack1_EffectUnit1_Effect1]"
        key: `enabled`
        id: propFx1Button1
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx1Button2;        			path: "app.traktor.fx.1.buttons.2" }
    Mixxx.ControlProxy {
        group: "[EffectRack1_EffectUnit1_Effect2]"
        key: `enabled`
        id: propFx1Button2
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx1Button3;        			path: "app.traktor.fx.1.buttons.3" }
    Mixxx.ControlProxy {
        group: "[EffectRack1_EffectUnit1_Effect3]"
        key: `enabled`
        id: propFx1Button3
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx2Button1;        			path: "app.traktor.fx.2.buttons.1" }
    Mixxx.ControlProxy {
        group: "[EffectRack1_EffectUnit2_Effect1]"
        key: `enabled`
        id: propFx2Button1
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx2Button2;        			path: "app.traktor.fx.2.buttons.2" }
    Mixxx.ControlProxy {
        group: "[EffectRack1_EffectUnit2_Effect2]"
        key: `enabled`
        id: propFx2Button2
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx2Button3;        			path: "app.traktor.fx.2.buttons.3" }
    Mixxx.ControlProxy {
        group: "[EffectRack1_EffectUnit2_Effect3]"
        key: `enabled`
        id: propFx2Button3
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx1Ch1;        			path: "app.traktor.mixer.channels.1.fx.assign.1" }
    Mixxx.ControlProxy {
        group: "[EffectRack1_EffectUnit1]"
        key: `group_${viewModel.group}_enable`
        id: propFx1Ch1
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx1Ch2;        			path: "app.traktor.mixer.channels.2.fx.assign.1" }
    QtObject {
        id: propFx1Ch2
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx1Ch3;        			path: "app.traktor.mixer.channels.3.fx.assign.1" }
    QtObject {
        id: propFx1Ch3
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx1Ch4;        			path: "app.traktor.mixer.channels.4.fx.assign.1" }
    QtObject {
        id: propFx1Ch4
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx2Ch1;        			path: "app.traktor.mixer.channels.1.fx.assign.2" }
    QtObject {
        id: propFx2Ch1
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx2Ch2;        			path: "app.traktor.mixer.channels.2.fx.assign.2" }
    QtObject {
        id: propFx2Ch2
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx2Ch3;        			path: "app.traktor.mixer.channels.3.fx.assign.2" }
    QtObject {
        id: propFx2Ch3
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx2Ch4;        			path: "app.traktor.mixer.channels.4.fx.assign.2" }
    QtObject {
        id: propFx2Ch4
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }

    readonly property real fx1DryWet: propFx1DryWet.value
    readonly property real fx2DryWet: propFx2DryWet.value
    readonly property real fx1Knob1: propFx1Knob1.value
    readonly property real fx1Knob2: propFx1Knob2.value
    readonly property real fx1Knob3: propFx1Knob3.value
    readonly property real fx2Knob1: propFx2Knob1.value
    readonly property real fx2Knob2: propFx2Knob2.value
    readonly property real fx2Knob3: propFx2Knob3.value

    readonly property string fx1Knob1Name: propFx1Knob1Name.value
    readonly property string fx1Knob2Name: propFx1Knob2Name.value
    readonly property string fx1Knob3Name: propFx1Knob3Name.value
    readonly property string fx2Knob1Name: propFx2Knob1Name.value
    readonly property string fx2Knob2Name: propFx2Knob2Name.value
    readonly property string fx2Knob3Name: propFx2Knob3Name.value

    readonly property bool fx1Enabled:	propFx1Enabled.value
    readonly property bool fx2Enabled:	propFx2Enabled.value
    readonly property bool fx1Button1:	propFx1Button1.value
    readonly property bool fx1Button2:	propFx1Button2.value
    readonly property bool fx1Button3:	propFx1Button3.value
    readonly property bool fx2Button1:	propFx2Button1.value
    readonly property bool fx2Button2:	propFx2Button2.value
    readonly property bool fx2Button3:	propFx2Button3.value

    readonly property bool fx1Ch1:	propFx1Ch1.value
    readonly property bool fx1Ch2:	propFx1Ch2.value
    readonly property bool fx1Ch3:	propFx1Ch3.value
    readonly property bool fx1Ch4:	propFx1Ch4.value
    readonly property bool fx2Ch1:	propFx2Ch1.value
    readonly property bool fx2Ch2:	propFx2Ch2.value
    readonly property bool fx2Ch3:	propFx2Ch3.value
    readonly property bool fx2Ch4:	propFx2Ch4.value

    onFx1DryWetChanged: {fx1Timer.running = true}
    onFx2DryWetChanged: {fx2Timer.running = true}
    onFx1Knob1Changed: {fx1Timer.running = true}
    onFx1Knob2Changed: {fx1Timer.running = true}
    onFx1Knob3Changed: {fx1Timer.running = true}
    onFx2Knob1Changed: {fx2Timer.running = true}
    onFx2Knob2Changed: {fx2Timer.running = true}
    onFx2Knob3Changed: {fx2Timer.running = true}
    onFx1EnabledChanged: {fx1Timer.running = true}
    onFx2EnabledChanged: {fx2Timer.running = true}
    onFx1Button1Changed: {fx1Timer.running = true}
    onFx1Button2Changed: {fx1Timer.running = true}
    onFx1Button3Changed: {fx1Timer.running = true}
    onFx2Button1Changed: {fx2Timer.running = true}
    onFx2Button2Changed: {fx2Timer.running = true}
    onFx2Button3Changed: {fx2Timer.running = true}
    onFx1Ch1Changed: {fx1Timer.running = true}
    onFx1Ch2Changed: {fx1Timer.running = true}
    onFx1Ch3Changed: {fx1Timer.running = true}
    onFx1Ch4Changed: {fx1Timer.running = true}
    onFx2Ch1Changed: {fx2Timer.running = true}
    onFx2Ch2Changed: {fx2Timer.running = true}
    onFx2Ch3Changed: {fx2Timer.running = true}
    onFx2Ch4Changed: {fx2Timer.running = true}
    onFx1Knob1NameChanged: {fx1Timer.running = true}
    onFx1Knob2NameChanged: {fx1Timer.running = true}
    onFx1Knob3NameChanged: {fx1Timer.running = true}
    onFx2Knob1NameChanged: {fx2Timer.running = true}
    onFx2Knob2NameChanged: {fx2Timer.running = true}
    onFx2Knob3NameChanged: {fx2Timer.running = true}

    onLoopSizeStringChanged: {loopTimer.running = true}
    onLoopActiveChanged: {loopTimer.running = true}

    Timer {
        id: loopTimer
        property bool showLoop: false

        triggeredOnStart: true
        interval: settings.loopOverlayTimer
        repeat: false
        running: false

        onTriggered: {
            showLoop = !showLoop
        }
    }

    property bool showLoopInfo:	 loopTimer.showLoop

    onBpmStringChanged: {bpmTimer.running = true}

    Timer {
        id: bpmTimer
        property bool showBPM: false

        triggeredOnStart: true
        interval: settings.bpmOverlayTimer
        repeat: false
        running: false

        onTriggered: {
            showBPM = !showBPM
        }
    }

    property bool showBPMInfo:	 bpmTimer.showBPM && bpmTimer.running

  // AppProperty { id: propFx3DryWet;        			path: "app.traktor.fx.3.dry_wet" }
    Mixxx.ControlProxy {
        group: "[EffectRack1_EffectUnit3]"
        key: `mix`
        id: propFx3DryWet
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx4DryWet;        			path: "app.traktor.fx.4.dry_wet" }
    Mixxx.ControlProxy {
        group: "[EffectRack1_EffectUnit4]"
        key: `mix`
        id: propFx4DryWet
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx3Knob1;        			path: "app.traktor.fx.3.knobs.1" }
    QtObject {
        id: propFx3Knob1
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx3Knob2;        			path: "app.traktor.fx.3.knobs.2" }
    QtObject {
        id: propFx3Knob2
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx3Knob3;        			path: "app.traktor.fx.3.knobs.3" }
    QtObject {
        id: propFx3Knob3
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx4Knob1;        			path: "app.traktor.fx.4.knobs.1" }
    QtObject {
        id: propFx4Knob1
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx4Knob2;        			path: "app.traktor.fx.4.knobs.2" }
    QtObject {
        id: propFx4Knob2
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx4Knob3;        			path: "app.traktor.fx.4.knobs.3" }
    QtObject {
        id: propFx4Knob3
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }

  // AppProperty { id: propFx3Knob1Name;        		path: "app.traktor.fx.3.knobs.1.name" }
    QtObject {
        id: propFx3Knob1Name
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx3Knob2Name;        		path: "app.traktor.fx.3.knobs.2.name" }
    QtObject {
        id: propFx3Knob2Name
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx3Knob3Name;        		path: "app.traktor.fx.3.knobs.3.name" }
    QtObject {
        id: propFx3Knob3Name
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx4Knob1Name;        		path: "app.traktor.fx.4.knobs.1.name" }
    QtObject {
        id: propFx4Knob1Name
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx4Knob2Name;        		path: "app.traktor.fx.4.knobs.2.name" }
    QtObject {
        id: propFx4Knob2Name
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx4Knob3Name;        		path: "app.traktor.fx.4.knobs.3.name" }
    QtObject {
        id: propFx4Knob3Name
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }

  // AppProperty { id: propFx3Enabled;        			path: "app.traktor.fx.3.enabled" }
    Mixxx.ControlProxy {
        group: "[EffectRack1_EffectUnit3]"
        key: "enabled"
        id: propFx3Enabled
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx4Enabled;        			path: "app.traktor.fx.4.enabled" }
    Mixxx.ControlProxy {
        group: "[EffectRack1_EffectUnit4]"
        key: "enabled"
        id: propFx4Enabled
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx3Button1;        			path: "app.traktor.fx.3.buttons.1" }
    QtObject {
        id: propFx3Button1
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx3Button2;        			path: "app.traktor.fx.3.buttons.2" }
    QtObject {
        id: propFx3Button2
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx3Button3;        			path: "app.traktor.fx.3.buttons.3" }
    QtObject {
        id: propFx3Button3
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx4Button1;        			path: "app.traktor.fx.4.buttons.1" }
    QtObject {
        id: propFx4Button1
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx4Button2;        			path: "app.traktor.fx.4.buttons.2" }
    QtObject {
        id: propFx4Button2
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propFx4Button3;        			path: "app.traktor.fx.4.buttons.3" }
    QtObject {
        id: propFx4Button3
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }

    readonly property real fx3DryWet: propFx3DryWet.value
    readonly property real fx4DryWet: propFx3DryWet.value
    readonly property real fx3Knob1: propFx3Knob1.value
    readonly property real fx3Knob2: propFx3Knob2.value
    readonly property real fx3Knob3: propFx3Knob3.value
    readonly property real fx4Knob1: propFx4Knob1.value
    readonly property real fx4Knob2: propFx4Knob2.value
    readonly property real fx4Knob3: propFx4Knob3.value

    readonly property string fx3Knob1Name: propFx3Knob1Name.value
    readonly property string fx3Knob2Name: propFx3Knob2Name.value
    readonly property string fx3Knob3Name: propFx3Knob3Name.value
    readonly property string fx4Knob1Name: propFx4Knob1Name.value
    readonly property string fx4Knob2Name: propFx4Knob2Name.value
    readonly property string fx4Knob3Name: propFx4Knob3Name.value

    readonly property bool fx3Enabled:	propFx3Enabled.value
    readonly property bool fx4Enabled:	propFx4Enabled.value
    readonly property bool fx3Button1:	propFx3Button1.value
    readonly property bool fx3Button2:	propFx3Button2.value
    readonly property bool fx3Button3:	propFx3Button3.value
    readonly property bool fx4Button1:	propFx4Button1.value
    readonly property bool fx4Button2:	propFx4Button2.value
    readonly property bool fx4Button3:	propFx4Button3.value

  // readonly property bool fx3Ch1:	propFx3Ch1.value
    readonly property bool fx3Ch1:	false
  // readonly property bool fx3Ch2:	propFx3Ch2.value
    readonly property bool fx3Ch2:	false
  // readonly property bool fx3Ch3:	propFx3Ch3.value
    readonly property bool fx3Ch3:	false
  // readonly property bool fx3Ch4:	propFx3Ch4.value
    readonly property bool fx3Ch4:	false
  // readonly property bool fx4Ch1:	propFx4Ch1.value
    readonly property bool fx4Ch1:	false
  // readonly property bool fx4Ch2:	propFx4Ch2.value
    readonly property bool fx4Ch2:	false
  // readonly property bool fx4Ch3:	propFx4Ch3.value
    readonly property bool fx4Ch3:	false
  // readonly property bool fx4Ch4:	propFx4Ch4.value
    readonly property bool fx4Ch4:	false

    onFx3DryWetChanged: {fx3Timer.running = true}
    onFx4DryWetChanged: {fx4Timer.running = true}
    onFx3Knob1Changed: {fx3Timer.running = true}
    onFx3Knob2Changed: {fx3Timer.running = true}
    onFx3Knob3Changed: {fx3Timer.running = true}
    onFx4Knob1Changed: {fx4Timer.running = true}
    onFx4Knob2Changed: {fx4Timer.running = true}
    onFx4Knob3Changed: {fx4Timer.running = true}
    onFx3EnabledChanged: {fx3Timer.running = true}
    onFx4EnabledChanged: {fx4Timer.running = true}
    onFx3Button1Changed: {fx3Timer.running = true}
    onFx3Button2Changed: {fx3Timer.running = true}
    onFx3Button3Changed: {fx3Timer.running = true}
    onFx4Button1Changed: {fx4Timer.running = true}
    onFx4Button2Changed: {fx4Timer.running = true}
    onFx4Button3Changed: {fx4Timer.running = true}
    onFx3Ch1Changed: {fx3Timer.running = true}
    onFx3Ch2Changed: {fx3Timer.running = true}
    onFx3Ch3Changed: {fx3Timer.running = true}
    onFx3Ch4Changed: {fx3Timer.running = true}
    onFx4Ch1Changed: {fx4Timer.running = true}
    onFx4Ch2Changed: {fx4Timer.running = true}
    onFx4Ch3Changed: {fx4Timer.running = true}
    onFx4Ch4Changed: {fx4Timer.running = true}
    onFx3Knob1NameChanged: {fx3Timer.running = true}
    onFx3Knob2NameChanged: {fx3Timer.running = true}
    onFx3Knob3NameChanged: {fx3Timer.running = true}
    onFx4Knob1NameChanged: {fx4Timer.running = true}
    onFx4Knob2NameChanged: {fx4Timer.running = true}
    onFx4Knob3NameChanged: {fx4Timer.running = true}

  // AppProperty { id: propfx1;        			path: "app.traktor.mixer.channels." + deckId + ".fx.assign.1" }
    Mixxx.ControlProxy {
        group: "[EffectRack1_EffectUnit1]"
        key: `group_${viewModel.group}_enable`
        id: propfx1
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propfx2;        			path: "app.traktor.mixer.channels." + deckId + ".fx.assign.2" }
    Mixxx.ControlProxy {
        group: "[EffectRack1_EffectUnit2]"
        key: `group_${viewModel.group}_enable`
        id: propfx2
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propfx3;        			path: "app.traktor.mixer.channels." + deckId + ".fx.assign.3" }
    Mixxx.ControlProxy {
        group: "[EffectRack1_EffectUnit3]"
        key: `group_${viewModel.group}_enable`
        id: propfx3
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propfx4;        			path: "app.traktor.mixer.channels." + deckId + ".fx.assign.4" }
    Mixxx.ControlProxy {
        group: "[EffectRack1_EffectUnit4]"
        key: `group_${viewModel.group}_enable`
        id: propfx4
        property string description: "Description"
        property var valueRange: ({isDiscrete: true, steps: 1})
    }

    readonly property bool fx1On: propfx1.value
    readonly property bool fx2On: propfx2.value
    readonly property bool fx3On: propfx3.value
    readonly property bool fx4On: propfx4.value

    Timer {
        id: fx1Timer
        property bool blink: false

        triggeredOnStart: true
        interval: settings.fxOverlayTimer
        repeat: false
        running: fx1On

        onTriggered: {
            blink = !blink
        }
    }

    Timer {
        id: fx2Timer
        property bool blink: false

        triggeredOnStart: true
        interval: settings.fxOverlayTimer
        repeat: false
        running: fx2On

        onTriggered: {
            blink = !blink
        }
    }

    Timer {
        id: fx3Timer
        property bool blink: false

        triggeredOnStart: true
        interval: settings.fxOverlayTimer
        repeat: false
        running: fx3On

        onTriggered: {
            blink = !blink
        }
    }

    Timer {
        id: fx4Timer
        property bool blink: false

        triggeredOnStart: true
        interval: settings.fxOverlayTimer
        repeat: false
        running: fx4On

        onTriggered: {
            blink = !blink
        }
    }

    readonly property bool showFx1: fx1On && fx1Timer.blink
    readonly property bool showFx2: fx2On && fx2Timer.blink
    readonly property bool showFx3: fx3On && fx3Timer.blink
    readonly property bool showFx4: fx4On && fx4Timer.blink

  // MappingProperty { id: propBreak;     path: "mapping.state." + (isLeftScreen(deckId) ? "left." : "right.") + deckId + ".break_enabled" }
    QtObject {
        id: propBreak
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
    readonly property bool breakEnabled: propBreak.value

  // MappingProperty { id: propView;     path: "mapping.state." + (isLeftScreen(deckId) ? "left." : "right.") + deckId + ".view" }
    QtObject {
        id: propView
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }

    readonly property bool viewButton: propView.value

  // MappingProperty { id: propHotcuePressed;     path: "mapping.state." + deckId + ".hotcueInfo" }
    QtObject {
        id: propHotcuePressed
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
    property bool hotcuePressed: propHotcuePressed.value
    onHotcuePressedChanged: {hotcuePressed == false ? cueTimer.restart() : hotcuePressed = hotcuePressed }

  // MappingProperty { id: propHotcueId;     path: "mapping.state." + deckId + ".hotcueId" }
    QtObject {
        id: propHotcueId
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
    readonly property int hotcueId: propHotcueId.value

  // MappingProperty { id: propfaderStart;     path: "mapping.state.mixer." + deckId + ".fader_start"; }
    QtObject {
        id: propfaderStart
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
    readonly property bool faderStart: propfaderStart.value

    readonly property bool hotcueDisplay: hotcuePressed || cueTimer.running

  // AppProperty { id: nameProp; path: "app.traktor.decks." + deckId + ".track.cue.hotcues." + hotcueId + ".name"}
    QtObject {
        id: nameProp
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
    readonly property string hotcueName: nameProp.value

  // AppProperty { id: typeProp; path: "app.traktor.decks." + deckId + ".track.cue.hotcues." + hotcueId + ".type"}
    QtObject {
        id: typeProp
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
    readonly property int hotcueType: typeProp.value

    Timer {
        id: cueTimer
        property bool blink: false

        triggeredOnStart: true
        interval: 1000
        repeat: false
        running: false
    }

  ///////////////////////////////////////////////////
  /////// Remix Deck properties /////////////////////
  ///////////////////////////////////////////////////

    readonly property string beatPositionString: propBeatPosition.description
    readonly property bool rmxQuantizeOn: propRemixQuantOn.value
    readonly property string rmxQuantizeIndex: propRemixQuantIndex.description
    readonly property bool isSequencerRecOn: propSequencerRecOn.value
    readonly property int remixActiveSlot: propRemixActiveSlot.value
    readonly property bool remixSampleBrowsing: propRemixSampleBrowsing.value
    readonly property real remixPitch:			 propRemixPitch.value
    readonly property real remixGain:			 propRemixGain.value
    readonly property int activeCellIdx: 0 //slot.activeCellIdx
    readonly property bool	remixFx:			propRemixFx.value
    readonly property bool	remixLock:			propRemixLock.value
    readonly property int		captureSource:		propRemixSource.value
    readonly property string	sourceString:		captureSource == 0 ? "A" : captureSource == 1 ? "B" : captureSource >= 2 ? "C" : captureSource == 3 ? "D" : "L"

  // AppProperty { id: propRemixFx; 					 path: "app.traktor.decks." + deckId + ".remix.players." + remixActiveSlot + ".fx_send_on"}
    QtObject {
        id: propRemixFx
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propRemixLock; 					 path: "app.traktor.decks." + deckId + ".remix.players." + remixActiveSlot + ".key_lock"}
    QtObject {
        id: propRemixLock
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propBeatPosition;                path: "app.traktor.decks." + deckId + ".remix.current_beat_pos"}
    QtObject {
        id: propBeatPosition
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propRemixQuantOn;                path: "app.traktor.decks." + deckId + ".remix.quant"}
    QtObject {
        id: propRemixQuantOn
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propRemixSource;                path: "app.traktor.decks." + deckId + ".capture_source"}
    QtObject {
        id: propRemixSource
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propRemixQuantIndex;             path: "app.traktor.decks." + deckId + ".remix.quant_index"}
    QtObject {
        id: propRemixQuantIndex
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propSequencerRecOn;              path: "app.traktor.decks." + deckId + ".remix.sequencer.rec.on"}
    QtObject {
        id: propSequencerRecOn
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // MappingProperty { id: propRemixActiveSlot; path: "mapping.state." + (isLeftScreen(deckId) ? "left." : "right.") + deckId + ".active_slot";  }
    QtObject {
        id: propRemixActiveSlot
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // MappingProperty { id: propRemixSampleBrowsing; path: "mapping.state." + (isLeftScreen(deckId) ? "left." : "right.") + deckId + ".sample_browsing";  }
    QtObject {
        id: propRemixSampleBrowsing
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propRemixPitch; path: "app.traktor.decks." + deckId + ".remix.cell.columns." + remixActiveSlot + ".rows." + activeCellIdx + ".pitch";}
    QtObject {
        id: propRemixPitch
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propRemixGain; path: "app.traktor.decks." + deckId + ".remix.cell.columns." + remixActiveSlot + ".rows." + activeCellIdx + ".gain";}
    QtObject {
        id: propRemixGain
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }

  ///////////////////////////////////////////////////
  /////// Stem Deck properties //////////////////////
  ///////////////////////////////////////////////////

  // MappingProperty { id: propStemActive; path: "mapping.state." + (isLeftScreen(deckId) ? "left." : "right.") + deckId + ".stems.active_stem";  }
    QtObject {
        id: propStemActive
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }

    readonly property bool isStemsActive: propStemActive.value != 0
    readonly property int stemSelected: isStemsActive ? propStemActive.value : 1 // default value is 1

    readonly property string stemSelectedName: isStemsActive ? propStemSelectedName.value : ""
    readonly property real stemSelectedVolume: isStemsActive ? propStemSelectedVolume.value : 0.0
    readonly property bool stemSelectedMuted: isStemsActive ? propStemSelectedMuted.value : false
    readonly property real stemSelectedFilterValue: isStemsActive ? propStemSelectedFilter.value : 0.5
    readonly property real stemSelectedFXSendValue: isStemsActive ? propStemSelectedFXSend.value : 1
    readonly property bool stemSelectedFilterOn: isStemsActive ? propStemSelectedFilterOn.value : false
    readonly property bool stemSelectedFXSendOn: isStemsActive ? propStemSelectedFXSendOn.value : false
    readonly property color stemSelectedBrightColor: isStemsActive ? colors.palette(1., propStemSelectedColorId.value) : "grey"
    readonly property color stemSelectedMidColor: isStemsActive ? colors.palette(0.5, propStemSelectedColorId.value) : "black"

    function selectedStemPath() { return "app.traktor.decks." + deckId + ".stems." + stemSelected;}

  // AppProperty { id: propStemSelectedName;     path: selectedStemPath() + ".name" }
    QtObject {
        id: propStemSelectedName
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propStemSelectedVolume;   path: selectedStemPath() + ".volume" }
    QtObject {
        id: propStemSelectedVolume
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propStemSelectedMuted;    path: selectedStemPath() + ".muted" }
    QtObject {
        id: propStemSelectedMuted
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propStemSelectedFilter;   path: selectedStemPath() + ".filter_value" }
    QtObject {
        id: propStemSelectedFilter
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propStemSelectedFilterOn; path: selectedStemPath() + ".filter_on" }
    QtObject {
        id: propStemSelectedFilterOn
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propStemSelectedColorId;  path: selectedStemPath() + ".color_id" }
    QtObject {
        id: propStemSelectedColorId
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propStemSelectedFXSend;  path: selectedStemPath() + ".fx_send" }
    QtObject {
        id: propStemSelectedFXSend
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: propStemSelectedFXSendOn;  path: selectedStemPath() + ".fx_send_on" }
    QtObject {
        id: propStemSelectedFXSendOn
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }

  ///////////////////////////////////////////////////
  /////// Stripe properties /////////////////////////
  ///////////////////////////////////////////////////

    readonly property alias hotcues: hotcuesModel
    readonly property alias hotcues1: hotcuesModel1
    readonly property alias hotcues2: hotcuesModel2
    readonly property alias hotcues3: hotcuesModel3
    readonly property alias hotcues4: hotcuesModel4
    readonly property alias hotcuesMaster: hotcuesModelMaster

    HotCues { id: hotcuesModel; deckId: viewModel.deckId }
    HotCues { id: hotcuesModel1; deckId: 1 }
    HotCues { id: hotcuesModel2; deckId: 2 }
    HotCues { id: hotcuesModel3; deckId: 3 }
    HotCues { id: hotcuesModel4; deckId: 4 }
    HotCues { id: hotcuesModelMaster; deckId: masterDeck }
}
