import "." as Skin
import Mixxx 1.0 as Mixxx
import QtQuick 2.12
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects
import "Theme"

ColumnLayout {
    anchors.fill: parent

    property var selectedTab: ""
    Item {
        id: tabSection
        Layout.fillWidth: true
        Layout.preferredHeight: engine.height
        RowLayout {
            id: engine
            anchors.left: parent.left
            anchors.right: parent.right
            ColumnLayout {
                RowLayout {
                    Text {
                        Layout.fillWidth: true
                        text: "Main Mix"
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
                        text: "Main Output Mode"
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
                        text: "Sound Clock"
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
            }
            Item {
                Layout.preferredWidth: 70
            }
            ColumnLayout {
                RowLayout {
                    Text {
                        Layout.fillWidth: true
                        text: "Sample Rate"
                        color: "#D9D9D9"
                        font.pixelSize: 14
                    }
                    RatioChoice {
                        options: [
                                  "44100 hz",
                                  "48000 hz",
                                  "96000 hz"
                        ]
                    }
                }
                RowLayout {
                    Text {
                        Layout.fillWidth: true
                        text: "Audio Buffer"
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
                        text: "Sample Rate"
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
            }
        }
    }
    SettingAudioRouter {
        Layout.fillWidth: true
        Layout.fillHeight: true
    }

    function selectTab(tab) {
        console.log(tab)
    }
}
