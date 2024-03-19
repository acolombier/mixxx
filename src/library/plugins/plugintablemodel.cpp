#include "library/plugins/plugintablemodel.h"

#include "library/plugins/pluginclient.h"
#include "library/queryutil.h"
#include "moc_plugintablemodel.cpp"

PluginTableModel::PluginTableModel(QObject* parent,
        TrackCollectionManager* pTrackCollectionManager,
        QSharedPointer<BaseTrackCache> trackSource,
        std::shared_ptr<PluginClient> client)
        : BaseExternalTrackModel(parent,
                  pTrackCollectionManager,
                  "mixxx.db.model.plugin.tablemodel",
                  "plugin_library",
                  trackSource),
          m_pClient(client) {
    QSqlQuery flush(m_database);
    flush.prepare("delete from plugin_playlist_tracks");

    if (!flush.exec()) {
        qWarning() << "Could not delete remove old entries from table "
                      "plugin_playlist_tracks : "
                   << flush.lastError();
    } else {
        qDebug() << "Plugin table entries of 'plugin_playlist_tracks' have been cleared.";
    }
    flush.prepare("delete from plugin_library");

    if (!flush.exec()) {
        qWarning() << "Could not delete remove old entries from table "
                      "plugin_library : "
                   << flush.lastError();
    } else {
        qDebug() << "Plugin table entries of 'plugin_library' have been cleared.";
    }
}

bool PluginTableModel::isColumnHiddenByDefault(int column) {
    if (column == fieldIndex(ColumnCache::COLUMN_LIBRARYTABLE_BITRATE)) {
        return true;
    }
    return BaseSqlTableModel::isColumnHiddenByDefault(column);
}
