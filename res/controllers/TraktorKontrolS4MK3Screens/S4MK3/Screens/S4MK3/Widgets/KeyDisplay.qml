import '../../../' as CSI
import '../Views'
import QtQuick 2.15

Item {
    anchors.fill: parent

    Colors {
        id: colors
        Component.onCompleted: {
            keyBackground.color = Qt.binding(function() { return deckInfo.isKeyLockOn ? colors.musicalKeyColors[deckInfo.keyIndex] : colors.musicalKeyDarkColors[deckInfo.keyIndex]; })
        }
    }

  // AppProperty { id: loopEnabled; path: "app.traktor.decks." + (parent.deckId) + ".loop.active" }
    QtObject {
        id: loopEnabled
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: loopSizePos; path: "app.traktor.decks." + (parent.deckId) + ".loop.size";          }
    QtObject {
        id: loopSizePos
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }

    property int deckId: 0

    Rectangle {
        id: keyBackground
        width: 60
        height: 20
    // color:    'red'
        // color: deckInfo.isKeyLockOn ? colors.musicalKeyColors[deckInfo.keyIndex] : colors.musicalKeyDarkColors[deckInfo.keyIndex]
        anchors.right: parent.right
        anchors.top: parent.top
        Rectangle {
            id: keyBorder
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: keyBackground.width -2
            height: keyBackground.height -2
            color: "transparent"
            border.color: colors.defaultBackground
            border.width: 2
        }
    }

    Text {
        text: deckInfo.hasKey && (deckInfo.keyAdjustString != "-0") && (deckInfo.keyAdjustString != "+0") ? (settings.camelotKey ? utils.camelotConvert(deckInfo.keyString) : deckInfo.keyString) + deckInfo.keyAdjustString
        : deckInfo.hasKey ? (settings.camelotKey ? utils.camelotConvert(deckInfo.keyString) : deckInfo.keyString)
        : "No key"
        color: deckInfo.isKeyLockOn ? "black" : "white"
        font.pixelSize: 15
        font.family: "Pragmatica"
        anchors.fill: keyBackground
        anchors.rightMargin: 2
        anchors.topMargin: 1
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
