import "." as Skin
import Mixxx 1.0 as Mixxx
import QtQuick 2.12
import QtQuick.Controls
import QtQuick.Layouts
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

    Column {
        anchors.fill: parent

        Rectangle {
            id: toolbar

            width: parent.width
            height: 36
            color: Theme.toolbarBackgroundColor
            radius: 1

            Row {
                padding: 5
                spacing: 5

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

                Skin.Button {
                    id: showPreferencesButton

                    text: "Prefs"
                    activeColor: Theme.white
                    onClicked: {
                        Mixxx.PreferencesDialog.show();
                    }
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
                    width: 8
                    height: splitView.height
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

                    minimized: root.minimized
                    height: root.show4decks ? 255 : 274
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

                    minimized: root.minimized
                    height: root.show4decks ? 255 : 274
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

                    minimized: root.minimized
                    height: 255
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

                    minimized: root.minimized
                    height: 255
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
                        top: root.show4decks ? deck3.bottom : deck1.bottom
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
