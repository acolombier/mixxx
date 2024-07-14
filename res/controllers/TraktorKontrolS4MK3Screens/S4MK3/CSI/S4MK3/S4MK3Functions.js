
// Returns a color for the specified Deck index
/**
 *
 * @param deckId
 * @param deckA
 * @param deckB
 * @param deckC
 * @param deckD
 */
function colorForDeck(deckId, deckA, deckB, deckC, deckD) {
    switch (deckId) {
    case 1: return colorForDeckSingle(deckA);
    case 2: return colorForDeckSingle(deckB);
    case 3: return colorForDeckSingle(deckC);
    case 4: return colorForDeckSingle(deckD);
    }
}

/**
 *
 * @param deck
 */
function colorForDeckSingle(deck) {
    if (deck === 0) { return Color.Red; } else if (deck === 1) { return Color.DarkOrange; } else if (deck === 2) { return Color.LightOrange; } else if (deck === 3) { return Color.White; } else if (deck === 4) { return Color.Yellow; } else if (deck === 5) { return Color.Lime; } else if (deck === 6) { return Color.Green; } else if (deck === 7) { return Color.Mint; } else if (deck === 8) { return Color.Cyan; } else if (deck === 9) { return Color.Turquoise; } else if (deck === 10) { return Color.Blue; } else if (deck === 11) { return Color.Plum; } else if (deck === 12) { return Color.Violet; } else if (deck === 13) { return Color.Purple; } else if (deck === 14) { return Color.Magenta; } else if (deck === 15) { return Color.Fuchsia; } else if (deck === 16) { return Color.Black; } else if (deck === 17) { return Color.WarmYellow; } else { return Color.White; }
}

/**
 *
 * @param deck
 */
function colorForDeckSingle2(deck) {
    if (deck === 0) { return Color.Red; } else if (deck === 1) { return Color.DarkOrange; } else if (deck === 2) { return Color.LightOrange; } else if (deck === 3) { return Color.White; } else if (deck === 4) { return Color.Yellow; } else if (deck === 5) { return Color.Lime; } else if (deck === 6) { return Color.Green; } else if (deck === 7) { return Color.Mint; } else if (deck === 8) { return Color.Cyan; } else if (deck === 9) { return Color.Turquoise; } else if (deck === 10) { return Color.Blue; } else if (deck === 11) { return Color.Plum; } else if (deck === 12) { return Color.Violet; } else if (deck === 13) { return Color.Purple; } else if (deck === 14) { return Color.Magenta; } else if (deck === 15) { return Color.Fuchsia; } else if (deck === 16) { return Color.WarmYellow; } else { return Color.White; }
}

/**
 *
 * @param key
 * @param masterKey
 */
function colorKey(key, masterKey) {
    if (key === "1m" || "1M") { if (masterKey === "12m" || "12M" || "2m" || "2M") { return true; } } else { return false; }
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
    return deckType === DeckType.Track || deckType === DeckType.Stem;
}

/**
 *
 * @param val
 */
function select(val) {
    return Math.round(val * 45);
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
