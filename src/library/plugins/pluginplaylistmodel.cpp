#include "library/plugins/pluginplaylistmodel.h"

#include "library/plugins/pluginclient.h"
#include "library/queryutil.h"
#include "moc_pluginplaylistmodel.cpp"
#include "track/track.h"

PluginPlaylistModel::PluginPlaylistModel(QObject* parent,
        TrackCollectionManager* pTrackCollectionManager,
        QSharedPointer<BaseTrackCache> trackSource,
        std::shared_ptr<PluginClient> client)
        : BaseExternalPlaylistModel(parent,
                  pTrackCollectionManager,
                  "mixxx.db.model.plugin.playlistmodel",
                  "plugin_playlists",
                  "plugin_playlist_tracks",
                  trackSource),
          m_pClient(client) {
}

bool PluginPlaylistModel::isColumnHiddenByDefault(int column) {
    if (
            column == fieldIndex(ColumnCache::COLUMN_LIBRARYTABLE_BITRATE) ||
            column == fieldIndex(ColumnCache::COLUMN_LIBRARYTABLE_BPM_LOCK) ||
            column == fieldIndex(ColumnCache::COLUMN_TRACKLOCATIONSTABLE_LOCATION) ||
            column == fieldIndex(ColumnCache::COLUMN_LIBRARYTABLE_COMMENT) ||
            column == fieldIndex(ColumnCache::COLUMN_LIBRARYTABLE_ID)) {
        return true;
    }
    return BaseSqlTableModel::isColumnHiddenByDefault(column);
}
QString PluginPlaylistModel::getTrackLocation(const QModelIndex& index) const {
    if (!index.isValid()) {
        return QString();
    }
    QString nativeLocation =
            index.sibling(index.row(),
                         fieldIndex(ColumnCache::COLUMN_TRACKLOCATIONSTABLE_LOCATION))
                    .data()
                    .toString();
    QUrl location = QUrl(nativeLocation);
    if (!location.isLocalFile() && location.scheme() == "plugin") {
        return location.url();
    }
    return QDir::fromNativeSeparators(nativeLocation);
}

QUrl PluginPlaylistModel::getTrackUrl(const QModelIndex& index) const {
    const QString trackLocation = getTrackLocation(index);
    DEBUG_ASSERT(trackLocation.trimmed() == trackLocation);
    if (trackLocation.isEmpty()) {
        return {};
    }
    QUrl url = QUrl(trackLocation);
    if (!url.isLocalFile() && url.scheme() == "plugin") {
        return url;
    }
    return QUrl::fromLocalFile(trackLocation);
}

void PluginPlaylistModel::setTracklist(const mixxx::plugin::Tracklist& tracklist) {
    m_pClient->fetch_tracklist(tracklist);
    setPlaylist(QString::fromStdString(tracklist.ref()));
}
