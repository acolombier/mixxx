import "." as Skin
import Mixxx 1.0 as Mixxx
import QtQuick 2.12
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import QtQuick.Dialogs
import Qt5Compat.GraphicalEffects
import "Theme"

Item {
    id: root
    property string selectedTab: "waveform"

    Repeater {
        id: themeColor
        anchors.fill: parent

        model: selectedTab == "theme & colour" ? 1 : 0

        RowLayout {
            id: theme
            anchors.fill: parent
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                Layout.topMargin: 30
                RowLayout {
                    Text {
                        Layout.fillWidth: true
                        text: "Skin"
                        color: "#D9D9D9"
                        font.pixelSize: 14
                    }
                    RatioChoice {
                        options: [
                                  "on",
                                  "off"
                        ]
                    }
                }
                RowLayout {
                    Text {
                        Layout.fillWidth: true
                        text: "Style"
                        color: "#D9D9D9"
                        font.pixelSize: 14
                    }
                    RatioChoice {
                        options: [
                                  "mono",
                                  "stereo"
                        ]
                    }
                }
                RowLayout {
                    Text {
                        Layout.fillWidth: true
                        text: "Tool tips"
                        color: "#D9D9D9"
                        font.pixelSize: 14
                    }
                    RatioChoice {
                        options: [
                                  "soundcard",
                                  "network"
                        ]
                    }
                }
                RowLayout {
                    Text {
                        Layout.fillWidth: true
                        text: "Disable screen saver"
                        color: "#D9D9D9"
                        font.pixelSize: 14
                    }
                    Skin.ComboBox {
                        spacing: 2
                        // indicator.width: 0
                        // popupWidth: 150
                        clip: true

                        font.pixelSize: 12
                        model: [
                                "11.6 ms",
                                "23.2 ms",
                                "46.4 ms",
                                "92.8 ms"
                        ]
                    }
                }
                RowLayout {
                    Text {
                        Layout.fillWidth: true
                        text: "Start in full-screen mode"
                        color: "#D9D9D9"
                        font.pixelSize: 14
                    }
                    Skin.ComboBox {
                        spacing: 2
                        // indicator.width: 0
                        // popupWidth: 150
                        clip: true

                        font.pixelSize: 12
                        model: [
                                "Main output only",
                                "Main and booth outputs",
                                "Direct monitor (recording and broadcasting only)"
                        ]
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    ColumnLayout {
                        Layout.fillWidth: true
                        Text {
                            Layout.fillWidth: true
                            text: "Auto-hide the menu bar"
                            color: "#D9D9D9"
                            font.pixelSize: 14
                        }
                        Text {
                            text: "Toggle it with a single Alt key press"
                            color: "#D9D9D9"
                            font.pixelSize: 12
                            font.italic: true
                            font.weight: Font.Thin
                        }
                    }
                    RatioChoice {
                        options: [
                                  "on",
                                  "off"
                        ]
                    }
                }
            }
        }
    }
    Repeater {
        anchors.fill: parent

        model: selectedTab == "waveform" ? 1 : 0

        Item {
            id: waveformTab
            readonly property real playMarkerPosition: playMarkerPositionInput.value
            readonly property real defaultZoom: defaultZoomInput.value / 10
            readonly property real beatgridOpacity: beatgridOpacityInput.value / 100
            anchors.fill: parent
            ColumnLayout {
                anchors {
                    top: parent.top
                    topMargin: 15
                    // bottom: parent.bottom
                    left: parent.left
                    right: parent.horizontalCenter
                    rightMargin: 8
                }
                GridLayout {
                    columns: 2
                    rowSpacing: 10
                    Text {
                        Layout.fillWidth: true
                        text: "End of track warning"
                        color: "#D9D9D9"
                        font.pixelSize: 14
                    }
                    Skin.Slider {
                        Layout.fillWidth: true
                        markers: ["0s", "10s", "30s", "60s", "120s"]
                        suffix: "sec"
                        value: 30
                        slider.to: 120
                    }
                    Text {
                        Layout.fillWidth: true
                        text: "Beat grid opacity"
                        color: "#D9D9D9"
                        font.pixelSize: 14
                    }
                    Skin.Slider {
                        id: beatgridOpacityInput
                        Layout.fillWidth: true
                        markers: ["0%", "50%", "100%"]
                        suffix: "%"
                        value: 50
                        slider.to: 100
                    }
                    Text {
                        Layout.fillWidth: true
                        text: "Default zoom level"
                        color: "#D9D9D9"
                        font.pixelSize: 14
                    }
                    Skin.Slider {
                        id: defaultZoomInput
                        Layout.fillWidth: true
                        markers: ["0%", "50%", "100%"]
                        suffix: "%"
                        value: 60
                        slider.to: 100
                    }
                }
                ColumnLayout {
                    RowLayout {
                        Text {
                            Layout.fillWidth: true
                            text: "Synchronise zoom level across waveform"
                            color: "#D9D9D9"
                            font.pixelSize: 14
                        }
                        RatioChoice {
                            options: [
                                      "on",
                                      "off"
                            ]
                        }
                    }
                    RowLayout {
                        Text {
                            Layout.fillWidth: true
                            text: "Normalise waveform overview"
                            color: "#D9D9D9"
                            font.pixelSize: 14
                        }
                        RatioChoice {
                            options: [
                                      "on",
                                      "off"
                            ]
                        }
                    }
                }
            }
            ColumnLayout {
                anchors {
                    top: parent.top
                    topMargin: 15
                    // bottom: parent.bottom
                    right: parent.right
                    left: parent.horizontalCenter
                    leftMargin: 8
                }
                ComboBox {
                    id: waveformDropdown

                    Layout.fillWidth: true
                    Layout.preferredHeight: 102

                    model: ["Filtered", "HSV", "RGB", "Simple", "Stacked"]
                    currentIndex: 2

                    property var track: Mixxx.Library.model.getTrack(Mixxx.Library.model.length * Math.random())
                    property double playbackProgress: 0.2

                    property var backgroundColor: "#0F0F0E"
                    property var axesColor: '#a1a1a1a1'
                    property var lowColor: '#2154D7'
                    property var midColor: '#97632D'
                    property var highColor: '#D5C2A2'

                    property var gainAll: 1.0
                    property var gainLow: 1.0
                    property var gainMid: 1.0
                    property var gainHigh: 1.0

                    property var filteredRenderer: Mixxx.WaveformRendererFiltered {
                        axesColor: waveformDropdown.axesColor
                        lowColor: waveformDropdown.lowColor
                        midColor: waveformDropdown.midColor
                        highColor: waveformDropdown.midColor

                        gainAll: waveformDropdown.gainAll
                        gainLow: waveformDropdown.gainLow
                        gainMid: waveformDropdown.gainMid
                        gainHigh: waveformDropdown.gainHigh

                        ignoreStem: true
                    }
                    property var hsvRenderer: Mixxx.WaveformRendererHSV {
                        axesColor: waveformDropdown.axesColor
                        color: waveformDropdown.lowColor

                        gainAll: waveformDropdown.gainAll
                        gainLow: waveformDropdown.gainLow
                        gainMid: waveformDropdown.gainMid
                        gainHigh: waveformDropdown.gainHigh

                        ignoreStem: true
                    }
                    property var rgbRenderer: Mixxx.WaveformRendererRGB {
                        axesColor: waveformDropdown.axesColor
                        lowColor: waveformDropdown.lowColor
                        midColor: waveformDropdown.midColor
                        highColor: waveformDropdown.highColor

                        gainAll: waveformDropdown.gainAll
                        gainLow: waveformDropdown.gainLow
                        gainMid: waveformDropdown.gainMid
                        gainHigh: waveformDropdown.gainHigh

                        ignoreStem: true
                    }
                    property var simpleRenderer: Mixxx.WaveformRendererSimple {
                        axesColor: waveformDropdown.axesColor
                        color: waveformDropdown.midColor
                        gain: waveformDropdown.gainAll
                        ignoreStem: true
                    }
                    property var stackedRenderer: Mixxx.WaveformRendererFiltered {
                        stacked: true
                        axesColor: waveformDropdown.axesColor
                        lowColor: waveformDropdown.lowColor
                        midColor: waveformDropdown.midColor
                        highColor: waveformDropdown.highColor

                        gainAll: waveformDropdown.gainAll
                        gainLow: waveformDropdown.gainLow
                        gainMid: waveformDropdown.gainMid
                        gainHigh: waveformDropdown.gainHigh

                        ignoreStem: true
                    }
                    property var beatsRenderer: Mixxx.WaveformRendererBeat {
                        color: Qt.alpha('#a1a1a1', waveformTab.beatgridOpacity)
                        onColorChanged: {
                            console.log(`changed ${color}`)
                        }
                    }

                    Timer {
                        interval: 20; running: true; repeat: true
                        onTriggered: {
                            waveformDropdown.playbackProgress += interval / 500 / waveformDropdown.track.duration
                            if (waveformDropdown.playbackProgress > 0.8) {
                                waveformDropdown.playbackProgress = 0.2
                            }
                        }
                    }

                    delegate: ItemDelegate {
                        id: control

                        required property int index
                        width: parent.width
                        height: 99
                        highlighted: waveformDropdown.highlightedIndex === this.index

                        ColumnLayout {
                            anchors.fill: parent
                            Item {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                Mixxx.WaveformDisplay {
                                    id: waveform
                                    visible: false
                                    anchors.fill: parent
                                    zoom: waveformTab.defaultZoom
                                    backgroundColor: "#0F0F0E"

                                    track: waveformDropdown.track
                                    position: waveformDropdown.playbackProgress

                                    renderers: [
                                                (index == 0 ? waveformDropdown.filteredRenderer :
                                                    index == 1 ? waveformDropdown.hsvRenderer :
                                                    index == 2 ? waveformDropdown.rgbRenderer :
                                                    index == 3 ? waveformDropdown.simpleRenderer :
                                                    waveformDropdown.stackedRenderer),
                                                waveformDropdown.beatsRenderer
                                    ]
                                }
                                InnerShadow {
                                    id: effect1
                                    anchors.fill: parent
                                    source: waveform
                                    spread: 0.2
                                    radius: 24
                                    samples: 24
                                    horizontalOffset: 4
                                    verticalOffset: 4
                                    color: control.highlighted ? "#575757" : "#000000"
                                }
                                InnerShadow {
                                    anchors.fill: parent
                                    source: effect1
                                    spread: 0.2
                                    radius: 24
                                    samples: 24
                                    horizontalOffset: -4
                                    verticalOffset: -4
                                    color: control.highlighted ? "#575757" : "#000000"
                                }
                            }
                            Text {
                                Layout.bottomMargin: 5
                                Layout.leftMargin: 5
                                text: waveformDropdown.model[index]
                                color: "#FFFFFF"
                            }
                        }

                        background: Rectangle {
                            radius: 5
                            color: control.pressed || control.highlighted ? "#575757" : "#000000"
                        }
                    }

                    onActivated: (selectedIndex) => {
                        currentIndex = selectedIndex
                    }

                    contentItem: Rectangle {
                        color: '#00000000'
                        ColumnLayout {
                            anchors.fill: parent
                            Item {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                property var markRenderer: Mixxx.WaveformRendererMark {
                                    playMarkerColor: '#D9D9D9'
                                    playMarkerBackground: '#D9D9D9'
                                    playMarkerPosition: waveformTab.playMarkerPosition
                                    defaultMark: Mixxx.WaveformMark {
                                        align: "bottom|right"
                                        color: "#00d9ff"
                                        textColor: "#1a1a1a"
                                        text: " %1 "
                                    }

                                    untilMark.showTime: false
                                    untilMark.showBeats: false
                                }
                                Mixxx.WaveformDisplay {
                                    id: waveform
                                    visible: false
                                    anchors.fill: parent
                                    zoom: waveformTab.defaultZoom
                                    backgroundColor: "#0F0F0E"

                                    track: waveformDropdown.track
                                    position: waveformDropdown.playbackProgress

                                    renderers: [
                                                (waveformDropdown.currentIndex == 0 ? waveformDropdown.filteredRenderer :
                                                    waveformDropdown.currentIndex == 1 ? waveformDropdown.hsvRenderer :
                                                    waveformDropdown.currentIndex == 2 ? waveformDropdown.rgbRenderer :
                                                    waveformDropdown.currentIndex == 3 ? waveformDropdown.simpleRenderer :
                                                    waveformDropdown.stackedRenderer),
                                                waveformDropdown.beatsRenderer,
                                                parent.markRenderer
                                    ]
                                }
                                InnerShadow {
                                    id: effect1
                                    anchors.fill: parent
                                    source: waveform
                                    spread: 0.2
                                    radius: 24
                                    samples: 24
                                    horizontalOffset: 2
                                    verticalOffset: 4
                                    color: "#000000"
                                }
                                InnerShadow {
                                    anchors.fill: parent
                                    source: effect1
                                    spread: 0.2
                                    radius: 24
                                    samples: 24
                                    horizontalOffset: -2
                                    verticalOffset: -4
                                    color: "#000000"
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    Layout.fillWidth: true
                                    Layout.margins: 5
                                    text: waveformDropdown.currentText
                                    color: "#FFFFFF"
                                }
                                Repeater {
                                    model: waveformDropdown.currentIndex != 3 ? [waveformDropdown.lowColor, waveformDropdown.midColor, waveformDropdown.highColor] : [waveformDropdown.midColor]
                                    Rectangle {
                                        required property color modelData
                                        required property int index

                                        Layout.margins: 1
                                        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                                        width: 15
                                        height: 15
                                        radius: 2
                                        color: modelData

                                        ColorDialog {
                                            id: colorDialog
                                            title: "Please choose a color"
                                            onAccepted: {
                                                if (index == 0) {
                                                    waveformDropdown.lowColor = Qt.color(selectedColor);
                                                } else if (index == 1) {
                                                    waveformDropdown.midColor = Qt.color(selectedColor);
                                                } else {
                                                    waveformDropdown.highColor = Qt.color(selectedColor);
                                                }
                                            }
                                            selectedColor: modelData
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onPressed: {
                                                colorDialog.open()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        // leftPadding: 5
                        // rightPadding: waveformDropdown.indicator.width + waveformDropdown.spacing
                    }

                    background: Rectangle {
                        radius: 5
                        // border.width: control.highlighted ?  1 : 0
                        // border.color: Theme.deckLineColor
                        color: "#000000"
                    }

                    // Text {
                    //     leftPadding: 5
                    //     rightPadding: waveformDropdown.indicator.width + waveformDropdown.spacing
                    //     text: waveformDropdown.displayText
                    //     font: waveformDropdown.font
                    //     color: Theme.deckTextColor
                    //     verticalAlignment: Text.AlignVCenter
                    //     elide: waveformDropdown.clip ? Text.ElideNone : Text.ElideRight
                    //     clip: waveformDropdown.clip
                    // }

                    popup: Popup {
                        id: popup
                        x: waveformDropdown.x + 27
                        y: waveformDropdown.height + 13
                        width: waveformDropdown.width - 27
                        implicitHeight: contentItem.implicitHeight

                        contentItem: ListView {
                            clip: true
                            anchors.fill: parent
                            implicitHeight: contentHeight
                            model: waveformDropdown.popup.visible ? waveformDropdown.delegateModel : null
                            currentIndex: waveformDropdown.highlightedIndex

                            ScrollIndicator.vertical: ScrollIndicator {
                            }
                        }

                        background: Rectangle {
                            border.width: 0
                            radius: 8
                            color: '#000000'
                        }
                    }
                }
                Skin.Slider {
                    id: playMarkerPositionInput
                    Layout.fillWidth: true
                    Layout.topMargin: 15
                    Layout.preferredHeight: 23

                    markers: ["0%", "50%", "100%"]

                    value: 0.5
                }
                Text {
                    Layout.topMargin: 10
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    text: "Play marker position"
                    color: "#D9D9D9"
                    font.pixelSize: 14
                }
            }
        }
    }
}
