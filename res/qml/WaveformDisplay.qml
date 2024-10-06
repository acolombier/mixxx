import "." as Skin
import Mixxx 1.0 as Mixxx
import Mixxx.Controls 1.0 as MixxxControls
import QtQuick 2.12
import "Theme"

Item {
    id: root

    required property string group

    enum MouseStatus {
        Normal,
        Bending,
        Scratching
    }

    MixxxControls.WaveformDisplay {
        anchors.fill: parent
        group: root.group

        Mixxx.WaveformRendererEndOfTrack {
            color: 'blue'
        }

        Mixxx.WaveformRendererPreroll {
            color: 'red'
        }

        // // Mixxx.WaveformRendererMarkRange {
        // //     // <!-- Loop -->
        // //     Mixxx.WaveformMarkRange {
        // //         startControl: "loop_start_position"
        // //         endControl: "loop_end_position"
        // //         enabledControl: "loop_enabled"
        // //         color: 'LoopColor'
        // //         opacity: 0.7
        // //         disabledColor: '#FFFFFF'
        // //         disabledOpacity: 0.6
        // //     }
        // //     // <!-- Intro -->
        // //     Mixxx.WaveformMarkRange {
        // //         startControl: "intro_start_position"
        // //         endControl: "intro_end_position"
        // //         //   visibilityControl: '[Skin],show_intro_outro_cues'
        // //         color: 'IntroOutroColor'
        // //         opacity: 0.6
        // //         durationTextColor: '#ffffff'
        // //         durationTextLocation: 'after'
        // //     }
        // //     // <!-- Outro -->
        // //     Mixxx.WaveformMarkRange {
        // //         startControl: "outro_start_position"
        // //         endControl: "outro_end_position"
        // //         //   visibilityControl: '[Skin],show_intro_outro_cues'
        // //         color: 'IntroOutroColor'
        // //         opacity: 0.6
        // //         durationTextColor: '#ffffff'
        // //         durationTextLocation: 'before'
        // //     }
        // // }

        Mixxx.WaveformRendererRGB {
            axesColor: 'yellow'
            lowColor: 'red'
            midColor: 'green'
            highColor: 'blue'
        }

        Mixxx.WaveformRendererBeat {
            color: 'green'
        }

        Mixxx.WaveformRendererMark {
            playMarkerColor: 'cyan'
            playMarkerBackground: 'orange'
            defaultMark: Mixxx.WaveformMark {
                align: "bottom|right"
                color: "#FF0000"
                textColor: "#FFFFFF"
                text: " %1 "
            }
            Mixxx.WaveformMark {
                control: "cue_point"
                text: 'C'
                align: 'top|right'
                color: 'red'
                textColor: '#FFFFFF'
            }
            Mixxx.WaveformMark {
                control: "loop_start_position"
                text: '&#8635;'
                align: 'top|left'
                color: 'green'
                textColor: '#FFFFFF'
            }
            Mixxx.WaveformMark {
                control: "loop_end_position"
                //   visibilityControl: '<Variable name="'
                //   <!--Text>OUT</Text-->
                align: 'bottom|right'
                color: 'green'
                textColor: '#FFFFFF'
                //   visibilityControl: '<Variable name="'
            }
            Mixxx.WaveformMark {
                control: "intro_start_position"
                //   visibilityControl: '[Skin],show_intro_outro_cues'
                align: 'top|right'
                color: 'blue'
                textColor: '#FFFFFF'
            }
            Mixxx.WaveformMark {
                control: "intro_end_position"
                //   visibilityControl: '[Skin],show_intro_outro_cues'
                text: '&#9698;'
                align: 'top|left'
                color: 'blue'
                textColor: '#FFFFFF'
            }
            Mixxx.WaveformMark {
                control: "outro_start_position"
                //   visibilityControl: '[Skin],show_intro_outro_cues'
                text: '&#9699;'
                align: 'top|right'
                color: 'blue'
                textColor: '#FFFFFF'
            }
            Mixxx.WaveformMark {
                control: "outro_end_position"
                //   visibilityControl: '[Skin],show_intro_outro_cues'
                align: 'top|left'
                color: 'blue'
                textColor: '#FFFFFF'
            }
        }
    }

    Mixxx.ControlProxy {
        id: scratchPositionEnableControl

        group: root.group
        key: "scratch_position_enable"
    }

    Mixxx.ControlProxy {
        id: scratchPositionControl

        group: root.group
        key: "scratch_position"
    }

    Mixxx.ControlProxy {
        id: wheelControl

        group: root.group
        key: "wheel"
    }

    Mixxx.ControlProxy {
        id: rateRatioControl

        group: root.group
        key: "rate_ratio"
    }

    Mixxx.ControlProxy {
        id: zoomControl

        group: root.group
        key: "waveform_zoom"
    }
    readonly property real effectiveZoomFactor: (1 / rateRatioControl.value) * (100 / zoomControl.value)

    MouseArea {
        property int mouseStatus: WaveformDisplay.MouseStatus.Normal
        property point mouseAnchor: Qt.point(0, 0)

        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: {
            mouseAnchor = Qt.point(mouse.x, mouse.y);
            if (mouse.button == Qt.LeftButton) {
                if (mouseStatus == WaveformDisplay.MouseStatus.Bending)
                    wheelControl.parameter = 0.5;

                mouseStatus = WaveformDisplay.MouseStatus.Scratching;
                scratchPositionEnableControl.value = 1;
                // TODO: Calculate position properly
                scratchPositionControl.value = -mouse.x * 2 * zoomControl.value;
                console.log(mouse.x);
            } else {
                if (mouseStatus == WaveformDisplay.MouseStatus.Scratching)
                    scratchPositionEnableControl.value = 0;

                wheelControl.parameter = 0.5;
                mouseStatus = WaveformDisplay.MouseStatus.Bending;
            }
        }
        onPositionChanged: {
            switch (mouseStatus) {
                case WaveformDisplay.MouseStatus.Bending: {
                    const diff = mouse.x - mouseAnchor.x;
                    // Start at the middle of [0.0, 1.0], and emit values based on how far
                    // the mouse has traveled horizontally. Note, for legacy (MIDI) reasons,
                    // this is tuned to 127.
                    const v = 0.5 + (diff / 1270);
                    // clamp to [0.0, 1.0]
                    wheelControl.parameter = Mixxx.MathUtils.clamp(v, 0, 1);
                    break;
                };
                case WaveformDisplay.MouseStatus.Scratching:
                // TODO: Calculate position properly
                    scratchPositionControl.value = -mouse.x * zoomControl.value * 2 * 10;
                    break;
            }
        }
        onReleased: {
            switch (mouseStatus) {
                case WaveformDisplay.MouseStatus.Bending:
                    wheelControl.parameter = 0.5;
                    break;
                case WaveformDisplay.MouseStatus.Scratching:
                    scratchPositionEnableControl.value = 0;
                    break;
            }
            mouseStatus = WaveformDisplay.MouseStatus.Normal;
        }

        onWheel: {
            if (wheel.angleDelta.y < 0 && zoomControl.value > 1) {
                zoomControl.value -= 1;
            } else if (wheel.angleDelta.y > 0 && zoomControl.value < 10.0) {
                zoomControl.value += 1;
            }
        }
    }
}
