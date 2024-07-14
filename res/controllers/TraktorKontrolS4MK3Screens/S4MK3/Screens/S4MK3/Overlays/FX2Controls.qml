import '../../../' as CSI
import QtQuick 2.15

import '../Widgets' as Widgets
import '../../Defines' as Defines

//--------------------------------------------------------------------------------------------------------------------
//  FX CONTROLS
//--------------------------------------------------------------------------------------------------------------------

// The FxControls are located on the top of the screen and blend in if one of the top knobs is touched/changed

Item {
    id: fxLabels

    property string showHideState: "hide"
    property int bottomMargin: 0
    property int yPositionWhenHidden: 240
    property int yPositionWhenShown: (240 - height)
    property string name: ""
    readonly property color barBgColor: "black"

    Defines.Colors { id: colors }
    Defines.Durations { id: durations }
    Defines.Settings { id: settings }

    height: 65
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
        height: fxLabels.height
        color: colors.colorFxHeaderBg
    }

  // dividers
    Rectangle {
        id: fxInfoDivider0
        width:1;
        height:80;
        color: colors.colorDivider
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 80
    }

  // dividers
    Rectangle {
        id: fxInfoDivider1
        width:1;
        color: colors.colorDivider
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 160
        height: 80
    }

    Rectangle {
        id: fxInfoDivider2
        width:1;
        color: colors.colorDivider
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 240
        height: 80
    }

  // dividers
    Rectangle {
        id: fxInfoDivider3
        width:360;
        height:1;
        color: colors.colorDivider
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.left: parent.left
    }

  // dividers
    Rectangle {
        id: fxInfoDivider4
        width:360;
        height:1;
        color: colors.colorDivider
        anchors.top: parent.top
        anchors.topMargin: 40
        anchors.left: parent.left
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

        Column {
            Row {
                FXInfoDetails {
                    id: header
                    label: "FX PADS 2"
                    width: 80
                    header: true
                    effectID: 1000
                }
            }

            Row {
                FXInfoDetails {
                    id: bottomInfoDetails1
                    label: settings.fx2pad1label
                    fxUnit: settings.fx2unit
                    effectID: settings.fx2pad1
                    width: 80
                }
                FXInfoDetails {
                    id: bottomInfoDetails2
                    label: settings.fx2pad2label
                    fxUnit: settings.fx2unit
                    effectID: settings.fx2pad2
                    width: 80
                }
                FXInfoDetails {
                    id: bottomInfoDetails3
                    label: settings.fx2pad3label
                    fxUnit: settings.fx2unit
                    effectID: settings.fx2pad3
                    width: 80
                }
                FXInfoDetails {
                    id: bottomInfoDetails4
                    label: settings.fx2pad4label
                    fxUnit: settings.fx2unit
                    effectID: settings.fx2pad4
                    width: 80
                }
            }

            Row {
                FXInfoDetails {
                    id: bottomInfoDetails5
                    label: settings.fx2pad5label
                    fxUnit: settings.fx2unit
                    effectID: settings.fx2pad5
                    width: 80
                }
                FXInfoDetails {
                    id: bottomInfoDetails6
                    label: settings.fx2pad6label
                    fxUnit: settings.fx2unit
                    effectID: settings.fx2pad6
                    width: 80
                }
                FXInfoDetails {
                    id: bottomInfoDetails7
                    label: settings.fx2pad7label
                    fxUnit: settings.fx2unit
                    effectID: settings.fx2pad7
                    width: 80
                }
                FXInfoDetails {
                    id: bottomInfoDetails8
                    label: settings.fx2pad8label
                    fxUnit: settings.fx2unit
                    effectID: settings.fx2pad8
                    width: 80
                }
            }
        }
    }

  // black border & shadow
    Rectangle {
        id: headerBlackLine
        anchors.top: fxLabels.bottom
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
                PropertyChanges { target: fxLabels; y: yPositionWhenShown}
            },
            State {
                name: "hide";
                PropertyChanges { target: fxLabels; y: yPositionWhenHidden}
            }
        ]
    }
}
