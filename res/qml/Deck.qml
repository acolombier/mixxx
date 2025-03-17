import "." as Skin
import Mixxx 1.0 as Mixxx
import Mixxx.Controls 1.0 as MixxxControls
import Qt5Compat.GraphicalEffects
import QtQuick 2.12
import QtQuick.Layouts
import QtQuick.Shapes
import QtQuick.Controls 2.12
import "Theme"

Item {
    id: root

    required property string group
    property bool minimized: false
    property var deckPlayer: Mixxx.PlayerManager.getPlayer(group)
    readonly property var currentTrack: deckPlayer.currentTrack

    Drag.active: dragArea.drag.active
    Drag.dragType: Drag.Automatic
    Drag.supportedActions: Qt.CopyAction
    Drag.mimeData: {
        let data = {
            "mixxx/player": group
        };
        const trackLocationUrl = currentTrack.trackLocationUrl;
        if (trackLocationUrl)
            data["text/uri-list"] = trackLocationUrl;

        return data;
    }

    Mixxx.ControlProxy {
        id: trackLoadedControl

        group: root.group
        key: "track_loaded"
    }

    MouseArea {
        id: dragArea

        anchors.fill: root
        drag.target: root
    }

    Skin.SectionBackground {
        anchors.fill: parent
    }

    Skin.DeckInfoBar {
        id: infoBar

        anchors.leftMargin: 5
        anchors.topMargin: 5
        anchors.rightMargin: 5
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        group: root.group
        rightColumnWidth: 105
    }

    RowLayout {
        id: deckControl
        anchors {
            top: infoBar.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            leftMargin: 5
            rightMargin: 5
            bottomMargin: 5
        }

        visible: !root.minimized

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: 3
            Rectangle {
                Layout.fillWidth: true
                Layout.minimumHeight: 56
                id: overview

                visible: !root.minimized
                radius: 5
                color: Theme.deckBackgroundColor
                height: 50

                Skin.WaveformOverview {
                    group: root.group
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: parent.height
                }

                FadeBehavior on visible {
                    fadeTarget: overview
                }
            }

            Item {
                id: spacerOverview
                Layout.fillHeight: true
            }

            RowLayout {
                ColumnLayout {
                    Layout.minimumWidth: 60

                    Skin.ControlButton {
                        id: cueButton

                        implicitWidth: 60
                        implicitHeight: 60

                        group: root.group
                        key: "play"
                        toggleable: true
                        contentItem: Item {
                            Shape {
                                anchors.top: parent.top
                                anchors.topMargin: 6
                                anchors.horizontalCenter: parent.horizontalCenter
                                antialiasing: true
                                layer.enabled: true
                                layer.samples: 4
                                width: 30
                                height: 32
                                ShapePath {
                                    fillColor: '#D9D9D9'
                                    startX: 5; startY: 0
                                    fillRule: ShapePath.WindingFill
                                    capStyle: ShapePath.RoundCap
                                    PathLine { x: 30; y: 16 }
                                    PathLine { x: 5; y: 32 }
                                    PathLine { x: 5; y: 0 }
                                }
                            }
                            Label {
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 4
                                anchors.horizontalCenter: parent.horizontalCenter

                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.family: Theme.fontFamily
                                font.capitalization: Font.AllUppercase
                                font.bold: true
                                font.pixelSize: Theme.buttonFontPixelSize
                                text: "Play"
                                color: '#626262'
                            }
                        }
                        activeColor: Theme.deckActiveColor
                    }

                    Skin.ControlButton {
                        id: playButton

                        implicitWidth: 60
                        implicitHeight: 60

                        group: root.group
                        key: "cue_default"
                        text: "Cue"
                        activeColor: Theme.deckActiveColor
                    }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    RowLayout {
                        Layout.fillHeight: true
                        Skin.ControlButton {
                            id: reverseButton

                            implicitWidth: 22
                            implicitHeight: 22

                            group: root.group
                            key: "reverse"
                            contentItem: Shape {
                                anchors.fill: parent
                                antialiasing: true
                                layer.enabled: true
                                layer.samples: 4
                                ShapePath {
                                    fillColor: '#D9D9D9'
                                    startX: 5; startY: 11
                                    PathLine { x: 20; y: 4 }
                                    PathLine { x: 20; y: 18 }
                                    PathLine { x: 5; y: 11 }
                                }
                            }
                            activeColor: Theme.deckActiveColor
                        }
                        Item {
                            Layout.fillWidth: true
                            id: spacer
                        }
                        Skin.Button {
                            id: beatgridButton
                            text: "Beatgrid"
                        }
                        Skin.Button {
                            id: keylockButton
                            text: "Keylock"
                        }
                        Skin.ControlButton {
                            id: ejectButton

                            implicitWidth: 22
                            implicitHeight: 22

                            group: root.group
                            key: "eject"
                            contentItem: Item {
                                anchors.fill: parent
                                Shape {
                                    anchors {
                                        top: parent.top
                                        topMargin: 5
                                        horizontalCenter: parent.horizontalCenter
                                    }
                                    width: 15
                                    height: 10
                                    antialiasing: true
                                    layer.enabled: true
                                    layer.samples: 4
                                    ShapePath {
                                        fillColor: '#D9D9D9'
                                        startX: 7.5; startY: 0
                                        PathLine { x: 15; y: 10 }
                                        PathLine { x: 0; y: 10 }
                                        PathLine { x: 7.5; y: 0 }
                                    }
                                }
                                Rectangle {
                                    width: 15
                                    height: 2
                                    color: '#D9D9D9'
                                    anchors {
                                        bottom: parent.bottom
                                        bottomMargin: 3
                                        horizontalCenter: parent.horizontalCenter
                                    }
                                }
                            }
                            activeColor: Theme.deckActiveColor
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.maximumHeight: 92

                        Mixxx.ControlProxy {
                            id: stemCountControl

                            group: root.group
                            key: "stem_count"
                        }

                        Rectangle {
                            Layout.minimumWidth: 60
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            id: hotcueStemTab
                            color: '#0E0E0E'

                            states: [
                                State {
                                    name: "inactive"
                                    when: trackLoadedControl.value == 0

                                    PropertyChanges {
                                        target: hotcueTabButton
                                        checked: false
                                        opacity: 0.75
                                    }

                                    PropertyChanges {
                                        target: stemTabButton
                                        checked: false
                                        opacity: 0.75
                                    }

                                    PropertyChanges {
                                        target: stemTab
                                        visible: false
                                    }

                                    PropertyChanges {
                                        target: hotcueTab
                                        visible: false
                                    }
                                },
                                State {
                                    name: "hotcue"
                                    when: hotcueTabButton.checked || stemCountControl.value == 0

                                    PropertyChanges {
                                        target: hotcueTab
                                        visible: true
                                    }

                                    PropertyChanges {
                                        target: stemTab
                                        visible: false
                                    }
                                },
                                State {
                                    name: "stem"
                                    when: stemTabButton.checked && stemCountControl.value != 0

                                    PropertyChanges {
                                        target: stemTab
                                        visible: true
                                    }

                                    PropertyChanges {
                                        target: hotcueTab
                                        visible: false
                                    }
                                }
                            ]

                            Item {
                                id: hotcueTab
                                anchors.fill: parent
                                visible: false
                                GridLayout {
                                    rowSpacing: 6
                                    columnSpacing: 6
                                    anchors.fill: parent
                                    anchors.leftMargin: 16
                                    anchors.rightMargin: 16
                                    anchors.topMargin: 8
                                    anchors.bottomMargin: 8
                                    Repeater {
                                        model: 8
                                        Item {
                                            required property int index

                                            Skin.Hotcue {
                                                id: hotcue

                                                readonly property string label: isSet ? root.currentTrack.hotcuesModel.get(index).label : null

                                                group: root.group
                                                hotcueNumber: index + 1
                                                activate: activator.pressedButtons == Qt.LeftButton
                                                // onIsSetChanged: {
                                                //     if (!isSet)
                                                //         popup.close();
                                                // }
                                            }
                                            Layout.column: index % 4
                                            Layout.row: parseInt(index / 4)
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            Rectangle {
                                                id: backgroundImage

                                                anchors.fill: parent
                                                color: hotcue.isSet ? hotcue.color : '#2B2B2B'

                                                MouseArea {
                                                    anchors.fill: parent
                                                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                                                    id: activator
                                                }
                                            }

                                            DropShadow {
                                                id: effect1
                                                anchors.fill: backgroundImage
                                                source: backgroundImage
                                                horizontalOffset: 0
                                                verticalOffset: 0
                                                radius: 1.0
                                                color: "#80000000"
                                            }
                                            InnerShadow {
                                                id: effect2
                                                anchors.fill: parent
                                                source: effect1
                                                spread: 0.2
                                                radius: 12
                                                samples: 24
                                                horizontalOffset: 1
                                                verticalOffset: 1
                                                color: "#353535"
                                            }
                                            InnerShadow {
                                                anchors.fill: parent
                                                source: effect2
                                                spread: 0.2
                                                radius: 12
                                                samples: 24
                                                horizontalOffset: -1
                                                verticalOffset: -1
                                                color: "#353535"
                                            }
                                            ColumnLayout {
                                                anchors.centerIn: backgroundImage
                                                spacing: 0
                                                Label {
                                                    Layout.alignment: Qt.AlignHCenter
                                                    text: `${index+1}`
                                                    color: "#626262"
                                                    font.weight: Font.Bold
                                                    font.pixelSize: 14
                                                }
                                                Label {
                                                    Layout.alignment: Qt.AlignHCenter
                                                    visible: hotcue.label
                                                    text: hotcue.label
                                                    color: "#626262"
                                                    font.pixelSize: 12
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            Item {
                                id: stemTab
                                anchors.fill: parent
                                visible: false
                                RowLayout {
                                    spacing: 9
                                    anchors.fill: parent
                                    anchors.leftMargin: 9
                                    anchors.rightMargin: 9
                                    anchors.topMargin: 6
                                    anchors.bottomMargin: 6
                                    Repeater {
                                        model: root.currentTrack.stemsModel
                                        Item {
                                            id: stem
                                            required property int index
                                            required property string label
                                            required property color color
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            readonly property string group: `${root.group.substr(0, root.group.length-1)}_Stem${index + 1}]`
                                            readonly property string fxGroup: `[QuickEffectRack1_${group}]`

                                            Item {
                                                id: content
                                                anchors.fill: parent
                                                visible: false
                                                Rectangle {
                                                    id: backgroundColor

                                                    anchors.fill: parent
                                                    radius: 1
                                                    opacity: 0.75
                                                    color: stem.color
                                                }
                                            }

                                            InnerShadow {
                                                anchors.fill: parent
                                                horizontalOffset: 0
                                                verticalOffset: 4
                                                radius: 4.0
                                                spread: 0
                                                samples: 24
                                                color: "#4b000000"
                                                smooth: true

                                                source: content
                                            }
                                            Item {
                                                id: stemButton
                                                width: parent.width / 3 * 2
                                                height: parent.height / 3 * 2
                                                anchors {
                                                    top: parent.top
                                                    left: parent.left
                                                    bottom: stemFxSelector.top
                                                }
                                                Item {
                                                    id: contentStemButton
                                                    anchors.fill: parent
                                                    visible: false
                                                    Rectangle {
                                                        anchors.fill: parent
                                                        color: stem.color
                                                        opacity: stemMute.value ? 0.6 : 1.0
                                                    }
                                                }
                                                DropShadow {
                                                    id: effect1
                                                    anchors.fill: parent
                                                    horizontalOffset: 0
                                                    verticalOffset: 0
                                                    radius: 2.0
                                                    spread: 0.5
                                                    color: "#80000000"
                                                    source: contentStemButton
                                                }
                                                InnerShadow {
                                                    id: effect2
                                                    anchors.fill: parent
                                                    horizontalOffset: 2
                                                    verticalOffset: 2
                                                    radius: 4.0
                                                    spread: 0.4
                                                    samples: 24
                                                    color: "#353535"
                                                    smooth: true

                                                    source: effect1
                                                }
                                                InnerShadow {
                                                    anchors.fill: parent
                                                    horizontalOffset: -2
                                                    verticalOffset: -2
                                                    radius: 4.0
                                                    spread: 0.4
                                                    samples: 24
                                                    color: "#353535"
                                                    smooth: true

                                                    source: effect2
                                                }
                                                Column {
                                                    anchors.fill: parent
                                                    topPadding: 4
                                                    Label {
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                        text: stem.label
                                                        font.weight: Font.Bold
                                                        color: "#D9D9D9"
                                                    }
                                                    // Label {
                                                    //     text: "1/2"
                                                    //     color: "#626262"
                                                    // }
                                                }
                                                Mixxx.ControlProxy {
                                                    id: stemMute

                                                    group: stem.group
                                                    key: "mute"
                                                }
                                                TapHandler {
                                                    onTapped: stemMute.value = !stemMute.value
                                                }
                                            }
                                            Skin.ComboBox {
                                                id: stemFxSelector

                                                width: parent.width / 3 * 2
                                                height: Math.min(parent.width, parent.height) / 3
                                                anchors {
                                                    bottom: parent.bottom
                                                    left: parent.left
                                                }

                                                Mixxx.ControlProxy {
                                                    id: fxSelect

                                                    group: stem.fxGroup
                                                    key: "loaded_chain_preset"
                                                }

                                                spacing: 2
                                                indicator.width: 0
                                                popupWidth: 150
                                                clip: true

                                                textRole: "display"
                                                font.pixelSize: 10
                                                model: Mixxx.EffectsManager.quickChainPresetModel
                                                currentIndex: fxSelect.value == -1 ? 0 : fxSelect.value
                                                onActivated: (index) => {
                                                    fxSelect.value = index
                                                }
                                            }
                                            Item {
                                                id: stemVolume
                                                width: parent.width / 3
                                                anchors {
                                                    left: stemButton.right
                                                    right: parent.right
                                                    top: parent.top
                                                    bottom: stemFxKnob.top
                                                    bottomMargin: 3
                                                }

                                                // Skin.VuMeter {
                                                //     x: 15
                                                //     y: (parent.height - height) / 2
                                                //     width: 4
                                                //     height: parent.height - 40
                                                //     group: root.group
                                                //     key: "vu_meter_left"
                                                // }

                                                // Skin.VuMeter {
                                                //     x: parent.width - width - 15
                                                //     y: (parent.height - height) / 2
                                                //     width: 4
                                                //     height: parent.height - 40
                                                //     group: root.group
                                                //     key: "vu_meter_right"
                                                // }

                                                Skin.ControlSlider {
                                                    id: volumeSlider
                                                    implicitWidth: 10

                                                    handleImage {
                                                        width: parent.width - 4
                                                    }

                                                    anchors.fill: parent
                                                    group: stem.group
                                                    key: "volume"
                                                    barColor: Theme.volumeSliderBarColor
                                                    bg: Theme.imgVolumeSliderBackground
                                                }
                                            }
                                            Item {
                                                id: stemFxKnob
                                                width: parent.width / 3
                                                height: stemFxSelector.height
                                                anchors {
                                                    right: parent.right
                                                    bottom: parent.bottom
                                                }
                                                Skin.QuickFxKnob {
                                                    anchors.centerIn: parent
                                                    width: Math.min(parent.width, parent.height)
                                                    height: width
                                                    knob {
                                                        height: width * 0.8
                                                        width: width * 0.8
                                                    }
                                                    group: stem.fxGroup
                                                    knob.arcStyle: ShapePath.DashLine
                                                    knob.arcStylePattern: [2, 2]
                                                    knob.color: Theme.eqFxColor
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.minimumWidth: 36
                            Layout.maximumWidth: 36
                            spacing: 10
                            Skin.Button {
                                id: hotcueTabButton

                                onClicked: {
                                    stemTabButton.checked = false
                                    hotcueTabButton.checked = trackLoadedControl.value == 1
                                }

                                Layout.fillWidth: true
                                Layout.margins: 0
                                implicitHeight: 30

                                contentItem: Shape {
                                    anchors.fill: parent
                                    antialiasing: true
                                    layer.enabled: true
                                    layer.samples: 4
                                    ShapePath {
                                        fillColor: '#D9D9D9'
                                        startX: 10; startY: 4
                                        PathLine { x: 26; y: 4 }
                                        PathLine { x: 19.5; y: 10 }
                                        PathLine { x: 19.5; y: 24 }
                                        PathLine { x: 16.5; y: 24 }
                                        PathLine { x: 16.5; y: 10 }
                                        PathLine { x: 10; y: 4 }
                                    }
                                }
                            }
                            Skin.Button {
                                id: stemTabButton

                                onClicked: {
                                    stemTabButton.checked = trackLoadedControl.value == 1 && stemCountControl.value != 0
                                    hotcueTabButton.checked = !stemTabButton.checked
                                }

                                Layout.fillWidth: true
                                Layout.margins: 0
                                implicitHeight: 30

                                contentItem: Item {
                                    Rectangle {
                                        color: '#D9D9D9'
                                        height: 1
                                        anchors {
                                            left: parent.left
                                            leftMargin: 5
                                            right: parent.right
                                            rightMargin: 5
                                            top: parent.top
                                            topMargin: 6
                                        }
                                    }

                                    Rectangle {
                                        color: '#D9D9D9'
                                        height: 1
                                        anchors {
                                            left: parent.left
                                            leftMargin: 5
                                            right: parent.right
                                            rightMargin: 14
                                            top: parent.top
                                            topMargin: 12
                                        }
                                    }

                                    Rectangle {
                                        color: '#D9D9D9'
                                        height: 1
                                        anchors {
                                            left: parent.left
                                            leftMargin: 5
                                            right: parent.right
                                            rightMargin: 22
                                            bottom: parent.bottom
                                            bottomMargin: 12
                                        }
                                    }

                                    Rectangle {
                                        color: '#D9D9D9'
                                        height: 1
                                        anchors {
                                            left: parent.left
                                            leftMargin: 22
                                            right: parent.right
                                            rightMargin: 5
                                            bottom: parent.bottom
                                            bottomMargin: 13
                                        }
                                    }

                                    Rectangle {
                                        color: '#D9D9D9'
                                        height: 1
                                        anchors {
                                            left: parent.left
                                            leftMargin: 5
                                            right: parent.right
                                            rightMargin: 26
                                            bottom: parent.bottom
                                            bottomMargin: 6
                                        }
                                    }

                                    Rectangle {
                                        color: '#D9D9D9'
                                        height: 1
                                        anchors {
                                            left: parent.left
                                            leftMargin: 14
                                            right: parent.right
                                            rightMargin: 15
                                            bottom: parent.bottom
                                            bottomMargin: 6
                                        }
                                    }

                                    Rectangle {
                                        color: '#D9D9D9'
                                        height: 1
                                        anchors {
                                            left: parent.left
                                            leftMargin: 26
                                            right: parent.right
                                            rightMargin: 5
                                            bottom: parent.bottom
                                            bottomMargin: 6
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.minimumWidth: 120
                            Layout.fillHeight: true
                            id: beatJump
                            color: '#626262'

                            Label {
                                anchors.top: parent.top
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Beatjump"
                                color: '#3F3F3F'
                            }

                            Skin.ControlButton {
                                id: jumpBackButton
                                anchors {
                                    top: parent.top
                                    topMargin: 22
                                    left: parent.left
                                    leftMargin: 6
                                }

                                implicitWidth: 50
                                implicitHeight: 26

                                group: root.group
                                key: "beatjump_backward"
                                contentItem: Item {
                                    anchors.fill: parent
                                    Shape {
                                        anchors.centerIn: parent
                                        width: 21
                                        height: 14
                                        antialiasing: true
                                        layer.enabled: true
                                        layer.samples: 4
                                        ShapePath {
                                            fillColor: '#D9D9D9'
                                            startX: 0; startY: 1
                                            PathLine { x: 1; y: 1 }
                                            PathLine { x: 1; y: 7 }
                                            PathLine { x: 10; y: 1 }
                                            PathLine { x: 10; y: 7 }
                                            PathLine { x: 20; y: 1 }
                                            PathLine { x: 21; y: 1 }
                                            PathLine { x: 21; y: 13 }
                                            PathLine { x: 20; y: 13 }
                                            PathLine { x: 10; y: 7 }
                                            PathLine { x: 10; y: 13 }
                                            PathLine { x: 1; y: 7 }
                                            PathLine { x: 1; y: 13 }
                                            PathLine { x: 0; y: 13 }
                                            PathLine { x: 0; y: 1 }
                                        }
                                    }
                                }
                            }
                            Skin.ControlButton {
                                id: jumpForwardButton

                                anchors {
                                    top: parent.top
                                    topMargin: 22
                                    right: parent.right
                                    rightMargin: 6
                                }

                                implicitWidth: 50
                                implicitHeight: 26

                                group: root.group
                                key: "beatjump_forward"
                                contentItem: Item {
                                    anchors.fill: parent
                                    Shape {
                                        anchors.centerIn: parent
                                        width: 21
                                        height: 14
                                        antialiasing: true
                                        layer.enabled: true
                                        layer.samples: 4
                                        ShapePath {
                                            fillColor: '#D9D9D9'
                                            startX: 0; startY: 1
                                            PathLine { x: 10; y: 7 }
                                            PathLine { x: 10; y: 1 }
                                            PathLine { x: 20; y: 7 }
                                            PathLine { x: 20; y: 1 }
                                            PathLine { x: 21; y: 1 }
                                            PathLine { x: 21; y: 13 }
                                            PathLine { x: 20; y: 13 }
                                            PathLine { x: 20; y: 7 }
                                            PathLine { x: 10; y: 13 }
                                            PathLine { x: 10; y: 7 }
                                            PathLine { x: 0; y: 13 }
                                            PathLine { x: 0; y: 1 }
                                        }
                                    }
                                }
                            }

                            Skin.ControlButton {
                                id: jumpSizeHalfButton
                                anchors {
                                    bottom: parent.bottom
                                    bottomMargin: 7
                                    left: parent.left
                                    leftMargin: 6
                                }

                                implicitWidth: 22
                                implicitHeight: 28

                                group: root.group
                                key: "beatjump_size_halve"
                                contentItem: Item {
                                    anchors.fill: parent
                                    Shape {
                                        anchors.centerIn: parent
                                        width: 12
                                        height: 10
                                        antialiasing: true
                                        layer.enabled: true
                                        layer.samples: 4
                                        ShapePath {
                                            fillColor: '#626262'
                                            strokeColor: 'transparent'
                                            startX: 0; startY: 5
                                            PathLine { x: 12; y: 0 }
                                            PathLine { x: 12; y: 10 }
                                            PathLine { x: 0; y: 5 }
                                        }
                                    }
                                }
                                activeColor: Theme.deckActiveColor
                            }
                            Item {
                                anchors {
                                    bottom: parent.bottom
                                    bottomMargin: 7
                                    left: jumpSizeHalfButton.right
                                    leftMargin: 5
                                    right: jumpSizeDoubleButton.left
                                    rightMargin: 5
                                }
                                implicitHeight: 28

                                Rectangle {
                                    id: backgroundImage

                                    anchors.fill: parent
                                    color: '#2B2B2B'
                                }

                                DropShadow {
                                    anchors.fill: backgroundImage
                                    horizontalOffset: 0
                                    verticalOffset: 0
                                    radius: 1.0
                                    color: "#80000000"
                                    source: backgroundImage
                                }
                                InnerShadow {
                                    anchors.fill: backgroundImage
                                    radius: 1
                                    samples: 16
                                    horizontalOffset: -0
                                    verticalOffset: 0
                                    color: "#353535"
                                    source: backgroundImage
                                }
                                Mixxx.ControlProxy {
                                    id: beatjumpSize

                                    group: root.group
                                    key: "beatjump_size"
                                }
                                TextInput {
                                    anchors.centerIn: backgroundImage
                                    text: beatjumpSize.value < 1 ? `1/${1/beatjumpSize.value}` : beatjumpSize.value
                                    color: "#626262"
                                }
                            }

                            Skin.ControlButton {
                                id: jumpSizeDoubleButton
                                anchors {
                                    bottom: parent.bottom
                                    bottomMargin: 7
                                    right: parent.right
                                    rightMargin: 6
                                }

                                implicitWidth: 22
                                implicitHeight: 28

                                group: root.group
                                key: "beatjump_size_double"
                                contentItem: Item {
                                    anchors.fill: parent
                                    Shape {
                                        anchors.centerIn: parent
                                        width: 12
                                        height: 10
                                        antialiasing: true
                                        layer.enabled: true
                                        layer.samples: 4
                                        ShapePath {
                                            fillColor: '#626262'
                                            strokeColor: 'transparent'
                                            startX: 0; startY: 0
                                            fillRule: ShapePath.WindingFill
                                            capStyle: ShapePath.RoundCap
                                            PathLine { x: 12; y: 5 }
                                            PathLine { x: 0; y: 10 }
                                            PathLine { x: 0; y: 0 }
                                        }
                                    }
                                }
                                activeColor: Theme.deckActiveColor
                            }
                        }

                        Rectangle {
                            Layout.minimumWidth: 120
                            // Layout.horizontalStretchFactor: 1
                            Layout.fillHeight: true
                            id: loop
                            color: '#626262'

                            Label {
                                anchors.top: parent.top
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Loop"
                                color: '#3F3F3F'
                            }
                            RowLayout {
                                anchors {
                                    left: parent.left
                                    leftMargin: 6
                                    right: parent.right
                                    rightMargin: 6
                                    top: parent.top
                                    topMargin: 22
                                }

                                Skin.ControlButton {
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 28
                                    id: loopInButton

                                    implicitHeight: 26

                                    group: root.group
                                    key: "loop_in"
                                    text: "In"
                                }

                                Skin.ControlButton {
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 28
                                    id: loopOutButton

                                    implicitHeight: 26

                                    group: root.group
                                    key: "loop_out"
                                    text: "Out"
                                }

                                Skin.ControlButton {
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 40
                                    id: loopRecallButton

                                    implicitHeight: 26

                                    Mixxx.ControlProxy {
                                        id: loopEnabled

                                        group: root.group
                                        key: "loop_enabled"
                                    }

                                    group: root.group
                                    toggleable: loopEnabled.value
                                    key: loopEnabled.value ? "loop_enabled" : "reloop_toggle"
                                    text: loopEnabled.value ? "exit" : "Recall"
                                }
                            }
                            RowLayout {
                                anchors {
                                    bottom: parent.bottom
                                    bottomMargin: 6
                                    left: parent.left
                                    leftMargin: 6
                                    right: parent.right
                                    rightMargin: 6
                                }
                                Skin.ControlButton {
                                    id: loopSizeHalfButton

                                    implicitWidth: 22
                                    implicitHeight: 28

                                    group: root.group
                                    key: "loop_halve"
                                    contentItem: Item {
                                        anchors.fill: parent
                                        Shape {
                                            anchors.centerIn: parent
                                            width: 12
                                            height: 10
                                            antialiasing: true
                                            layer.enabled: true
                                            layer.samples: 4
                                            ShapePath {
                                                fillColor: '#626262'
                                                strokeColor: 'transparent'
                                                startX: 0; startY: 5
                                                PathLine { x: 12; y: 0 }
                                                PathLine { x: 12; y: 10 }
                                                PathLine { x: 0; y: 5 }
                                            }
                                        }
                                    }
                                    activeColor: Theme.deckActiveColor
                                }

                                Repeater {
                                    model: Math.min(Math.max(1, parseInt((loop.width - 56)/50)), 4)

                                    Skin.ControlButton {
                                        required property int index
                                        id: loopSizeOpt1Button

                                        implicitHeight: 28

                                        group: root.group
                                        key: "beatloop_activate"
                                        Mixxx.ControlProxy {
                                            id: beatloopSize

                                            group: root.group
                                            key: "beatloop_size"
                                        }
                                        text: beatloopSize.value < 1 ? `1/${1/beatloopSize.value}` : beatloopSize.value
                                        activeColor: Theme.deckActiveColor
                                    }
                                }

                                Skin.ControlButton {
                                    id: loopSizeDoubleButton

                                    implicitWidth: 22
                                    implicitHeight: 28

                                    group: root.group
                                    key: "loop_double"
                                    contentItem: Item {
                                        anchors.fill: parent
                                        Shape {
                                            anchors.centerIn: parent
                                            width: 12
                                            height: 10
                                            antialiasing: true
                                            layer.enabled: true
                                            layer.samples: 4
                                            ShapePath {
                                                fillColor: '#626262'
                                                strokeColor: 'transparent'
                                                startX: 0; startY: 0
                                                fillRule: ShapePath.WindingFill
                                                capStyle: ShapePath.RoundCap
                                                PathLine { x: 12; y: 5 }
                                                PathLine { x: 0; y: 10 }
                                                PathLine { x: 0; y: 0 }
                                            }
                                        }
                                    }
                                    activeColor: Theme.deckActiveColor
                                }
                            }
                        }
                        // Row {
                        //     anchors.left: cueButton.right
                        //     anchors.top: parent.top
                        //     anchors.leftMargin: 10
                        //     spacing: -1

                        //     Repeater {
                        //         model: 8

                        //         Skin.HotcueButton {
                        //             required property int index

                        //             hotcueNumber: this.index + 1
                        //             group: root.group
                        //             width: playButton.height
                        //             height: playButton.height
                        //         }
                        //     }
                        // }

                        FadeBehavior on visible {
                            fadeTarget: deckControl
                        }
                    }
                }
            }
        }
        ColumnLayout {
            Layout.preferredWidth: 120
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            Layout.bottomMargin: 3
            Item {
                Layout.topMargin: 8
                Layout.fillHeight: true
                // Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                Rectangle {
                    id: spinner
                    anchors.centerIn: parent
                    width: 140
                    height: 140
                    radius: width / 2
                    color: '#BDBDBD'
                    transform: Rotation { origin.x: spinner.width/2; origin.y: spinner.height/2; angle: 45}

                    MixxxControls.Spinny {
                        id: spinnyIndicator

                        anchors.fill: parent
                        group: root.group
                        indicatorVisible: trackLoadedControl.value

                        indicator: Item {
                            width: spinnyIndicator.width
                            height: spinnyIndicator.height

                            Rectangle {
                                id: tick
                                width: 2
                                height: 70
                                color: '#0E0E0E'
                                anchors {
                                    top: parent.top
                                    horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }
                    }
                }
                Rectangle {
                    id: tempoInfo
                    anchors.centerIn: parent
                    width: spinner.width /2 - 10
                    height: trackLoadedControl.value ? spinner.height / 4 : 0
                    clip: true
                    radius: height / 2 - 5
                    color: '#0E0E0E'

                    Label {
                        id: tempo

                        Mixxx.ControlProxy {
                            id: bpmControl

                            group: root.group
                            key: "bpm"
                        }

                        readonly property real bpm: bpmControl.value.toFixed(2)

                        color: '#BDBDBD'
                        text: bpm
                        anchors {
                            top: parent.top
                            topMargin: 2
                            horizontalCenter: parent.horizontalCenter
                        }
                    }
                    Label {
                        id: pitchRatio

                        Mixxx.ControlProxy {
                            id: rateRatioControl

                            group: root.group
                            key: "rate_ratio"
                        }

                        readonly property real ratio: ((rateRatioControl.value - 1) * 100).toPrecision(2)

                        color: '#3F3F3F'
                        text: ((ratio > 0) ? "+" + ratio.toFixed(2) : ratio.toFixed(2)) + "%"
                        anchors {
                            bottom: parent.bottom
                            bottomMargin: 2
                            horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }
            Item {
                Layout.fillHeight: true
            }
            Item {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                Layout.maximumWidth: 124
                Layout.preferredHeight: 35
                id: fxAssign

                Label {
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "FX Assign"
                    font.pixelSize: 8
                    color: '#626262'
                }

                RowLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    Repeater {
                        model: 4
                        Skin.ControlButton {
                            required property int index
                            Layout.maximumWidth: 30
                            Layout.minimumWidth: 22
                            id: fx1AssignButton

                            implicitHeight: 22

                            group: `[EffectRack1_EffectUnit${index+1}]`
                            key: `group_${root.group}_enable`
                            text: `${index+1}`
                            toggleable: true
                            activeColor: Theme.deckActiveColor
                        }
                    }
                }
            }
        }

        ColumnLayout {
            Layout.minimumWidth: 64
            Layout.maximumWidth: 74
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Item {
                Layout.minimumHeight: pitchDownButton.implicitHeight + 8
                Layout.fillWidth: true
                Skin.ControlButton {
                    id: pitchDownButton
                    anchors {
                        bottom: parent.bottom
                        left: parent.left
                    }

                    implicitWidth: 20
                    implicitHeight: 22

                    group: root.group
                    key: "pitch_down"
                    contentItem: Item {
                        anchors.fill: parent
                        Shape {
                            anchors.centerIn: parent
                            width: 12
                            height: 10
                            antialiasing: true
                            layer.enabled: true
                            layer.samples: 4
                            ShapePath {
                                fillColor: '#626262'
                                strokeColor: 'transparent'
                                startX: 0; startY: 5
                                PathLine { x: 12; y: 0 }
                                PathLine { x: 12; y: 10 }
                                PathLine { x: 0; y: 5 }
                            }
                        }
                    }
                    activeColor: Theme.deckActiveColor
                }
                Item {
                    id: pitchKey
                    anchors {
                        bottom: parent.bottom
                        left: pitchDownButton.right
                        leftMargin: 5
                        right: pitchUpButton.left
                        rightMargin: 5
                    }
                    implicitHeight: 22

                    Rectangle {
                        id: background2Image

                        anchors.fill: parent
                        color: '#2B2B2B'
                    }

                    DropShadow {
                        anchors.fill: background2Image
                        horizontalOffset: 0
                        verticalOffset: 0
                        radius: 1.0
                        color: "#80000000"
                        source: background2Image
                    }
                    InnerShadow {
                        anchors.fill: background2Image
                        radius: 1
                        samples: 16
                        horizontalOffset: -0
                        verticalOffset: 0
                        color: "#353535"
                        source: background2Image
                    }
                    TextInput {
                        anchors.centerIn: background2Image
                        text: trackLoadedControl.value ? root.currentTrack.keyText : "-"
                        color: "#626262"
                        font.pixelSize: 8
                    }
                }

                Skin.ControlButton {
                    id: pitchUpButton
                    anchors {
                        bottom: parent.bottom
                        right: parent.right
                    }

                    implicitWidth: 20
                    implicitHeight: 22

                    group: root.group
                    key: "pitch_up"
                    contentItem: Item {
                        anchors.fill: parent
                        Shape {
                            anchors.centerIn: parent
                            width: 12
                            height: 10
                            antialiasing: true
                            layer.enabled: true
                            layer.samples: 4
                            ShapePath {
                                fillColor: '#626262'
                                strokeColor: 'transparent'
                                startX: 0; startY: 0
                                fillRule: ShapePath.WindingFill
                                capStyle: ShapePath.RoundCap
                                PathLine { x: 12; y: 5 }
                                PathLine { x: 0; y: 10 }
                                PathLine { x: 0; y: 0 }
                            }
                        }
                    }
                    activeColor: Theme.deckActiveColor
                }
            }
            Skin.ControlSlider {
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignHCenter
                id: rateSlider

                visible: !root.minimized
                width: pitchKey.implicitWidth
                group: root.group
                key: "rate"
                barStart: 0.5
                barMargin: 0
                barColor: Theme.bpmSliderBarColor
                bg: Theme.imgBpmSliderBackground

                FadeBehavior on visible {
                    fadeTarget: rateSlider
                }
            }

            Skin.SyncButton {
                id: syncButton
                Layout.alignment: Qt.AlignHCenter
                group: root.group
            }
        }
    }

    Mixxx.PlayerDropArea {
        anchors.fill: parent
        group: root.group
    }
}
