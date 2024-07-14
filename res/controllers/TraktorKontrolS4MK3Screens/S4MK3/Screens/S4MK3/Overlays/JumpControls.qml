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
    property bool shift: false

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
                JumpInfoDetails {
                    id: header
                    label: "MOVE/BEATJUMP"
                    width: 200
                    header: true
                }
            }

            Row {
                JumpInfoDetails {
                    id: bottomInfoDetails1
                    label: !shift ? getValue(settings.jumpSizePad1) : getValue(settings.shiftJumpSizePad1)
                    back: settings.jumpSizePad1 < 0 ? true : false
                    width: 80
                }
                JumpInfoDetails {
                    id: bottomInfoDetails2
                    label: !shift ? getValue(settings.jumpSizePad2) : getValue(settings.shiftJumpSizePad2)
                    back: settings.jumpSizePad2 < 0 ? true : false
                    width: 80
                }
                JumpInfoDetails {
                    id: bottomInfoDetails3
                    label: !shift ? getValue(settings.jumpSizePad3) : getValue(settings.shiftJumpSizePad3)
                    back: settings.jumpSizePad3 < 0 ? true : false
                    width: 80
                }
                JumpInfoDetails {
                    id: bottomInfoDetails4
                    label: !shift ? getValue(settings.jumpSizePad4) : getValue(settings.shiftJumpSizePad4)
                    back: settings.jumpSizePad4 < 0 ? true : false
                    width: 80
                }
            }

            Row {
                JumpInfoDetails {
                    id: bottomInfoDetails5
                    label: !shift ? getValue(settings.jumpSizePad5) : getValue(settings.shiftJumpSizePad5)
                    back: settings.jumpSizePad5 < 0 ? true : false
                    width: 80
                }
                JumpInfoDetails {
                    id: bottomInfoDetails6
                    label: !shift ? getValue(settings.jumpSizePad6) : getValue(settings.shiftJumpSizePad6)
                    back: settings.jumpSizePad6 < 0 ? true : false
                    width: 80
                }
                JumpInfoDetails {
                    id: bottomInfoDetails7
                    label: !shift ? getValue(settings.jumpSizePad7) : getValue(settings.shiftJumpSizePad7)
                    back: settings.jumpSizePad7 < 0 ? true : false
                    width: 80
                }
                JumpInfoDetails {
                    id: bottomInfoDetails8
                    label: !shift ? getValue(settings.jumpSizePad8) : getValue(settings.shiftJumpSizePad8)
                    back: settings.jumpSizePad8 < 0 ? true : false
                    width: 80
                }
            }
        }
    }

    function getValue(size) {
        switch(size) {
            case -13: return "Loop"
            case -12: return "-32"
            case -11: return "-16"
            case -10: return "-8"
            case -9: return "-4"
            case -8: return "-2"
            case -7: return "-1"
            case -6: return "-1/2"
            case -5: return "-1/4"
            case -4: return "-1/8"
            case -3: return "-1/16"
            case -2: return "-1/32"
            case -1: return "-U-Fine"
            case 0: return "n/a"
            case 1: return "U-Fine"
            case 2: return "1/32"
            case 3: return "1/16"
            case 4: return "1/8"
            case 5: return "1/4"
            case 6: return "1/2"
            case 7: return "1"
            case 8: return "2"
            case 9: return "4"
            case 10: return "8"
            case 11: return "16"
            case 12: return "32"
            case 13: return "Loop"
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
