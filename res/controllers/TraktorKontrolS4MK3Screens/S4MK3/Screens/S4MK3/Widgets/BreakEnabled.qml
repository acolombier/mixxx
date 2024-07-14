import '../../../' as CSI
import QtQuick 2.15

Item {
    anchors.fill: parent
    property int deckId: 0
    property bool fader: false

    Rectangle {
        id: bpmBackground
        width: 130
        height: 18
        color: colors.red
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
    }

    Text {
        text: "Freeze Enabled"
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
