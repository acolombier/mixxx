import "." as Skin
import Mixxx 1.0 as Mixxx
import Mixxx.Controls 1.0 as MixxxControls
import Qt5Compat.GraphicalEffects
import QtQuick 2.12
import QtQuick.Shapes
import QtQuick.Layouts
import "Theme"

Rectangle {
    id: root

    required property string group
    required property int rightColumnWidth
    property var deckPlayer: Mixxx.PlayerManager.getPlayer(group)
    readonly property var currentTrack: deckPlayer.currentTrack
    property color lineColor: Theme.deckLineColor

    border.width: 2
    border.color: Theme.deckBackgroundColor
    radius: 5
    height: 56

    Image {
        id: coverArt

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 5
        width: height
        source: root.currentTrack.coverArtUrl
        visible: false
        asynchronous: true
    }

    Rectangle {
        id: coverArtCircle

        anchors.fill: coverArt
        radius: 4
        visible: false
    }

    OpacityMask {
        anchors.fill: coverArt
        source: coverArt
        maskSource: coverArtCircle
    }

    Skin.EmbeddedText {
        id: infoBarTitle

        text: root.deckPlayer.isLoaded ? root.currentTrack.title : "No track loaded"
        anchors.top: infoBarHSeparator1.top
        anchors.left: infoBarVSeparator.left
        anchors.right: infoBarHSeparator1.left
        anchors.bottom: infoBarVSeparator.bottom
        horizontalAlignment: Text.AlignLeft
        font.bold: false
        font.italic: !root.deckPlayer.isLoaded
        font.pixelSize: Theme.textFontPixelSize
    }

    Rectangle {
        id: infoBarVSeparator

        anchors.left: coverArt.right
        anchors.right: root.right
        anchors.verticalCenter: root.verticalCenter
        anchors.margins: 5
        height: 2
        color: root.lineColor
    }

    Skin.EmbeddedText {
        id: infoBarArtist

        text: root.currentTrack.artist
        anchors.top: infoBarVSeparator.bottom
        anchors.left: infoBarVSeparator.left
        anchors.right: infoBarHSeparator1.left
        anchors.bottom: infoBarHSeparator1.bottom
        horizontalAlignment: Text.AlignLeft
        font.bold: false
        font.pixelSize: Theme.textFontPixelSize
    }

    Rectangle {
        id: infoBarHSeparator1

        anchors.top: root.top
        anchors.bottom: root.verticalCenter
        anchors.right: infoBarKey.left
        anchors.topMargin: 5
        anchors.bottomMargin: 5
        width: 2
        color: root.lineColor
    }

    Skin.EmbeddedText {
        id: infoBarKey

        text: root.currentTrack.year
        anchors.top: infoBarHSeparator1.top
        anchors.bottom: infoBarVSeparator.top
        anchors.right: infoBarHSeparator2.left
        width: root.rightColumnWidth
        visible: root.deckPlayer.isLoaded
    }

    Rectangle {
        id: infoBarHSeparator2

        anchors.top: root.top
        anchors.bottom: root.bottom
        anchors.right: infoBarStars.left
        anchors.topMargin: 5
        anchors.bottomMargin: 5
        width: 2
        color: root.lineColor
    }

    Skin.EmbeddedText {
        id: infoBarRate

        Mixxx.ControlProxy {
            id: durationControl

            group: root.group
            key: "duration"
        }

        Mixxx.ControlProxy {
            id: playPositionControl

            group: root.group
            key: "playposition"
        }

        readonly property real remaining: durationControl.value * (1 - playPositionControl.value)

        anchors.top: infoBarHSeparator2.top
        anchors.bottom: infoBarVSeparator.top
        anchors.right: root.right
        anchors.rightMargin: 5
        width: root.rightColumnWidth
        visible: root.deckPlayer.isLoaded
        text: `-${parseInt(remaining / 60).toString().padStart(2, '0')}:${parseInt(remaining % 60).toString().padStart(2, '0')}.${(remaining % 1).toFixed(1)}`
    }

    Item {
        id: infoBarStars

        property real ratio: ((rateRatioControl.value - 1) * 100).toPrecision(2)

        anchors.top: infoBarVSeparator.bottom
        anchors.bottom: infoBarHSeparator2.bottom
        anchors.right: root.right
        anchors.rightMargin: 5
        width: root.rightColumnWidth
        visible: root.deckPlayer.isLoaded

        Row {
            id: stars
            anchors.centerIn: parent
            spacing: 0
            Repeater {
                model: 5
                Shape {
                    id: star
                    antialiasing: true
                    layer.enabled: true
                    layer.samples: 4
                    // Layout.preferredWidth: 16
                    // Layout.preferredHeight: 14
                    width: 16
                    height: 14
                    ShapePath {
                        fillColor: mouse.containsMouse && !(mouse.pressedButtons & Qt.RightButton) && mouse.mouseX > star.x + stars.x ? "#3a60be" : (!mouse.containsMouse || mouse.pressedButtons & Qt.RightButton) && root.currentTrack.stars > index ? (mouse.containsMouse ? "#7D3B3B" : '#D9D9D9') : '#96d9d9d9'
                        strokeColor: 'transparent'
                        startX: 8; startY: 0
                        PathLine { x: 9.78701; y: 5.18237; }
                        PathLine { x: 15.3496; y: 5.18237; }
                        PathLine { x: 10.8494; y: 8.38525; }
                        PathLine { x: 12.5683; y: 13.5676; }
                        PathLine { x: 8.06808; y: 10.3647; }
                        PathLine { x: 3.56787; y: 13.5676; }
                        PathLine { x: 5.2868; y: 8.38525; }
                        PathLine { x: 0.786587; y: 5.18237; }
                        PathLine { x: 6.34915; y: 5.18237; }
                        PathLine { x: 8.06808; y: 0; }
                    }
                }
            }
        }
        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: (event) => {
                let selectedStars = Math.ceil((mouseX - stars.x)/16);
                if (event.button === Qt.RightButton) {
                    root.currentTrack.stars = 0
                } else if (selectedStars >= 0 && selectedStars <= 5) {
                    root.currentTrack.stars = selectedStars;
                    console.warn(root.currentTrack.stars)
                }
            }
        }
    }

    gradient: Gradient {
        orientation: Gradient.Horizontal

        GradientStop {
            position: 0
            color: {
                const trackColor = root.currentTrack.color;
                if (!trackColor.valid)
                    return Theme.deckBackgroundColor;

                return Qt.darker(root.currentTrack.color, 2);
            }
        }

        GradientStop {
            position: 1
            color: Theme.deckBackgroundColor
        }
    }
}
