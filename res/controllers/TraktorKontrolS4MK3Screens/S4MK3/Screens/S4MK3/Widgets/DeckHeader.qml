import QtQuick 2.5
import '../../../' as CSI
import '../../Defines' as Defines

//here we assume that `colors` and `dimensions` already exists in the object hierarchy
Item {
    id: widget

    readonly property var colors: ({black: "black", colorDeckBlueBright: "dodgerblue", colorWhite: "white", cyan: "cyan", darkOrange: "darkorange", defaultBackground: "transparent", fuchsia: "fuchsia", green: "green", lightOrange: "orange", lime: "lime", magenta: "magenta", mint: "mint", plum: "plum", purple: "purple", red: "red", turquoise: "turquoise", violet: "violet", yellow: "yellow"})

    property string title: ''
    property string artist: ''
    property color backgroundColor: colors.defaultBackground
    height: dimensions.firstRowHeight
    property int radius: 		 dimensions.cornerRadius

    Defines.Settings {id: settings}
    property int deckA: settings.deckAColour
    property int deckB: settings.deckBColour
    property int deckC: settings.deckCColour
    property int deckD: settings.deckDColour

    function colorForDeck(deckId,deckA,deckB,deckC,deckD) {
        switch (deckId) {
            case 1: return colorForDeckSingle(deckA);
            case 2: return colorForDeckSingle(deckB);
            case 3: return colorForDeckSingle(deckC);
            case 4: return colorForDeckSingle(deckD);
        }
    }

    function colorForDeckSingle(deck) {
        if (deck == 0) {return colors.red}
        else if (deck == 1) {return colors.darkOrange}
        else if (deck == 2) {return colors.lightOrange}
        else if (deck == 3) {return colors.colorWhite}
        else if (deck == 4) {return colors.yellow}
        else if (deck == 5) {return colors.lime}
        else if (deck == 6) {return colors.green}
        else if (deck == 7) {return colors.mint}
        else if (deck == 8) {return colors.cyan}
        else if (deck == 9) {return colors.turquoise}
        else if (deck == 10) {return colors.colorDeckBlueBright}
        else if (deck == 11) {return colors.plum}
        else if (deck == 12) {return colors.violet}
        else if (deck == 13) {return colors.purple}
        else if (deck == 14) {return colors.magenta}
        else if (deck == 15) {return colors.fuchsia}
        else {return colors.colorWhite};
    }

    Rectangle {
        id: headerBg
        color: colorForDeck(deckInfo.deckId,deckA,deckB,deckC,deckD)
        anchors.fill: parent
        radius: widget.radius

        Text {
            anchors.fill: parent
            anchors.leftMargin: 4
            anchors.rightMargin: 2
            anchors.topMargin:	2
            font.family: "Roboto"
            font.weight: Font.Normal
            font.pixelSize: 20
            color: colors.black
            text: widget.title
            elide: Text.ElideRight
            visible: deckInfo.shift ? false : true
        }

        Text {
            anchors.fill: parent
            anchors.leftMargin: 4
            anchors.rightMargin: 2
            anchors.topMargin:	2
            font.family: "Roboto"
            font.weight: Font.Normal
            font.pixelSize: 20
            color: colors.black
            text: widget.artist
            elide: Text.ElideRight
            visible: deckInfo.shift ? true : false
        }
    }
}
