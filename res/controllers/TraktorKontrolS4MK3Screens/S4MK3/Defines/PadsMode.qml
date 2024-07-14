pragma Singleton

import QtQuick 2.15
import '..' as CSI

QtObject {
    readonly property int disabled: 0
    readonly property int hotcues: 1
    readonly property int remix: 2
    readonly property int stems: 3
    readonly property int freeze: 4
    readonly property int loop: 5
    readonly property int favorite: 6
    readonly property int roll: 7
    readonly property int jump: 8
    readonly property int fx1:	 9
    readonly property int fx2:	 10
    readonly property int tone:	 11
    readonly property int fxBank1: 12
    readonly property int fxBank2: 13
    readonly property int fxBank3: 14
    readonly property int fxBank4: 15

    function isPadsModeSupported(padMode, deckType) {
        switch(padMode) {
            case disabled:
                return deckType == DeckType.Live
            case hotcues:
                return deckType == DeckType.Stem || deckType == DeckType.Track;
            case remix:
                return deckType == DeckType.Remix;
            case stems:
                return deckType == DeckType.Stem;
            case freeze:
                return deckType == DeckType.Stem || deckType == DeckType.Track;
            case loop:
                return deckType != DeckType.Live || deckType == DeckType.Stem || deckType == DeckType.Track || deckType == DeckType.Remix;
            case jump:
                return deckType != DeckType.Live || deckType == DeckType.Stem || deckType == DeckType.Track || deckType == DeckType.Remix;
            case favorite:
                return deckType == DeckType.Live || deckType == DeckType.Stem || deckType == DeckType.Track || deckType == DeckType.Remix;
            case roll:
                return deckType != DeckType.Live || deckType == DeckType.Stem || deckType == DeckType.Track || deckType == DeckType.Remix;
            case fx1:
                return deckType != DeckType.Live || deckType == DeckType.Stem || deckType == DeckType.Track || deckType == DeckType.Remix;
            case fx2:
                return deckType != DeckType.Live || deckType == DeckType.Stem || deckType == DeckType.Track || deckType == DeckType.Remix;
            case tone:
                return deckType != DeckType.Live || deckType == DeckType.Stem || deckType == DeckType.Track;
            case fxBank1:
                return deckType != DeckType.Live || deckType == DeckType.Stem || deckType == DeckType.Track || deckType == DeckType.Remix;
            case fxBank2:
                return deckType != DeckType.Live || deckType == DeckType.Stem || deckType == DeckType.Track || deckType == DeckType.Remix;
            case fxBank3:
                return deckType != DeckType.Live || deckType == DeckType.Stem || deckType == DeckType.Track || deckType == DeckType.Remix;
            case fxBank4:
                return deckType != DeckType.Live || deckType == DeckType.Stem || deckType == DeckType.Track || deckType == DeckType.Remix;
        }
    }

    function defaultPadsModeForDeck(deckType) {

        switch(deckType) {
            case DeckType.Stem:
                return stems;
            case DeckType.Remix:
                return remix;
            case DeckType.Track:
                return hotcues;
            case DeckType.Live:
                default:
                    return disabled;
        }
    }
}
