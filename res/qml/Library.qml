import "." as Skin
import Mixxx 1.0 as Mixxx
import Qt.labs.qmlmodels
import QtQml
import QtQuick
import QtQml.Models
import QtQuick.Layouts
import QtQuick.Controls 2.15
import QtQuick.Shapes 1.6
import "Theme"

Item {
    id: root

    Mixxx.LibrarySourceTree {
        id: librarySources

        component DefaultDelegate: LibraryCell {
            Drag.active: dragArea.drag.active

            Menu {
                id: contextMenu
                title: qsTr("File")

                Menu {
                    title: qsTr("Load to")
                    enabled: {
                        model.hasCapabilities(Mixxx.LibraryTrackListModel.Capability.LoadToDeck) |
                        model.hasCapabilities(Mixxx.LibraryTrackListModel.Capability.LoadToSampler) |
                        model.hasCapabilities(Mixxx.LibraryTrackListModel.Capability.LoadToPreviewDeck)
                    }

                    Menu {
                        id: loadToDeckMenu
                        title: qsTr("Deck")
                        enabled: model.hasCapabilities(Mixxx.LibraryTrackListModel.Capability.LoadToDeck)
                        Instantiator {
                            model: 4
                            delegate: MenuItem {
                                text: `Deck ${modelData+1}`
                                onTriggered: Mixxx.PlayerManager.getPlayer(`[Channel${modelData+1}]`).loadTrack(track)
                            }

                            onObjectAdded: (index, object) => loadToDeckMenu.insertItem(index, object)
                            onObjectRemoved: (index, object) => loadToDeckMenu.removeItem(object)
                        }
                    }

                    Menu {
                        title: qsTr("Sampler")
                        enabled: model.hasCapabilities(Mixxx.LibraryTrackListModel.Capability.LoadToSampler)
                    }

                    // Instantiator {
                    //     id: recentFilesInstantiator
                    //     model: settings.recentFiles
                    //     delegate: MenuItem {
                    //         text: settings.displayableFilePath(modelData)
                    //         onTriggered: loadFile(modelData)
                    //     }

                    //     onObjectAdded: (index, object) => recentFilesMenu.insertItem(index, object)
                    //     onObjectRemoved: (index, object) => recentFilesMenu.removeItem(object)
                    // }
                }

                Menu {
                    id: addToPlaylistMenu
                    title: qsTr("Add to playlists")
                    enabled: {
                        model.hasCapabilities(Mixxx.LibraryTrackListModel.Capability.AddToTrackSet)
                    }

                    Instantiator {
                        model: 2
                        delegate: MenuItem {
                            text: `Playlist ${modelData+1}`
                            // onTriggered: loadFile(modelData)
                        }

                        onObjectAdded: (index, object) => addToPlaylistMenu.insertItem(index, object)
                        onObjectRemoved: (index, object) => addToPlaylistMenu.removeItem(object)
                    }

                    MenuSeparator {}

                    MenuItem {
                        text: qsTr("Create New Playlist")
                        // onTriggered: settings.clearRecentFiles()
                    }
                }
            }
            MouseArea {
                id: dragArea

                anchors.fill: parent
                drag.target: value
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onPressed: {
                    if (pressedButtons == Qt.LeftButton) {
                        tableView.selectionModel.selectRow(row);
                        parent.dragImage.grabToImage((result) => {
                                parent.Drag.imageSource = result.url;
                        });
                    } else {
                    }
                }
                onDoubleClicked: {
                    tableView.selectionModel.selectRow(row);
                    tableView.loadSelectedTrackIntoNextAvailableDeck(false);
                }
                onClicked: {
                    if (mouse.button === Qt.RightButton)
                        contextMenu.popup()
                }
                onPressAndHold: {
                    if (mouse.source === Qt.MouseEventNotSynthesized)
                        contextMenu.popup()
                }
            }

            Text {
                id: value
                anchors.fill: parent
                anchors.leftMargin: 15
                font.pixelSize: 14
                text: display
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                color: '#D9D9D9'
            }
        }

        defaultColumns: [
            Mixxx.TrackListColumn {
                preferredWidth: 110

                columnIdx: Mixxx.TrackListColumn.SQLColumns.Album

                delegate: Rectangle {
                    color: decoration
                    implicitHeight: 30

                    Image {
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectCrop
                        source: cover_art
                        clip: true
                        asynchronous: true
                    }
                }
            },
            Mixxx.TrackListColumn {
                label: "Preview"
                fillSpan: 3
                preferredWidth: 300
                columnIdx: Mixxx.TrackListColumn.SQLColumns.Title

                delegate: Rectangle {
                    color: 'transparent'
                    // implicitHeight: 30
                    anchors.fill: parent

                    readonly property var trackProxy: track

                    Mixxx.WaveformOverview {
                        anchors.fill: parent
                        channels: Mixxx.WaveformOverview.Channels.LeftChannel
                        renderer: Mixxx.WaveformOverview.Renderer.Filtered
                        colorHigh: Theme.white
                        colorMid: Theme.blue
                        colorLow: Theme.green
                        track: trackProxy
                    }
                    Rectangle {
                        id: border
                        color: '#202020'
                        width: 1
                        anchors {
                            top: parent.top
                            bottom: parent.bottom
                            right: parent.right
                        }
                    }
                }

            },
            Mixxx.TrackListColumn {
                label: "Title"
                fillSpan: 3
                columnIdx: Mixxx.TrackListColumn.SQLColumns.Title

                delegate: DefaultDelegate { }
            },
            Mixxx.TrackListColumn {
                label: "Artist"
                fillSpan: 2

                columnIdx: Mixxx.TrackListColumn.SQLColumns.Artist
                delegate: DefaultDelegate { }
            },
            Mixxx.TrackListColumn {
                label: "Album"
                fillSpan: 1

                columnIdx: Mixxx.TrackListColumn.SQLColumns.Album
                delegate: DefaultDelegate { }
            },
            Mixxx.TrackListColumn {
                label: "Year"
                preferredWidth: 80

                columnIdx: Mixxx.TrackListColumn.SQLColumns.Year
                delegate: DefaultDelegate { }
            },
            Mixxx.TrackListColumn {
                label: "Bpm"
                preferredWidth: 60

                columnIdx: Mixxx.TrackListColumn.SQLColumns.Bpm
                delegate: DefaultDelegate { }
            },
            Mixxx.TrackListColumn {
                label: "Key"
                preferredWidth: 70

                columnIdx: Mixxx.TrackListColumn.SQLColumns.Key
                delegate: DefaultDelegate { }
            },
            Mixxx.TrackListColumn {
                label: "File Type"
                preferredWidth: 70

                columnIdx: Mixxx.TrackListColumn.SQLColumns.FileType
                delegate: DefaultDelegate { }
            },
            Mixxx.TrackListColumn {
                label: "Bitrate"
                preferredWidth: 70

                columnIdx: Mixxx.TrackListColumn.SQLColumns.Bitrate
                delegate: DefaultDelegate { }
            }
        ]
        Mixxx.LibraryPlaylistSource {
            label: "Playlist"
            icon: "images/library_playlist.png"

            columns: librarySources.defaultColumns
        }
        Mixxx.LibraryCrateSource {
            label: "Crate"
            icon: "images/library_crate.png"

            columns: librarySources.defaultColumns
        }
        Mixxx.LibraryExplorerSource {
            label: "Explorer"
            icon: "images/library_explorer.png"
            columns: [
                Mixxx.TrackListColumn {

                    label: "Preview"
                    delegate: Rectangle {
                        color: decoration
                        implicitHeight: 30

                        Image {
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectCrop
                            source: cover_art
                            clip: true
                            asynchronous: true
                        }
                    }
                },
                Mixxx.TrackListColumn {

                    label: "Filename"
                    delegate: DefaultDelegate {}
                },
                Mixxx.TrackListColumn {

                    label: "Artist"
                    delegate: DefaultDelegate {}
                },
                Mixxx.TrackListColumn {

                    label: "Title"
                    delegate: DefaultDelegate {}
                },
                Mixxx.TrackListColumn {

                    label: "Album"
                    delegate: DefaultDelegate {}
                },
                Mixxx.TrackListColumn {

                    label: "Track #"
                    delegate: DefaultDelegate {}
                },
                Mixxx.TrackListColumn {

                    label: "Year"
                    delegate: DefaultDelegate {}
                },
                Mixxx.TrackListColumn {

                    label: "Genre"
                    delegate: DefaultDelegate {}
                },
                Mixxx.TrackListColumn {

                    label: "Composer"
                    delegate: DefaultDelegate {}
                },
                Mixxx.TrackListColumn {

                    label: "Comment"
                    delegate: DefaultDelegate {}
                },
                Mixxx.TrackListColumn {

                    label: "Duration"
                    delegate: DefaultDelegate {}
                },
                Mixxx.TrackListColumn {

                    label: "BPM"
                    delegate: DefaultDelegate {}
                },
                Mixxx.TrackListColumn {

                    label: "Key"
                    delegate: DefaultDelegate {}
                },
                Mixxx.TrackListColumn {

                    label: "Type"
                    delegate: DefaultDelegate {}
                },
                Mixxx.TrackListColumn {

                    label: "Bitrate"
                    delegate: DefaultDelegate {}
                },
                Mixxx.TrackListColumn {

                    label: "Location"
                    delegate: DefaultDelegate {}
                },
                Mixxx.TrackListColumn {

                    label: "Album Artist"
                    delegate: DefaultDelegate {}
                },
                Mixxx.TrackListColumn {

                    label: "Grouping"
                    delegate: DefaultDelegate {}
                },
                Mixxx.TrackListColumn {

                    label: "File Modified"
                    delegate: DefaultDelegate {}
                },
                Mixxx.TrackListColumn {

                    label: "File Created"
                    delegate: DefaultDelegate {}
                },
                Mixxx.TrackListColumn {

                    label: "ReplayGain"
                    delegate: DefaultDelegate {}
                }
            ]
        }
    }

    property var featureModel: librarySources.sidebar()
    property var tracksModel: librarySources.allTracks()

    Connections {
        target: featureModel
        function onTrackModelRequested(model) {
            console.log(`REQUESTED ${model} ${root.tracksModel}`)
            root.tracksModel = model
        }
    }

    SplitView {
        orientation: Qt.Horizontal
        anchors.fill: parent

        handle: Rectangle {
            id: handleDelegate
            implicitWidth: 8
            implicitHeight: 8
            color: Theme.libraryPanelSplitterBackground
            clip: true
            property color handleColor: SplitHandle.pressed || SplitHandle.hovered ? Theme.libraryPanelSplitterHandleActive : Theme.libraryPanelSplitterHandle
            property int handleSize: SplitHandle.pressed || SplitHandle.hovered ? 6 : 5

            ColumnLayout {
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

        SplitView {
            SplitView.minimumWidth: 100
            SplitView.preferredWidth: 415
            SplitView.maximumWidth: 600

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
            LibraryBrowser {
                model: root.featureModel
                SplitView.minimumHeight: 200
                SplitView.preferredHeight: 500

                SplitView.fillHeight: true

                onAllModel: {
                    root.tracksModel = librarySources.allTracks()
                }
            }

            Skin.LibraryPreviewDeck {
                SplitView.minimumHeight: 100
                SplitView.preferredHeight: 100
                SplitView.maximumHeight: 200
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton
                    onPressed: {
                        root.tracksModel = librarySources.allTracks()
                    }
                    // drag {
                    //     target: parent
                    // }
                }
            }
        }
        LibraryTrackList {
            SplitView.fillHeight: true

            model: root.tracksModel
        }
    }
}
