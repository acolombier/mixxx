import QtQuick 2.5
import '../../../' as CSI
import '../../Defines' as Defines

Item {
    id: widget

    height: 16

    property int deck: 1
    property int master: 1

    property int deckId: 1
    property int masterId: 1

    property color backgroundColor: colors.grayBackground

	// Background
    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: 3
        color: widget.backgroundColor
    }

    // Phrase Bar
    Rectangle {
        color: deck == 1 ? (deckId == masterId ? "green" : "white") : colors.grayBackground
        border.color: master == 1 ? "green" : "black"
        border.width: 3
        height: parent.height
        width: 78
        x: 0
        radius: 3
    }

    // Phrase Bar
    Rectangle {
        color: deck == 2 ? (deckId == masterId ? "green" : "white") : colors.grayBackground
        border.color: master == 2 ? "green" : "black"
        border.width: 3
        height: parent.height
        width: 78
        x: 79
        radius: 3
    }

    // Phrase Bar
    Rectangle {
        color: deck == 3 ? (deckId == masterId ? "green" : "white") : colors.grayBackground
        border.color: master == 3 ? "green" : "black"
        border.width: 3
        height: parent.height
        width: 79
        x: 158
        radius: 3
    }

    // Phrase Bar
    Rectangle {
        color: deck == 4 ? (deckId == masterId ? "green" : "white") : colors.grayBackground
        border.color: master == 4 ? "green" : "black"
        border.width: 3
        height: parent.height
        width: 78
        x: 238
        radius: 3
    }
}
