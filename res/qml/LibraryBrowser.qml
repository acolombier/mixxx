import "." as Skin
import Mixxx 1.0 as Mixxx
import Qt.labs.qmlmodels
import QtQml
import QtQuick
import QtQml.Models
import QtQuick.Layouts
import QtQuick.Controls 2.15
import "Theme"

Skin.LibraryPanel {
    id: root

    signal selected(feature: color)

    Rectangle {
        id: treeView

        anchors.fill: parent

        color: 'transparent'

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            drag {
                target: parent
            }
        }

        Drag.active: mouseArea.drag.active
        Drag.source: parent
        Drag.dragType: Drag.Automatic
        Drag.supportedActions: Qt.MoveAction
        Drag.hotSpot.x: mouseArea.mouseX
        Drag.hotSpot.y: mouseArea.mouseY

        ColumnLayout {
            anchors.fill: parent
            spacing: 5
            Rectangle {
                Layout.fillWidth: true
                height: searchBar.implicitHeight

                border.color: 'red'

                TextInput {
                    id: searchBar

                    anchors.fill: parent

                    text: "Search..."
                    cursorVisible: true
                }
            }
            ListView {
                id: featureView
                Layout.fillWidth: true
                // Layout.fillHeight: true
                Layout.preferredHeight: contentHeight

                focus: true
                clip: true

                model: ListModel {
                    id: treeSection
                    // ListElement { option: "Missing Tracks"; feature: "Tracks"; icon: "tracks" }
                    // ListElement { option: "Hidden Tracks"; feature: "Tracks"; icon: "tracks" }
                    // ListElement { option: "Crates" ; feature: "Auto DJ"; icon: "auto_dj" }
                    // ListElement { feature: "Playlists" }
                    // ListElement { feature: "Crates" }
                    // ListElement { feature: "Computer" }
                    // ListElement { feature: "Recordings" }
                    // ListElement { feature: "History" }
                    // ListElement { feature: "Analyse" }
                    // ListElement { feature: "iTunes" }
                    // ListElement { feature: "Traktor" }
                    // ListElement { feature: "Rekordbox" }
                    // ListElement { feature: "Serato" }
                    ListElement {
                        feature: "Tracks"
                        icon: "tracks"
                        options: [
                            ListElement {
                                option: "Missing Tracks"
                            },
                            ListElement {
                                option: "Hidden Tracks"
                            }
                        ]
                    }
                    ListElement {
                        feature: "Auto DJ"
                        icon: "autodj"
                        options: []
                    }
                    ListElement {
                        feature: "Playlists"
                        icon: "playlist"
                        options: []
                    }
                    ListElement {
                        feature: "Crates"
                        icon: "crates"
                        options: []
                    }
                    ListElement {
                        feature: "Computer"
                        icon: "computer"
                        options: []
                    }
                    ListElement {
                        feature: "Recordings"
                        icon: "recordings"
                        options: []
                    }
                    ListElement {
                        feature: "History"
                        icon: "history"
                        options: []
                    }
                    ListElement {
                        feature: "Analyse"
                        icon: "prepare"
                        options: []
                    }
                    ListElement {
                        feature: "iTunes"
                        icon: "itunes"
                        options: []
                    }
                    ListElement {
                        feature: "Traktor"
                        icon: "traktor"
                        options: []
                    }
                    ListElement {
                        feature: "Rekordbox"
                        icon: "rekordbox"
                        options: []
                    }
                    ListElement {
                        feature: "Serato"
                        icon: "serato"
                        options: []
                    }
                }

                // moveDisplaced: Transition {
                //     NumberAnimation { properties: "x,y"; duration: 1000 }
                // }

                delegate: Item {
                    id: featureDelegate

                    required property int index
                    required property string feature
                    required property string icon
                    required property var options

                    property bool expanded: true

                    height: featureLabel.implicitHeight + 6 + (featureDelegate.expanded && options.count ? featureOptionView.contentHeight + 6 : 0)

                    Behavior on height {
                        NumberAnimation { duration: 200 }
                    }

                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    signal clicked()

                    ColumnLayout {
                        anchors.fill: parent
                        MouseArea {
                            Layout.preferredHeight: featureLabel.implicitHeight + 4
                            Layout.fillWidth: true

                            onClicked: {
                                featureView.currentIndex = index
                            }
                            Rectangle {

                                anchors.fill: parent
                                color: featureView.currentItem == featureDelegate ? "#5e4507" : "transparent"
                                RowLayout {
                                    anchors {
                                        leftMargin: 8
                                        left: parent.left
                                        right: parent.right
                                    }
                                    Text {
                                        id: indicator
                                        text: "▸"
                                        Layout.preferredWidth: indicator.implicitWidth
                                        height: 16

                                        color: 'white'
                                        font.pixelSize: 18
                                        font.weight: Font.Bold
                                        opacity: featureDelegate.options.count > 0 ? 1 : 0
                                        rotation: featureDelegate.expanded ? 90 : 0

                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                featureDelegate.expanded = !featureDelegate.expanded
                                            }
                                        }
                                    }

                                    Item {
                                        id: icon
                                        height: 14
                                        Layout.preferredWidth: 14

                                        Image {
                                            anchors.fill: parent
                                            source: `../../res/images/library/ic_library_${featureDelegate.icon}.svg`
                                        }
                                    }

                                    Text {
                                        id: featureLabel
                                        Layout.fillWidth: true

                                        font.weight: Font.Bold
                                        text: featureDelegate.feature
                                        color: 'white'
                                    }
                                }
                            }
                        }
                        ListView {
                            id: featureOptionView

                            Layout.fillWidth: true
                            Layout.preferredHeight: featureDelegate.expanded ? contentHeight : 0

                            focus: true
                            clip: true

                            model: featureDelegate.options

                            delegate: Rectangle {
                                id: featureOptionDelegate

                                required property int index
                                required property string option
                                property var element: {
                                    "fillHeight": true,
                                    "type": "TrackList",
                                    "preferredHeight": 0
                                }

                                color: (featureView.currentIndex == -1 && featureOptionView.currentItem == featureOptionDelegate) ? "#5e4507" : "transparent"
                                height: label.height

                                MouseArea {
                                    id: mouseArea
                                    anchors.fill: parent
                                    drag.target: parent
                                    onClicked: {
                                        featureView.currentIndex = -1
                                        featureOptionView.currentIndex = index
                                    }
                                }

                                Drag.active: mouseArea.drag.active
                                Drag.dragType: Drag.Automatic
                                Drag.supportedActions: Qt.CopyAction
                                Drag.hotSpot.x: mouseArea.mouseX
                                Drag.hotSpot.y: mouseArea.mouseY

                                anchors {
                                    left: parent.left
                                    leftMargin: 42
                                    right: parent.right
                                }
                                RowLayout {
                                    anchors.fill: parent

                                    Item {
                                        id: icon
                                        height: 14
                                        Layout.preferredWidth: 14
                                        visible: false

                                        Image {
                                            anchors.fill: parent
                                            source: `../../res/images/library/ic_library_${featureDelegate.icon}.svg`
                                        }
                                    }
                                    Text {
                                        id: label
                                        Layout.fillWidth: true

                                        font.weight: Font.Bold
                                        text: featureOptionDelegate.option
                                        color: 'white'
                                    }
                                }
                            }
                        }
                    }
                }

                highlightFollowsCurrentItem: false
            }
            Item {
                Layout.fillHeight: true
            }
        }
    }
}
