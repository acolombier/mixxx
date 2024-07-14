import '../../../' as CSI
import QtQuick 2.15
import '../Defines' as Defines
import './Views' as Views
import './ViewModels' as ViewModels
import './Overlays' as Overlays

Item {
    id: deckscreen

    property int deckId: 1

    property bool active: true

  //--------------------------------------------------------------------------------------------------------------------
  // Deck Screen: show information for track, stem, remix decks
  //--------------------------------------------------------------------------------------------------------------------

  // AppProperty { id: deckType;  path: "app.traktor.decks." + deckId + ".type" }
    QtObject {
        id: deckType
        property string description: "Track Deck"
        property var value: 1
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: directThruID;  path: "app.traktor.decks." + deckId + ".direct_thru" }
    QtObject {
        id: directThruID
        property string description: "Description"
        property var value: false
        property var valueRange: ({isDiscrete: true, steps: 1})
    }

  // MappingProperty { id: propShift1;     path: "mapping.state.left.shift" }
    QtObject {
        id: propShift1
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // MappingProperty { id: propShift2;     path: "mapping.state.right.shift" }
    QtObject {
        id: propShift2
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
    readonly property bool 	isShift: 	 propShift1.value || propShift2.value

    property bool browser: settings.showBrowserOnFavorites ? ((deckInfoModel.viewButton) || (deckInfoModel.favorites)) : (deckInfoModel.viewButton)

    ViewModels.DeckInfo {
        id: deckInfoModel
        deckId: deckscreen.deckId
    }

    Component {
        id: emptyDeckComponent;

        Views.EmptyDeck {
            anchors.fill: parent
            deckInfo: deckInfoModel
        }
    }

    Component {
        id: trackDeckComponent;
        Views.TrackDeck {
            id: trackDeck
            deckInfo: deckInfoModel
            deckId: deckscreen.deckId
            anchors.fill: parent
        }
    }

    Component {
        id: browserComponent;
        Views.BrowserView {
            id: browserView
            deckInfo: deckInfoModel
            anchors.fill: parent
            isActive: (loader.sourceComponent == browserComponent) && deckscreen.active
        }
    }

    Component {
        id: stemDeckComponent;

        Views.StemDeck {
            deckInfo: deckInfoModel
            anchors.fill: parent
        }
    }

    Component {
        id: remixDeckComponent;

        Views.RemixDeck {
            deckInfo: deckInfoModel
            anchors.fill: parent
        }
    }

    Loader {
        id: loader
        active: true
        visible: true
        anchors.fill: parent
        sourceComponent: trackDeckComponent
    }

    Item {
        id: content
        state: "Empty Deck"

        Component.onCompleted: {
            content.state = Qt.binding(function() {
                    return (browser && settings.enableBrowserMode) ? "Browser" :
                        directThruID.value ? "Direct Thru"
                    : deckType.description });
        }

        states: [
            State {
                name: "Empty Deck"
                PropertyChanges { target: loader; sourceComponent: emptyDeckComponent }
            },
            State {
                name: "Track Deck"
                PropertyChanges { target: loader; sourceComponent: trackDeckComponent }
            },
            State {
                name: "Browser"
                PropertyChanges { target: loader; sourceComponent: browserComponent }
            },
            State {
                name: "Stem Deck"
                PropertyChanges { target: loader; sourceComponent: stemDeckComponent }
            },
            State {
                name: "Remix Deck"
                PropertyChanges { target: loader; sourceComponent: remixDeckComponent }
            },
            State {
                name: "Live Input"
                PropertyChanges { target: loader; sourceComponent: emptyDeckComponent }
            },
            State {
                name: "Direct Thru"
                PropertyChanges { target: loader; sourceComponent: emptyDeckComponent }
            }
        ]
    }

    Overlays.GridControls {
        id: grid
        deckId: deckInfoModel.deckId
        showHideState: !settings.hideGridOverlay && deckInfoModel.adjustEnabled && !(loader.sourceComponent == browserComponent) ? "show" : "hide"
    }

    Overlays.FX1Controls {
        id: fx1;
        showHideState: !settings.hideEffectsOverlay2 && deckInfoModel.padsModeFx1 && !(loader.sourceComponent == browserComponent) && (settings.enableVinylBreakMode ? !deckInfoModel.breakEnabled : true) ? "show" : "hide"
    }

    Overlays.FX2Controls {
        id: fx2;
        showHideState: !settings.hideEffectsOverlay2 && deckInfoModel.padsModeFx2 && !(loader.sourceComponent == browserComponent) && (settings.enableVinylBreakMode ? !deckInfoModel.breakEnabled : true) ? "show" : "hide"
    }

    Overlays.BankInfo {
        id: bank1;
        bank: 1
        showHideState: deckInfoModel.padsModeBank1 && !(loader.sourceComponent == browserComponent) && (settings.enableVinylBreakMode ? !deckInfoModel.breakEnabled : true) ? "show" : "hide"
    }

    Overlays.BankInfo {
        id: bank2;
        bank: 2
        showHideState: deckInfoModel.padsModeBank2 && !(loader.sourceComponent == browserComponent) && (settings.enableVinylBreakMode ? !deckInfoModel.breakEnabled : true) ? "show" : "hide"
    }

    Overlays.BankInfo {
        id: bank3;
        bank: 3
        showHideState: deckInfoModel.padsModeBank3 && !(loader.sourceComponent == browserComponent) && (settings.enableVinylBreakMode ? !deckInfoModel.breakEnabled : true) ? "show" : "hide"
    }

    Overlays.BankInfo {
        id: bank4;
        bank: 4
        showHideState: deckInfoModel.padsModeBank4 && !(loader.sourceComponent == browserComponent) && (settings.enableVinylBreakMode ? !deckInfoModel.breakEnabled : true) ? "show" : "hide"
    }

    Overlays.CueInfo {
        id: cue
        deckId: deckInfoModel.deckId
        hotcue: deckInfoModel.hotcueId
        type: deckInfoModel.hotcueType
        name: deckInfoModel.hotcueName
        showHideState: !settings.hideHotcueOverlay && (settings.enableVinylBreakMode ? !deckInfoModel.breakEnabled : true) && deckInfoModel.hotcueDisplay && !(loader.sourceComponent == browserComponent) ? "show" : "hide"
    }

    Overlays.JumpControls {
        id: jump;
        shift: deckInfoModel.shift
        showHideState: !settings.hideJumpOverlay && deckInfoModel.padsModeJump && !(loader.sourceComponent == browserComponent) && (settings.enableVinylBreakMode ? !deckInfoModel.breakEnabled : true) ? "show" : "hide"
    }

    Overlays.LoopControls {
        id: loop;
        deckId: deckInfoModel.deckId
        showHideState: !settings.hideLoopOverlay && deckInfoModel.padsModeLoop && !(loader.sourceComponent == browserComponent) && (settings.enableVinylBreakMode ? !deckInfoModel.breakEnabled : true) ? "show" : "hide"
    }

    Overlays.RollControls {
        id: roll;
        deckId: deckInfoModel.deckId
        showHideState: !settings.hideRollOverlay && deckInfoModel.padsModeRoll && !(loader.sourceComponent == browserComponent) && (settings.enableVinylBreakMode ? !deckInfoModel.breakEnabled : true) ? "show" : "hide"
    }

    Overlays.ToneControls {
        id: tone;
        deckId: deckInfoModel.deckId
        adjustVal: deckInfoModel.keyAdjustVal
        showHideState: !settings.hideToneOverlay && deckInfoModel.padsModeTone && !(loader.sourceComponent == browserComponent) && (settings.enableVinylBreakMode ? !deckInfoModel.breakEnabled : true) ? "show" : "hide"
    }
}
