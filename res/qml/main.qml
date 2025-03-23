import "." as Skin
import Mixxx 1.0 as Mixxx
import QtQuick 2.12
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects
import "Theme"

ApplicationWindow {
    id: root

    property alias show4decks: show4DecksButton.checked
    property alias showEffects: showEffectsButton.checked
    property alias showSamplers: showSamplersButton.checked
    property alias maximizeLibrary: maximizeLibraryButton.checked

    width: 1920
    height: 1080
    color: Theme.backgroundColor
    visible: true

    Item {
        id: content
        anchors.fill: parent
        Column {
            anchors.fill: parent

            Rectangle {
                id: toolbar

                width: parent.width
                height: 36
                color: Theme.toolbarBackgroundColor
                radius: 1

                RowLayout {
                    anchors.fill: parent
                    // padding: 5
                    // spacing: 5

                    Skin.Button {
                        id: show4DecksButton

                        text: "4 Decks"
                        activeColor: Theme.white
                        checkable: true
                    }

                    Skin.Button {
                        id: maximizeLibraryButton

                        text: "Library"
                        activeColor: Theme.white
                        checkable: true
                    }

                    Skin.Button {
                        id: showEffectsButton

                        text: "Effects"
                        activeColor: Theme.white
                        checkable: true
                    }

                    Skin.Button {
                        id: showAuxButton

                        text: "Aux"
                        activeColor: Theme.white
                        checkable: true
                    }

                    Skin.Button {
                        id: showSamplersButton

                        text: "Sampler"
                        activeColor: Theme.white
                        checkable: true
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Skin.Button {
                        id: showDevToolsButton

                        text: "Develop"
                        activeColor: Theme.white
                        checkable: true
                        checked: devToolsWindow.visible
                        onClicked: {
                            if (devToolsWindow.visible)
                                devToolsWindow.close();
                            else
                                devToolsWindow.show();
                        }

                        DeveloperToolsWindow {
                            id: devToolsWindow

                            width: 640
                            height: 480
                        }
                    }

                    Skin.Button {
                        id: showPreferencesButton

                        implicitWidth: implicitHeight

                        icon.source: "images/gear.svg"
                        icon.width: 16
                        icon.height: 16

                        activeColor: Theme.white
                        checkable: true
                        // onClicked: {
                        //     Mixxx.PreferencesDialog.show();
                        // }
                    }
                }
            }
            SplitView {
                id: splitView
                width: parent.width
                height: parent.height - y

                // anchors.fill: parent

                orientation: Qt.Vertical

                handle: Rectangle {
                    id: handleDelegate
                    implicitWidth: 8
                    implicitHeight: 8
                    color: Theme.libraryPanelSplitterBackground
                    clip: true
                    property color handleColor: SplitHandle.pressed || SplitHandle.hovered ? Theme.libraryPanelSplitterHandleActive : Theme.libraryPanelSplitterHandle
                    property int handleSize: SplitHandle.pressed || SplitHandle.hovered ? 6 : 5

                    RowLayout {
                        anchors.centerIn: parent
                        Repeater {
                            model: 3
                            Rectangle {
                                width: handleSize
                                height: handleSize
                                radius: handleSize
                                color: handleColor
                            }
                        }
                    }

                    containmentMask: Item {
                        x: (handleDelegate.width - width) / 2
                        height: 8
                        width: splitView.width
                    }
                }

                Item {
                    SplitView.preferredHeight: 240
                    Skin.WaveformDisplay {
                        id: deck3waveform

                        anchors.top: parent.top

                        group: "[Channel3]"
                        width: root.width
                        height: parent.height / 4
                        visible: root.show4decks && !root.maximizeLibrary

                        FadeBehavior on visible {
                            fadeTarget: deck3waveform
                        }
                    }

                    Skin.WaveformDisplay {
                        id: deck1waveform

                        anchors.top: root.show4decks ? deck3waveform.bottom : parent.top

                        group: "[Channel1]"
                        width: root.width
                        height: root.show4decks ? parent.height / 4 : parent.height / 2
                        visible: !root.maximizeLibrary

                        FadeBehavior on visible {
                            fadeTarget: deck1waveform
                        }
                    }

                    Skin.WaveformDisplay {
                        id: deck2waveform

                        anchors.bottom: root.show4decks ? deck4waveform.top : parent.bottom

                        group: "[Channel2]"
                        width: root.width
                        height: root.show4decks ? parent.height / 4 : parent.height / 2
                        visible: !root.maximizeLibrary

                        FadeBehavior on visible {
                            fadeTarget: deck2waveform
                        }
                    }

                    Skin.WaveformDisplay {
                        id: deck4waveform

                        anchors.bottom: parent.bottom

                        group: "[Channel4]"
                        width: root.width
                        height: parent.height / 4
                        visible: root.show4decks && !root.maximizeLibrary

                        FadeBehavior on visible {
                            fadeTarget: deck4waveform
                        }
                    }
                    Rectangle {
                        width: 125
                        anchors {
                            top: parent.top
                            left: parent.left
                            bottom:parent.bottom
                        }
                        gradient: Gradient {
                            orientation: Gradient.Horizontal

                            GradientStop {
                                position: 0
                                color: '#000000'
                            }

                            GradientStop {
                                position: 1
                                color: '#00000000'
                            }
                        }
                    }
                    Rectangle {
                        width: 125
                        anchors {
                            top: parent.top
                            right: parent.right
                            bottom:parent.bottom
                        }
                        gradient: Gradient {
                            orientation: Gradient.Horizontal

                            GradientStop {
                                position: 0
                                color: '#00000000'
                            }

                            GradientStop {
                                position: 1
                                color: '#000000'
                            }
                        }
                    }
                }

                Item {
                    SplitView.fillHeight: true
                    Deck {
                        id: deck1

                        anchors {
                            left: parent.left
                            right: mixer.left
                        }

                        minimized: root.maximizeLibrary
                        height: root.maximizeLibrary ? 80 : root.show4decks ? mixer.implicitHeight / 2 : mixer.implicitHeight
                        group: "[Channel1]"
                    }

                    Mixer {
                        id: mixer
                        // anchors {
                        //     left: deck1.right
                        //     right: deck2.left
                        // }

                        show4decks: root.show4decks
                        groups: [
                                 deck1.group,
                                 deck2.group,
                                 deck3.group,
                                 deck4.group
                        ]

                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: !root.maximizeLibrary

                        FadeBehavior on visible {
                            fadeTarget: mixer
                        }
                    }

                    Deck {
                        id: deck2

                        anchors {
                            left: mixer.right
                            right: parent.right
                        }

                        minimized: root.maximizeLibrary
                        height: root.maximizeLibrary ? 80 : root.show4decks ? mixer.implicitHeight / 2 : mixer.implicitHeight
                        group: "[Channel2]"
                    }

                    Deck {
                        id: deck3
                        visible: root.show4decks

                        anchors {
                            top: deck1.bottom
                            left: parent.left
                            right: mixer.left
                        }

                        minimized: root.maximizeLibrary
                        height: root.maximizeLibrary ? 80 : mixer.implicitHeight / 2
                        group: "[Channel3]"
                    }

                    Deck {
                        id: deck4
                        visible: root.show4decks

                        anchors {
                            top: deck2.bottom
                            left: mixer.right
                            right: parent.right
                        }

                        minimized: root.maximizeLibrary
                        height: root.maximizeLibrary ? 80 : mixer.implicitHeight / 2
                        group: "[Channel4]"
                    }

                    // Skin.SamplerRow {
                    //     id: samplers

                    //     width: parent.width
                    //     visible: root.showSamplers

                    //     Skin.FadeBehavior on visible {
                    //         fadeTarget: samplers
                    //     }
                    // }

                    // Skin.EffectRow {
                    //     id: effects

                    //     width: parent.width
                    //     visible: root.showEffects

                    //     Skin.FadeBehavior on visible {
                    //         fadeTarget: effects
                    //     }
                    // }

                    Skin.Library {
                        anchors {
                            top: mixer.bottom
                            bottom: parent.bottom
                        }
                        width: parent.width
                        // height: parent.height - y
                    }
                }
            }

            move: Transition {
                NumberAnimation {
                    properties: "x,y"
                    duration: 150
                }
            }
        }
    }

    // ShaderEffectSource {
    //     id: effectSource

    //     sourceItem: content
    //     anchors.fill: parent
    // }
    Rectangle {
        id: overlay
        visible: showPreferencesButton.checked
        color: '#000000'
        anchors.fill: parent
        property real radius: 12
        GaussianBlur {
            anchors.fill: parent
            source: content
            radius: Math.max(0, parent.radius)
            samples: 16
            deviation: 4
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                showPreferencesButton.checked = false
            }
            onWheel: (mouse)=> {
                parent.radius = Math.min(32, parent.radius + (mouse.angleDelta.y > 0 ? 0.2 : -0.2))
                console.log("captured")
                mouse.accepted = true
            }
            onPressed: {
                console.log("pressed")
            }
            onCanceled: {
                console.log("cancelled")
            }
        }

        Repeater {
            id: setting
            model: showPreferencesButton.checked ? 1 : 0

            property list<var> categories: [{
                    label: "Sound hardware",
                    component: "SettingSoundHardware.qml",
                    tabs: ["engine", "delays", "stats"]
                }, {
                    label: "Library",
                    component: "SettingLibrary.qml",
                    tabs: []
                }, {
                    label: "Controllers",
                    component: "SettingController.qml",
                    tabs: []
                }, {
                    label: "Interface",
                    component: "SettingInterface.qml",
                    tabs: ["theme & colour", "waveform", "decks"]
                }, {
                    label: "Mixer & Effects",
                    component: "SettingMixerEffect.qml",
                    tabs: []
                }, {
                    label: "Auto DJ",
                    component: "SettingAutoDJ.qml",
                    tabs: []
                }, {
                    label: "Live broadcasting",
                    component: "SettingBroadcast.qml",
                    tabs: ["engine", "delays", "stats"]
                }, {
                    label: "Recording",
                    component: "SettingRecording.qml",
                    tabs: []
                }, {
                    label: "Analyzer",
                    component: "SettingAnalyzer.qml",
                    tabs: []
                }, {
                    label: "Stats & Performance",
                    component: "SettingStatsPerformance.qml",
                    tabs: []
                }
            ]
            property var activeCategory: categories[0]

            Rectangle {
                color: '#2B2B2B'
                anchors.centerIn: parent
                opacity: parent.radius < 0 ? Math.max(0.1, 1 + parent.radius / 8) : 1
                radius: 8
                width: Math.max(1400, parent.width*0.8)
                height: Math.max(680, parent.height*0.7)

                MouseArea {
                    anchors.fill: parent
                    preventStealing: true
                    onWheel: (mouse)=> {
                        console.log("captured")
                        mouse.accepted = true
                    }
                    onClicked: (mouse)=> {
                        console.log("captured")
                        mouse.accepted = true
                    }
                }

                Item {
                    width: parent.width - 40
                    height: parent.height - 40
                    anchors.centerIn: parent
                    RowLayout {
                        anchors.fill: parent
                        spacing: 0
                        Rectangle {
                            color: '#3F3F3F'
                            Layout.preferredWidth: 280
                            Layout.fillHeight: true
                            Rectangle {
                                color: '#0E0E0E'
                                anchors.fill: parent
                                anchors.margins: 6
                                anchors.centerIn: parent
                                // TODO listview?
                                Column {
                                    anchors.fill: parent
                                    Rectangle {
                                        width: parent.width
                                        height: 30
                                        color: '#626262'
                                        Text {
                                            anchors.verticalCenter: parent.verticalCenter
                                            color: '#D9D9D9'
                                            text: 'Search...'
                                        }
                                    }
                                    Repeater {
                                        model: setting.categories.length
                                        Rectangle {
                                            required property int index
                                            readonly property var modelData: setting.categories[index]
                                            width: parent.width
                                            height: 38
                                            color: setting.activeCategory == modelData ? '#3F3F3F' : '#2B2B2B'
                                            Image {
                                                id: handleImage
                                                anchors.verticalCenter: parent.verticalCenter
                                                anchors.left: parent.left
                                                anchors.leftMargin: 8
                                                height: 24
                                                visible: false
                                                source: "images/gear.svg"
                                                fillMode: Image.PreserveAspectFit
                                            }
                                            ColorOverlay {
                                                anchors.fill: handleImage
                                                source: handleImage
                                                color: setting.activeCategory == modelData ? '#3392E6' : "#696968"
                                                antialiasing: true
                                            }
                                            Text {
                                                anchors.left: handleImage.right
                                                anchors.leftMargin: 8
                                                anchors.verticalCenter: parent.verticalCenter
                                                color: '#D9D9D9'
                                                text: modelData.label
                                                font.bold: setting.activeCategory == modelData
                                            }
                                            TapHandler {
                                                // anchors.fill: parent
                                                onTapped: {
                                                    setting.activeCategory = modelData
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Text {
                                Layout.preferredHeight: 36
                                Layout.alignment: Qt.AlignHCenter
                                color: '#D9D9D9'
                                text: "Settings"
                                font.pixelSize: 16
                                font.weight: Font.DemiBold
                            }
                            Rectangle {
                                id: tabBar
                                Layout.preferredHeight: 30
                                Layout.fillWidth: true
                                color: '#3F3F3F'

                                property string selectedTab: setting.activeCategory.tabs.length ? setting.activeCategory.tabs[0] : null
                                visible: setting.activeCategory.tabs.length > 0

                                RowLayout {
                                    anchors.fill: parent
                                    // padding: 5
                                    // spacing: 5

                                    Repeater {
                                        model: setting.activeCategory.tabs

                                        Skin.Button {
                                            required property string modelData

                                            text: modelData
                                            activeColor: Theme.white
                                            // checkable: true
                                            Layout.alignment: Qt.AlignHCenter
                                            Layout.preferredHeight: 22
                                            Layout.preferredWidth: parent.width / (setting.activeCategory.tabs.length + 2)

                                            checked: tabBar.selectedTab == modelData

                                            onPressed: {
                                                tabBar.selectedTab = modelData
                                            }
                                        }
                                    }
                                }
                            }
                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.leftMargin: 20

                                Loader {
                                    id: settingCategory
                                    visible: setting.activeCategory != null
                                    anchors.fill: parent
                                    source: setting.activeCategory.component
                                }
                            }
                            Connections {
                                target: tabBar
                                function onSelectedTabChanged() {
                                    if (!settingCategory.item)
                                        return
                                    settingCategory.item.selectedTab = tabBar.selectedTab
                                }
                            }
                        }
                    }
                }
            }
        }
        DropShadow {
            id: dropSetting
            anchors.fill: setting
            horizontalOffset: 0
            verticalOffset: 0
            radius: 10.0
            color: "#80000000"
            source: setting
        }
    }
}
