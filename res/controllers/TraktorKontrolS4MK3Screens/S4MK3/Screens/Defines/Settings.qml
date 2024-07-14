import QtQuick 2.5

QtObject {

	// = comments

	//////////////////
	//EXTRA SETTINGS//
	//////////////////

	//Enable if you are using Traktor Pro Plus (NOTE: this requires a plus subscription. Also, do not enable if you are using a version of Traktor lower than 3.6.0)
    readonly property bool traktorPlus: false

	//change to false to disable tempo faders when holding shift
    readonly property bool 		shiftTempoFaderEnable: true

	//show only decks A&B or C&D - SELECT ONLY ONE
    readonly property bool 		showOnlyAB: false
    readonly property bool 		showOnlyCD: false

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	///////////////////////////////
	//PAD TYPE SELECTION SETTINGS//
	///////////////////////////////

	//Please only use the values in the line below. Using other values could have unexpected effects.
	//0 = disabled, 4 = freeze, 5 = loop, 7 = roll,  8 = jump/move, 9 = fx1, 10 = fx2, 11 = tone
    readonly property int		recordButton: 8
    readonly property int		samplesButton: 4
    readonly property int		muteButton: 7
    readonly property int		stemsButton: 5
    readonly property int		cueButton: 11
    readonly property int		fxLeftButton: 9
    readonly property int		fxRightButton: 10

	//0 = Red, 1 = Dark Orange, 2 = Light Orange, 3 = White, 4 = Yellow, 5 = Lime, 6 = Green, 7 = Mint, 8 = Cyan, 9 = Turquoise, 10 = Blue, 11 = Plum, 12 = Violet, 13 = Purple, 14 = Magenta, 15 = Fuchsia, 16 = Black, 17 = Warm Yellow
    readonly property int		stemsButtonColour: 6
    readonly property int		cueButtonColour: 3

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	/////////////////////////
	//DECK LOADING SETTINGS//
	/////////////////////////

	//set to false to disable the track starting at the earliset cue point when loading a track
    readonly property bool 		jumpToFirstCueOnLoad: true

	//set to true to disable the browser closing when a track is loaded.
    readonly property bool 		disableKnobFullBrowserCloser: false
    readonly property bool 		disableKnobSingleBrowserCloser: false

	//Change to true to enable headphone cue on selected deck when loading a track. If both are enabled, all cues will be disabled apart from the newly loaded deck.
    readonly property bool 		enableCueOnTrackLoad: false
    readonly property bool 		disableAllCueOnTrackLoad: false

	//set to false to disable the pad mode resetting when loading a track
    readonly property bool 		resetPadModeOnLoad: true

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	///////////////////////////
	//LED AND COLOUR SETTINGS//
	///////////////////////////

	//change to false to disable the flashing when track end warning is enabled
    readonly property bool 		waveformEndFlashing: true
    readonly property bool 		jogwheelEndFlashing: true

	//set to true to enable the jogwheel led to move when pressing cue
    readonly property bool 		jogwheelLedCue: true

	//0 = RGB, 1 = Default, 2 = Red, 3 = Dark Orange, 4 = Light Orange, 5 = Warm Yellow, 6 = Yellow, 7 = Lime, 8 = Green, 9 = Mint, 10 = Cyan, 11 = Turquoise, 12 = Blue, 13 = Plum, 14 = Violet, 15 = Purple, 16 = Magenta, 17 = Fuchsia, 18 = RGB 2, 19 = RGB 3, 20 = RGB 4, 21 = Ultraviolet, 22 = Ultraviolet Inverted
    readonly property int 		deckAWaveformColour:	0
    readonly property int 		deckBWaveformColour:	0
    readonly property int 		deckCWaveformColour:	0
    readonly property int		deckDWaveformColour:	0

	//0 = Red, 1 = Dark Orange, 2 = Light Orange, 3 = White, 4 = Yellow, 5 = Lime, 6 = Green, 7 = Mint, 8 = Cyan, 9 = Turquoise, 10 = Blue, 11 = Plum, 12 = Violet, 13 = Purple, 14 = Magenta, 15 = Fuchsia, 16 = Black, 17 = Warm Yellow
    readonly property int 		deckAColour:	10
    readonly property int 		deckBColour:	10
    readonly property int 		deckCColour:	2
    readonly property int 		deckDColour:	2
    readonly property int 		jogAColour:	10
    readonly property int 		jogBColour:	10
    readonly property int 		jogCColour:	2
    readonly property int 		jogDColour:	2

	//1 = Red, 2 = Dark Orange, 3 = Light Orange, 4 = White, 5 = Yellow, 6 = Lime, 7 = Green, 8 = Mint, 9 = Cyan, 10 = Turquoise, 11 = Blue, 12 = Plum, 13 = Violet, 14 = Purple, 15 = Magenta, 16 = Fuchsia, 17 = Warm Yellow
    readonly property int 		fx1Colour:	1
    readonly property int 		fx2Colour:	8
    readonly property int 		fx3Colour:	11
    readonly property int 		fx4Colour:	6
    readonly property int 		filterColour:	3

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //////////////////////////////
	//BPM/TEMPO DISPLAY SETTINGS//
	//////////////////////////////

	//Change to true to always show tempo/bpm info
    readonly property bool 		alwaysShowTempoInfo: false

	//amount of time the bpm overlay will stay on the screen in ms. 1000 = 1 second.
    readonly property int 		bpmOverlayTimer: 5000

	//0 = Hidden, 1 = Master BPM, 2 = BPM, 3 = Tempo, 4 = BPM Offset, 5 = Tempo Offset, 6 = Master Deck Letter, 7 = Tempo Range, 8 = Key, 9 = Original BPM
    readonly property int 		tempoDisplayLeft: 2
    readonly property int 		tempoDisplayCenter: 1
    readonly property int 		tempoDisplayRight: 3
    readonly property int 		tempoDisplayLeftShift: 4
    readonly property int 		tempoDisplayCenterShift: 6
    readonly property int 		tempoDisplayRightShift: 5

	//set to true to enable the text colour to aid with your mixing.
    readonly property bool 		enableBpmTextColor: false
    readonly property bool 		enableMasterBpmTextColor: false
    readonly property bool 		enableTempoTextColor: false
    readonly property bool 		enableBpmOffsetTextColor: false
    readonly property bool 		enableTempoOffsetTextColor: false
    readonly property bool 		enableMasterDeckTextColor: false

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	/////////////////////
	//WAVEFORM SETTINGS//
	/////////////////////

	//change to true to disable the moving waveforms
    readonly property bool 		hideWaveforms: false

	//Change to false to hide loop size indicator (after 10 seconds of loop inactivity)
    readonly property bool 		alwaysShowLoopSize: true

	//amount of time the loop overlay will stay on the screen in ms. 1000 = 1 second.
    readonly property int 		loopOverlayTimer: 10000

	//set to between 0 and -250 to move the playmarker to the left.
    readonly property int 		waveformPlaymarkerPosition: -250

	//set to true to hide the beatgrid
    readonly property bool hideBeatgrid: false

	//this value is the visibility of the beatgrid lines in %. Values are 0 to 100
    readonly property int beatgridVisibility: 25

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	////////////////////
	//BROWSER SETTINGS//
	////////////////////

	//set to false to disable browser view and pads
    readonly property bool 		enableBrowserMode: true

	//set to false to disable the adjacent key colouring and return to all keys coloured
    readonly property bool		adjacentKeys: true

	//change to true to enable camelot key
    readonly property bool 		camelotKey:	false

	//set to true to disable the preview player toggle button and change it back to hold
    readonly property bool 		disablePreviewPlayerToggle: false

	//Set to false to disable browser on screen when pressing favorites button
    readonly property bool 		showBrowserOnFavourites: true

	//0 = Red, 1 = Dark Orange, 2 = Light Orange, 3 = White, 4 = Yellow, 5 = Lime, 6 = Green, 7 = Mint, 8 = Cyan, 9 = Turquoise, 10 = Blue, 11 = Plum, 12 = Violet, 13 = Purple, 14 = Magenta, 15 = Fuchsia, 16 = Black, 17 = Warm Yellow
    readonly property int 		favorites1PadColor: 4
    readonly property int 		favorites2PadColor: 4
    readonly property int 		favorites3PadColor: 4
    readonly property int 		favorites4PadColor: 4
    readonly property int 		favorites5PadColor: 4
    readonly property int 		favorites6PadColor: 4
    readonly property int 		favorites7PadColor: 4
    readonly property int 		favorites8PadColor: 4
    readonly property int 		favorites9PadColor: 4
    readonly property int 		favorites10PadColor: 4
    readonly property int 		favorites11PadColor: 4
    readonly property int 		favorites12PadColor: 4

	//set to true to swap the functions of the view and add to prep buttons
    readonly property bool 		swapViewButtons: false

	//Set to false to disable browser on screen when open in full screen mode.
	//This will also revert the view and prep button functions back to default except opening the browser on the S4 instead of the laptop.
    readonly property bool 		showBrowserOnFullScreen: true

	//set to true to disable the led output on the browser sort buttons
    readonly property bool 		disableSortButtonOutput: false

	// 1 = "Sort By #", 2 = "Title", 3 = "Artist", 4 = "Time", 5 = "BPM", 6 = "Track #", 7 = "Release", 8 = "Label", 9 = "Genre", 10 = "Key Text", 11 = "Comment", 12 = "Lyrics", 13 = "Comment 2", 14 = "Path", 15 = "Analysed"
	// 16 = "Remixer", 17 = "Producer", 18 = "Mix", 19 = "CAT #", 20 = "Release Date", 21 = "Bitrate", 22 = "Rating", 23 = "Count", 24 = "Sort By #", 25 = "Cover Art", 26 = "Last Played", 27 = "Import Date", 28 = "Key", 29 = "Color"
    readonly property int 		hotcueButtonSort: 2
    readonly property int 		recordButtonSort: 3
    readonly property int 		samplesButtonSort: 5
    readonly property int 		muteButtonSort: 28
    readonly property int 		stemsButtonSort: 22

	//Change this setting to true to change the browser encoder to a list scroll when holding shift.
    readonly property bool 		browserEncoderShiftScroll: false

	//This is the size of the page scroll.
    readonly property int 		scrollPageSize: 6

	//change to false to disable the browser view displaying artist data whilst holding shift
    readonly property bool 		browserShift: true

	//only enable when both artist and title columns are shown
    readonly property bool 		swapArtistTitleColumns: false

    readonly property bool 		hideBPM: false
    readonly property bool 		hideKey: false
    readonly property bool		hideAlbumArt: false
    readonly property bool 		showArtistColumn: false
    readonly property bool 		showTrackTitleColumn: true
    readonly property int 		browserFontSize: 15
    readonly property bool 		raiseBrowserFooter: false

	//change the values below to determine the bpm text colour in the browser
	//the number values represent the percentage difference of the master tempo and the selected song
    readonly property bool 		bpmBrowserTextColor: true
    readonly property int 		browserBpmGreen: 3
    readonly property int 		browserBpmRed: 12

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	///////////////////
	//STRIPE SETTINGS//
	///////////////////

	//change to true to hide stripe
    readonly property bool 		hideStripe: false

	//change to false to disable the switching of stripes when holding shift
    readonly property bool 		shiftStripe: false

	//change to true to show the master deck's stripe when holding shift (shiftStripe must be set to true)
    readonly property bool 		shiftStripeMaster: false

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	///////////////////////////
	//TIME/BEATS BOX SETTINGS//
	///////////////////////////

	// 0 = Remaining Time, 1 = Elapsed Time, 2 = Time To Cue, 3 = Beats (0.0.0), 4 = Beats Alt (0.0), 5 = Beats To Cue (0.0.0), 6 = Beats To Cue Alt (0.0)
    readonly property int 		timeBox: 0
    readonly property int 		timeBoxShift: 1

	//set to true to have the time text change to black when the box is red.
    readonly property bool		timeTextColourChange: false

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	////////////////////////
	//VINYL BREAK SETTINGS//
	////////////////////////

	//set to false to disable vinyl break mode (play + shift)
    readonly property bool 		enableVinylBreakMode: true

	//this setting when enabled will disable the vinyl break mode when loading a new track to the deck.
    readonly property bool		resetOnDeckLoad: true

	//Change this value to the corresponding effect value for Turntable FX. This can be found in the effects section of the traktor preferences.
    readonly property int 		turntableFxNumber: 19

	//setting this to false will hide the 'break enabled' warning on screen when vinyl break mode is enabled.
    readonly property bool		showBreakWarning: true

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	////////////////////////
	//FADER START SETTINGS//
	////////////////////////

	//set this to false to disable the fader start feature on Shift + Cue
    readonly property bool		faderStartEnable: true

	//setting this to false will hide the warning indicator on screen.
    readonly property bool		showFaderStartWarning: true

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	/////////////////////////////////
	//PHASE & PHRASE METER SETTINGS//
	/////////////////////////////////

	//0 = Red, 1 = Dark Orange, 2 = Light Orange, 3 = Default, 4 = Yellow, 5 = Lime, 6 = Green, 7 = Mint, 8 = Cyan, 9 = Turquoise, 10 = Blue, 11 = Plum, 12 = Violet, 13 = Purple, 14 = Magenta, 15 = Fuchsia, 16 = White, 17 = Warm Yellow
    readonly property int 		phaseAColour:	3
    readonly property int 		phaseBColour:	3
    readonly property int 		phaseCColour:	3
    readonly property int 		phaseDColour:	3

	//change to true to hide the phase meter
    readonly property bool 		hidePhase: false

	//change to true to hide the phrase meter
    readonly property bool		hidePhrase: true

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	///////////////////
	//SLICER SETTINGS//
	///////////////////

	//set to false to disable the slicer pads
    readonly property bool 		enableSlicerPads: true

	//set to true to enable slicer mode instantly when selecting the slicer pads mode.
    readonly property bool 		enableSlicerOnFirstPress: false

	//change these values to change the default slicer size when pressing the 'samples button' (with or without shift)
	//Use values 1 to 16
    readonly property int 		defaultSlicerSize: 8
    readonly property int 		defaultSlicerSizeShift: 4

	//0 = Red, 1 = Dark Orange, 2 = Light Orange, 3 = White, 4 = Yellow, 5 = Lime, 6 = Green, 7 = Mint, 8 = Cyan, 9 = Turquoise, 10 = Blue, 11 = Plum, 12 = Violet, 13 = Purple, 14 = Magenta, 15 = Fuchsia, 16 = Black, 17 = Warm Yellow
    readonly property int 		slicerPadColour: 12

	//Change this value to modify the slicer beat size for each pad when triggering pad + shift
	//Use values 0 to 16
	//0 = off
    readonly property int 		slicerSizePad1: 1
    readonly property int 		slicerSizePad2: 2
    readonly property int 		slicerSizePad3: 3
    readonly property int 		slicerSizePad4: 4
    readonly property int 		slicerSizePad5: 5
    readonly property int 		slicerSizePad6: 6
    readonly property int 		slicerSizePad7: 7
    readonly property int 		slicerSizePad8: 8

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	//////////////////////
	//GRID EDIT SETTINGS//
	//////////////////////

	//set to true to disable the beatgrid toggle button and change it back to hold
    readonly property bool 		disableGridEditToggle: false

	//change to false to hide the bpm overlay when in grid adjust mode.
    readonly property bool 		showBPMGridAdjust: true

	//Change to false to disable the grid being deleted and reset when using Grid + Shift
    readonly property bool 		shiftGridSetsMarker: true

	//set to false to disable the grid markers being set/deleted with the flux and reverse buttons when holding shift.
    readonly property bool 		shiftFluxReverseSetsMarkers: true

	//0 = Red, 1 = Dark Orange, 2 = Light Orange, 3 = White, 4 = Yellow, 5 = Lime, 6 = Green, 7 = Mint, 8 = Cyan, 9 = Turquoise, 10 = Blue, 11 = Plum, 12 = Violet, 13 = Purple, 14 = Magenta, 15 = Fuchsia, 16 = Black, 17 = Warm Yellow
	//Change these values to change the colour of each grid edit pad
    readonly property int 		waveformZoomInColour: 6
    readonly property int 		waveformZoomOutColour: 0
    readonly property int 		tapColour: 3
    readonly property int 		tickColour: 8
    readonly property int 		unloadUnavailableColour: 0
    readonly property int 		unloadAvailableColour: 2
    readonly property int 		analyseUnavailableColour: 0
    readonly property int 		analyseAvailableColour: 17
    readonly property int 		tempoRangeUpColour: 6
    readonly property int 		tempoRangeDownColour: 0

	//this is the value in which the tempo will change each time a pad is pressed
    readonly property int 		tempoRangeChangeAmount: 2

	//These are the tempo range values that are assigned when pressing the pad with shift
    readonly property int 		shiftRange1: 0
    readonly property int 		shiftRange2: 20

	//These are the waveform zoom values that are assigned when pressing the pad with shift
    readonly property int 		shiftZoom1: 0
    readonly property int 		shiftZoom2: 20

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	///////////////////
	//HOTCUE SETTINGS//
	///////////////////

	//set to true to disable the hotcue overlay appearing
    readonly property bool 		hideHotcueOverlay: false

	//set to false to disable hotcue pad 1 setting the beat marker
    readonly property bool 		hotcue1SetsGridmarker: true

	//0 = Red, 1 = Dark Orange, 2 = Light Orange, 3 = White, 4 = Yellow, 5 = Lime, 6 = Green, 7 = Mint, 8 = Cyan, 9 = Turquoise, 10 = Blue, 11 = Plum, 12 = Violet, 13 = Purple, 14 = Magenta, 15 = Fuchsia, 16 = Warm Yellow
	//change these values to change default cue type colours.
	//This will change the cue markers and also the loop indicator.
    readonly property int 		cueCueColour: 10
    readonly property int 		cueFadeInColour: 16
    readonly property int 		cueFadeOutColour: 16
    readonly property int 		cueLoadColour: 4
    readonly property int 		cueGridColour: 3
    readonly property int 		cueLoopColour: 6

	//Set to false to disable the colour override when the cue name matches one of the setting names.
    readonly property bool 		hotcueNameColours: true

	//Cue name must be exact to the setting name, thus meaning it is case-sensitive. Colour refers to the values on the line below.
	//0 = Red, 1 = Dark Orange, 2 = Light Orange, 3 = White, 4 = Yellow, 5 = Lime, 6 = Green, 7 = Mint, 8 = Cyan, 9 = Turquoise, 10 = Blue, 11 = Plum, 12 = Violet, 13 = Purple, 14 = Magenta, 15 = Fuchsia, 16 = Warm Yellow
    readonly property string 	hotcueName1: "Name 1"
    readonly property int 		hotcueName1Colour: 11

    readonly property string 	hotcueName2: "Name 2"
    readonly property int 		hotcueName2Colour: 16

    readonly property string 	hotcueName3: "Name 3"
    readonly property int 		hotcueName3Colour: 2

    readonly property string 	hotcueName4: "Name 4"
    readonly property int 		hotcueName4Colour: 5

    readonly property string 	hotcueName5: "Name 5"
    readonly property int 		hotcueName5Colour: 15

    readonly property string 	hotcueName6: "Name 6"
    readonly property int 		hotcueName6Colour: 1

    readonly property string 	hotcueName7: "Name 7"
    readonly property int 		hotcueName7Colour: 9

    readonly property string 	hotcueName8: "Name 8"
    readonly property int 		hotcueName8Colour: 13

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	////////////////////
	//EFFECTS SETTINGS//
	////////////////////

	//set to true to revert the functionality of the FX banks to default
    readonly property bool 		resetFXFunctions: false

	//change to false to disable FX overlays
    readonly property bool 		fxOverlays: true

	//Change to true to set the fx overlays to close with a timer when the remix pads modes are enabled (instead of always being shown)
    readonly property bool		hideOverlayInRemixPads: false

	//amount of time the fx overlay will stay on the screen in ms. 1000 = 1 second.
    readonly property int 		fxOverlayTimer: 2000

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	////////////////////////
	//FX ASSIGN 1 SETTINGS//
	////////////////////////

	//set this to true to enable the assigning of FX and Parameters when pressing the fx assign buttons.
    readonly property bool		fxAssign1SetEffect: false

	//1 = Group, 2 = Single
    readonly property int		fxAssign1Type: 0

	//Select the ID's of the effects you would like to select. If single mode is enabled, 2 and 3 will be ignored.
    readonly property int		fxAssign1Effect1ID: 0
    readonly property int		fxAssign1Effect2ID: 0
    readonly property int		fxAssign1Effect3ID: 0

	//This is the value of each button. If single mode is enabled, 2 and 3 will be ignored and 1 will control the enabling of the single effect.
    readonly property bool		fxAssign1Enable1: false
    readonly property bool		fxAssign1Enable2: false
    readonly property bool		fxAssign1Enable3: false

	//This value is the parameter of the effects. Values between 0 and 100.
    readonly property int		fxAssign1DryWet: 0
    readonly property int		fxAssign1Parameter1: 0
    readonly property int		fxAssign1Parameter2: 0
    readonly property int		fxAssign1Parameter3: 0

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	////////////////////////
	//FX ASSIGN 2 SETTINGS//
	////////////////////////

	//set this to true to enable the assigning of FX and Parameters when pressing the fx assign buttons.
    readonly property bool		fxAssign2SetEffect: false

	//1 = Group, 2 = Single
    readonly property int		fxAssign2Type: 0

	//Select the ID's of the effects you would like to select. If single mode is enabled, 2 and 3 will be ignored.
    readonly property int		fxAssign2Effect1ID: 0
    readonly property int		fxAssign2Effect2ID: 0
    readonly property int		fxAssign2Effect3ID: 0

	//This is the value of each button. If single mode is enabled, 2 and 3 will be ignored and 1 will control the enabling of the single effect.
    readonly property bool		fxAssign2Enable1: false
    readonly property bool		fxAssign2Enable2: false
    readonly property bool		fxAssign2Enable3: false

	//This value is the parameter of the effects. Values between 0 and 100.
    readonly property int		fxAssign2DryWet: 0
    readonly property int		fxAssign2Parameter1: 0
    readonly property int		fxAssign2Parameter2: 0
    readonly property int		fxAssign2Parameter3: 0

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	////////////////////////
	//FX ASSIGN 3 SETTINGS//
	////////////////////////

	//set this to true to enable the assigning of FX and Parameters when pressing the fx assign buttons.
    readonly property bool		fxAssign3SetEffect: false

	//1 = Group, 2 = Single
    readonly property int		fxAssign3Type: 0

	//Select the ID's of the effects you would like to select. If single mode is enabled, 2 and 3 will be ignored.
    readonly property int		fxAssign3Effect1ID: 0
    readonly property int		fxAssign3Effect2ID: 0
    readonly property int		fxAssign3Effect3ID: 0

	//This is the value of each button. If single mode is enabled, 2 and 3 will be ignored and 1 will control the enabling of the single effect.
    readonly property bool		fxAssign3Enable1: false
    readonly property bool		fxAssign3Enable2: false
    readonly property bool		fxAssign3Enable3: false

	//This value is the parameter of the effects. Values between 0 and 100.
    readonly property int		fxAssign3DryWet: 0
    readonly property int		fxAssign3Parameter1: 0
    readonly property int		fxAssign3Parameter2: 0
    readonly property int		fxAssign3Parameter3: 0

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	////////////////////////
	//FX ASSIGN 4 SETTINGS//
	////////////////////////

	//set this to true to enable the assigning of FX and Parameters when pressing the fx assign buttons.
    readonly property bool		fxAssign4SetEffect: false

	//1 = Group, 2 = Single
    readonly property int		fxAssign4Type: 0

	//Select the ID's of the effects you would like to select. If single mode is enabled, 2 and 3 will be ignored.
    readonly property int		fxAssign4Effect1ID: 0
    readonly property int		fxAssign4Effect2ID: 0
    readonly property int		fxAssign4Effect3ID: 0

	//This is the value of each button. If single mode is enabled, 2 and 3 will be ignored and 1 will control the enabling of the single effect.
    readonly property bool		fxAssign4Enable1: false
    readonly property bool		fxAssign4Enable2: false
    readonly property bool		fxAssign4Enable3: false

	//This value is the parameter of the effects. Values between 0 and 100.
    readonly property int		fxAssign4DryWet: 0
    readonly property int		fxAssign4Parameter1: 0
    readonly property int		fxAssign4Parameter2: 0
    readonly property int		fxAssign4Parameter3: 0

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	//////////////////////////
	//EFFECTS PAD 1 SETTINGS//
	//////////////////////////

	//set to false to stop the fx bank being enabled when enabling effects pad 1.
    readonly property bool 		autoEnableFX1: true

	//set to true to disable the effects pads 1 overlay appearing
    readonly property bool		hideEffectsOverlay1: false

	//The fx unit used by fx pads 1
    readonly property int 		fx1unit: 1

	//set this setting to true to set all of the effects to toggle instead of hold
    readonly property bool 		toggleOnly1: false

	//The corresponding number of the desired effect (this can be found in the effects page of traktors preferences)
	//Set the 'fx#pad#set to true to force 'fx#pad#value' as the fx knob/parameter value.
	//Parameter values are between 0 and 100
    readonly property int fx1pad1: 1
    readonly property string fx1pad1label: "Delay"
    readonly property bool fx1pad1set: true
    readonly property real fx1pad1value: 50

    readonly property int fx1pad2: 2
    readonly property string fx1pad2label: "Reverb"
    readonly property bool fx1pad2set: true
    readonly property real fx1pad2value: 50

    readonly property int fx1pad3: 3
    readonly property string fx1pad3label: "Flanger"
    readonly property bool fx1pad3set: true
    readonly property real fx1pad3value: 25

    readonly property int fx1pad4: 6
    readonly property string fx1pad4label: "Gater"
    readonly property bool fx1pad4set: true
    readonly property real fx1pad4value: 50

    readonly property int fx1pad5: 7
    readonly property string fx1pad5label: "Beatmasher"
    readonly property bool fx1pad5set: true
    readonly property real fx1pad5value: 25

    readonly property int fx1pad6: 8
    readonly property string fx1pad6label: "Delay T3"
    readonly property bool fx1pad6set: true
    readonly property real fx1pad6value: 75

    readonly property int fx1pad7: 15
    readonly property string fx1pad7label: "Phaser"
    readonly property bool fx1pad7set: true
    readonly property real fx1pad7value: 15

    readonly property int fx1pad8: 20
    readonly property string fx1pad8label: "Iceverb"
    readonly property bool fx1pad8set: true
    readonly property real fx1pad8value: 25

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	//////////////////////////
	//EFFECTS PAD 2 SETTINGS//
	//////////////////////////

	//set to false to stop the fx bank being enabled when enabling effects pad 1.
    readonly property bool 		autoEnableFX2: true

	//set to true to disable the effects pads 2 overlay appearing
    readonly property bool		hideEffectsOverlay2: false

	//The fx unit used by fx pads 1
    readonly property int fx2unit: 2

	//set this setting to true to set all of the effects to toggle instead of hold
    readonly property bool 		toggleOnly2: false

	//The corresponding number of the desired effect (this can be found in the effects page of traktors preferences)
	//Set the 'fx#pad#set' to true to force 'fx#pad#value' as the fx knob/parameter value.
	//Parameter values are between 0 and 100

    readonly property int fx2pad1: 1
    readonly property string fx2pad1label: "Delay"
    readonly property bool fx2pad1set: true
    readonly property real fx2pad1value: 25

    readonly property int fx2pad2: 2
    readonly property string fx2pad2label: "Reverb"
    readonly property bool fx2pad2set: true
    readonly property real fx2pad2value: 50

    readonly property int fx2pad3: 23
    readonly property string fx2pad3label: "Lo-Fi"
    readonly property bool fx2pad3set: true
    readonly property real fx2pad3value: 25

    readonly property int fx2pad4: 30
    readonly property string fx2pad4label: "Ramp Delay"
    readonly property bool fx2pad4set: true
    readonly property real fx2pad4value: 25

    readonly property int fx2pad5: 8
    readonly property string fx2pad5label: "Delay T3"
    readonly property bool fx2pad5set: true
    readonly property real fx2pad5value: 50

    readonly property int fx2pad6: 20
    readonly property string fx2pad6label: "Iceverb"
    readonly property bool fx2pad6set: true
    readonly property real fx2pad6value: 15

    readonly property int fx2pad7: 32
    readonly property string fx2pad7label: "Bouncer"
    readonly property bool fx2pad7set: true
    readonly property real fx2pad7value: 50

    readonly property int fx2pad8: 26
    readonly property string fx2pad8label: "Slicer"
    readonly property bool fx2pad8set: true
    readonly property real fx2pad8value: 50

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	/////////////////////
	//TONE PAD SETTINGS//
	/////////////////////

	//set to true to disable the tone pads overlay appearing
    readonly property bool		hideToneOverlay: false

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	/////////////////////
	//LOOP PAD SETTINGS//
	/////////////////////

	//set to true to disable the loop pads overlay appearing
    readonly property bool		hideLoopOverlay: false

	//0 = Red, 1 = Dark Orange, 2 = Light Orange, 3 = White, 4 = Yellow, 5 = Lime, 6 = Green, 7 = Mint, 8 = Cyan, 9 = Turquoise, 10 = Blue, 11 = Plum, 12 = Violet, 13 = Purple, 14 = Magenta, 15 = Fuchsia, 16 = Black, 17 = Warm Yellow
    readonly property int 		loopPadColour: 6
    readonly property int 		loopBackPadColour: 0

	//Set to true to have a preset loop size when enabling a loop with the stems button.
	//0 = /32, 1 = /16, 2 = /8, 3 = /4, 4 = /2, 5 = 1, 6 = 2, 7 = 4, 8 = 8, 9 = 16, 10 = 32
    readonly property bool 		customAutoLoop: false
    readonly property int 		stemButtonLoopSize: 7

	//0 = /32, 1 = /16, 2 = /8, 3 = /4, 4 = /2, 5 = 1, 6 = 2, 7 = 4, 8 = 8, 9 = 16, 10 = 32
    readonly property int 		loopSizePad1: 3
    readonly property int 		loopSizePad2: 4
    readonly property int 		loopSizePad3: 5
    readonly property int 		loopSizePad4: 6
    readonly property int 		loopSizePad5: 7
    readonly property int 		loopSizePad6: 8
    readonly property int 		loopSizePad7: 9
    readonly property int 		loopSizePad8: 10

	//Set to true to play when triggering loop from pad when deck is not playing
    readonly property bool 		loopPadPlay: false

	//disables the loop in/out function when on loop pads mode
    readonly property bool 		resetLoopKnobs: false

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	/////////////////////
	//ROLL PAD SETTINGS//
	/////////////////////

	//set to true to disable the tone pads overlay appearing
    readonly property bool		hideRollOverlay: false

	//0 = Red, 1 = Dark Orange, 2 = Light Orange, 3 = White, 4 = Yellow, 5 = Lime, 6 = Green, 7 = Mint, 8 = Cyan, 9 = Turquoise, 10 = Blue, 11 = Plum, 12 = Violet, 13 = Purple, 14 = Magenta, 15 = Fuchsia, 16 = Black, 17 = Warm Yellow
    readonly property int 		rollPadColour: 8

	//0 = /32, 1 = /16, 2 = /8, 3 = /4, 4 = /2, 5 = 1, 6 = 2, 7 = 4, 8 = 8, 9 = 16, 10 = 32
    readonly property int 		rollSizePad1: 0
    readonly property int 		rollSizePad2: 1
    readonly property int 		rollSizePad3: 2
    readonly property int 		rollSizePad4: 3
    readonly property int 		rollSizePad5: 4
    readonly property int 		rollSizePad6: 5
    readonly property int 		rollSizePad7: 6
    readonly property int 		rollSizePad8: 7

	//Set to true to play when triggering roll from pad when deck is not playing
    readonly property bool 		rollPadPlay: true

	//Set to false to stop flux enabling when switching to the roll pads mode
    readonly property bool 		autoEnableFlux: true

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	/////////////////////
	//JUMP PAD SETTINGS//
	/////////////////////

	//set to true to enable repeating when holding on jump pads
    readonly property bool		jumpRepeat: false

	//time of each half repeat in ms. 1000 = 2 seconds.
    readonly property int		repeatTimer: 125
    readonly property bool		repeatDelay: false

	//set to true to disable the tone pads overlay appearing
    readonly property bool		hideJumpOverlay: false

	//0 = Red, 1 = Dark Orange, 2 = Light Orange, 3 = White, 4 = Yellow, 5 = Lime, 6 = Green, 7 = Mint, 8 = Cyan, 9 = Turquoise, 10 = Blue, 11 = Plum, 12 = Violet, 13 = Purple, 14 = Magenta, 15 = Fuchsia, 16 = Black, 17 = Warm Yellow
    readonly property int 		jumpPadColour: 6
    readonly property int 		jumpBackPadColour: 0

	//1 = UltraFine, 2 = Fine, 3 = 1/16, 4 = 1/8, 5 = 1/4, 6 = 1/2, 7 = 1, 8 = 2, 9 = 4, 10 = 8, 11 = 16, 12 = 32, 13 = Loop
	//-1 = -UltraFine, -2 = -Fine, -3 = -1/16, -4 = -1/8, -5 = -1/4, -6 = -1/2, -7 = -1, -8 = -2, -9 = -4, -10 = -8, -11 = -16, -12 = -32, -13 = -Loop
    readonly property int 		jumpSizePad1: 7
    readonly property int 		jumpSizePad2: 8
    readonly property int 		jumpSizePad3: 9
    readonly property int 		jumpSizePad4: 10
    readonly property int 		jumpSizePad5: -7
    readonly property int 		jumpSizePad6: -8
    readonly property int 		jumpSizePad7: -9
    readonly property int 		jumpSizePad8: -10

    readonly property int 		shiftJumpSizePad1: 5
    readonly property int 		shiftJumpSizePad2: 6
    readonly property int 		shiftJumpSizePad3: 11
    readonly property int 		shiftJumpSizePad4: 12
    readonly property int 		shiftJumpSizePad5: -5
    readonly property int 		shiftJumpSizePad6: -6
    readonly property int 		shiftJumpSizePad7: -11
    readonly property int 		shiftJumpSizePad8: -12

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	//////////////////////
	//DUPLICATE SETTINGS//
	//////////////////////

	//set to false to disable the duplicate feature
    readonly property bool 		enableDuplicate: true

	//set to true to change the duplication type to "duplicate to deck" instead of "duplicate from deck"
    readonly property bool 		duplicateTo: false

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	/////////////////
	//LOGO SETTINGS//
	/////////////////

	//set to false to disable logos
    readonly property bool 		enableLogo: true

	//these values are used to set a margin in case you need to move the logo up/down the screen. Value is in pixels.
    readonly property int 		top: 0
    readonly property int 		bottom: 0

	//If your logo does not fit the perfect aspect ratio, you can set the background colour to any value to save having black at the sides.
	//To get the exact colour of your logo's background, you can use this link: https://pinetools.com/image-color-picker
    readonly property string 	backgroundColour: "#000000"

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}
