import '../../../' as CSI
import QtQuick 2.15

Item {
    anchors.fill: parent
    property int deckId: 0

    Rectangle {
        id: bpmBackground
        width: 100
        height: 18
        color: colors.yellow
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
    }

    Text {
        text: "Fader Start"
        color: "black"
        font.pixelSize: 17
        font.family: "Pragmatica"
        anchors.fill: bpmBackground
        anchors.rightMargin: 2
        anchors.topMargin: 1
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
