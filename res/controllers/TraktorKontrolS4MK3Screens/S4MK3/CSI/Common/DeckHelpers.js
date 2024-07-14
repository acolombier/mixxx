
// Returns a color for the specified Deck index
/**
 *
 * @param deckIdx
 */
function colorForDeck(deckIdx) {
    switch (deckIdx) {
    case 1:
    case 2:
        // Deck A and B are color-coded in Blue
        return Color.Blue;

    case 3:
    case 4:
        // Deck C and D are color-coded in Orange
        return Color.LightOrange;
    }

    // Fall-through...
    return Color.Black;
}

// primary decks default to track, secondary decks default to remix
/**
 *
 * @param deckIdx
 */
function defaultTypeForDeck(deckIdx) {
    return (deckIdx > 2) ? DeckType.Remix : DeckType.Track;
}

/**
 *
 * @param deckType
 */
function deckTypeSupportsGridAdjust(deckType) {
    return deckType == DeckType.Track || deckType == DeckType.Stem;
}

/**
 *
 * @param deckIdx
 */
function linkedDeckIdx(deckIdx) {
    switch (deckIdx) {
    // Deck A and C are linked
    case 0: return 2;
    case 2: return 0;
    // Deck B and D are linked
    case 1: return 3;
    case 3: return 1;
    }
}
