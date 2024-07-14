import '../../../' as CSI
import QtQuick 2.15

import '../Widgets' as Widgets
import '../../Defines' as Defines

//--------------------------------------------------------------------------------------------------------------------
//  FX CONTROLS
//--------------------------------------------------------------------------------------------------------------------

// The FxControls are located on the top of the screen and blend in if one of the top knobs is touched/changed

Item {
    id: bottomLabels

    property string showHideState: "hide"
    property int bottomMargin: 0
    property int yPositionWhenHidden: 240
    property int yPositionWhenShown: (180 - bottomMargin)
    property int deckId: 1

  // AppProperty { id: waveZoomProp; path: "app.traktor.decks." + deckId + ".track.waveform_zoom" }
    QtObject {
        id: waveZoomProp
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: tick; path: "app.traktor.decks." + deckId + ".track.grid.enable_tick" }
    QtObject {
        id: tick
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }
  // AppProperty { id: range; path: "app.traktor.decks." + deckId + ".tempo.range_value" }
    QtObject {
        id: range
        property string description: "Description"
        property var value: 0
        property var valueRange: ({isDiscrete: true, steps: 1})
    }

    readonly property color barBgColor: "black"

    Defines.Colors { id: colors }
    Defines.Durations { id: durations }

    height: 60
    anchors.left: parent.left
    anchors.right: parent.right

  // dark grey background
    Rectangle {
        id: bottomInfoDetailsPanelDarkBg
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: bottomLabels.height
        color: colors.colorFxHeaderBg
    // light grey background
        Rectangle {
            id:bottomInfoDetailsPanelLightBg
            anchors {
                top: parent.top
                left: parent.left
            }
            height: bottomLabels.height
            width: 80
            color: colors.colorFxHeaderLightBg
        }
    }

//  // dividers
    Rectangle {
        id: fxInfoDivider0
        width:1;
        height:63;
        color: colors.colorDivider
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 80
    }

  // dividers
    Rectangle {
        id: fxInfoDivider1
        width:1;
        color: colors.colorDivider
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 160
        height: 63
    }

    Rectangle {
        id: fxInfoDivider2
        width:1;
        color: colors.colorDivider
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 240
        height: 63
    }

  // Info Details
    Rectangle {
        id: bottomInfoDetailsPanel

        height: parent.height
        clip: true
        width: parent.width
        color: "transparent"

        anchors.left: parent.left
        anchors.leftMargin: 1

        Row {
            GridInfoDetails {
                id: bottomInfoDetails1
                parameter: waveZoomProp
                label: "ZOOM"
                fxEnabled: true
                barBgColor: barBgColor
                hideButton: true
                zoom: true
                hideValue: false
            }

            GridInfoDetails {
                id: bottomInfoDetails2
                parameter: tick
                label: "TICK"
                fxEnabled: true
                isOn: tick.value
                barBgColor: barBgColor
                hideButton: false
                zoom: true
                hideValue: true
            }

            GridInfoDetails {
                id: bottomInfoDetails3
                parameter: tick
                label: "TICK"
                fxEnabled: false
                isOn: tick.value
                barBgColor: barBgColor
                hideButton: true
                zoom: true
                hideValue: true
            }

            GridInfoDetails {
                id: bottomInfoDetails4
                parameter: range
                label: "RANGE"
                fxEnabled: true
                barBgColor: barBgColor
                hideButton: true
                zoom: false
                hideValue: false
            }
        }
    }

  // black border & shadow
    Rectangle {
        id: headerBlackLine
        anchors.top: bottomLabels.bottom
        width: parent.width
        color: colors.colorBlack
        height: 2
    }
    Rectangle {
        id: headerShadow
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: headerBlackLine.bottom
        height: 6
        gradient: Gradient {
            GradientStop { position: 1.0; color: colors.colorBlack0 }
            GradientStop { position: 0.0; color: colors.colorBlack63 }
        }
        visible: false
    }

  //------------------------------------------------------------------------------------------------------------------
  //  STATES
  //------------------------------------------------------------------------------------------------------------------

    Behavior on y { PropertyAnimation { duration: durations.overlayTransition; easing.type: Easing.InOutQuad } }

    Item {
        id: showHide
        state: showHideState
        states: [
            State {
                name: "show";
                PropertyChanges { target: bottomLabels; y: yPositionWhenShown}
            },
            State {
                name: "hide";
                PropertyChanges { target: bottomLabels; y: yPositionWhenHidden}
            }
        ]
    }
}
