#include "library/plugins/pluginfeature.h"

#include <QMap>
#include <QMessageBox>
#include <QQuickWindow>
#include <QRegularExpression>
#include <QRegularExpressionMatch>
#include <QSettings>
#include <QtDebug>

#include "library/dao/trackschema.h"
#include "library/library.h"
#include "library/librarytablemodel.h"
#include "library/plugins/pluginclient.h"
#include "library/plugins/pluginplaylistmodel.h"
#include "library/plugins/plugintablemodel.h"
#include "library/plugins/plugintreemodel.h"
#include "library/queryutil.h"
#include "library/trackcollection.h"
#include "library/trackcollectionmanager.h"
#include "library/treeitem.h"
#include "moc_pluginfeature.cpp"
#include "plugin.grpc.pb.h"
#include "track/keyutils.h"
#include "util/sandbox.h"
#include "util/semanticversion.h"
#include "widget/wlibrary.h"
#include "widget/wlibrarypluginview.h"

namespace {
const QString kPluginLibraryTable = QStringLiteral("plugin_library");
const QString kPluginPlaylistsTable = QStringLiteral("plugin_playlists");
const QString kPluginPlaylistTracksTable = QStringLiteral("plugin_playlist_tracks");

int createPlaylist(const QSqlDatabase& database, const QString& ref) {
    QSqlQuery finder(database);
    finder.prepare("select id from plugin_playlists where name=:name");
    finder.bindValue(":name", ref);

    if (!finder.exec()) {
        LOG_FAILED_QUERY(finder) << "Could not get track ref:" << ref;
        return -1;
    }

    if (finder.next()) {
        int track_id = finder.value(finder.record().indexOf(LIBRARYTABLE_ID)).toInt();
        // qDebug() << "Plugin playlist" << ref << "already exist:" << track_id;
        return track_id;
    }

    QSqlQuery query(database);
    query.prepare(
            "INSERT INTO plugin_playlists (name)"
            "VALUES (:name)");
    query.bindValue(":name", ref);

    if (!query.exec()) {
        LOG_FAILED_QUERY(query) << "ref: " << ref;
        return -1;
    }

    return query.lastInsertId().toInt();
}

int insertTrackIntoPlaylist(const QSqlDatabase& database,
        const QString& playlistRef,
        int trackId,
        int position) {
    QSqlQuery finder(database);

    finder.prepare("select id from plugin_playlists where name=:name");
    finder.bindValue(":name", playlistRef);

    if (!finder.exec()) {
        LOG_FAILED_QUERY(finder) << "Could not find playlist:" << playlistRef;
    }

    if (finder.next()) {
        int playlistId = finder.value(finder.record().indexOf(LIBRARYTABLE_ID)).toInt();

        finder.prepare(
                "select id from plugin_playlist_tracks where "
                "playlist_id=:playlist_id and track_id=:track_id and "
                "position=:position");
        finder.bindValue(":playlist_id", playlistId);
        finder.bindValue(":track_id", trackId);
        finder.bindValue(":position", position);

        if (!finder.exec()) {
            LOG_FAILED_QUERY(finder) << "Could not add to playlist:" << playlistRef;
            return -1;
        }

        if (finder.next()) {
            int track_id = finder.value(finder.record().indexOf(LIBRARYTABLE_ID)).toInt();
            // qDebug() << "Plugin playlist" << playlistId << "already exist:" << track_id;
            return track_id;
        }

        QSqlQuery query(database);
        query.prepare(
                "INSERT INTO plugin_playlist_tracks (playlist_id, track_id, position) "
                "VALUES (:playlist_id, :track_id, :position)");
        query.bindValue(":playlist_id", playlistId);
        query.bindValue(":track_id", trackId);
        query.bindValue(":position", position);

        if (query.exec()) {
            return query.lastInsertId().toInt();
        }
        LOG_FAILED_QUERY(query);
    }
    return -1;
}

bool createLibraryTable(QSqlDatabase& database, const QString& tableName) {
    qDebug() << "Creating Plugin library table: " << tableName;

    QSqlQuery query(database);
    query.prepare(
            "CREATE TABLE IF NOT EXISTS " + tableName +
            " ("
            "    id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "    title TEXT,"
            "    artist TEXT,"
            "    album TEXT,"
            "    genre TEXT,"
            "    comment TEXT,"
            "    grouping TEXT,"
            "    year INTEGER,"
            "    duration INTEGER,"
            "    bitrate TEXT,"
            "    samplerate TEXT,"
            "    bpm FLOAT,"
            "    key TEXT,"
            "    location TEXT,"
            "    bpm_lock INTEGER,"
            "    datetime_added DEFAULT CURRENT_TIMESTAMP,"
            "    label TEXT,"
            "    composer TEXT,"
            "    filename TEXT,"
            "    filetype TEXT,"
            "    remixer TEXT,"
            "    size INTEGER,"
            "    tracknumber TEXT"
            ");");

    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        return false;
    }

    return true;
}

bool createPlaylistsTable(QSqlDatabase& database, const QString& tableName) {
    qDebug() << "Creating Plugin playlists table: " << tableName;

    QSqlQuery query(database);
    query.prepare(
            "CREATE TABLE IF NOT EXISTS " + tableName +
            " ("
            "    id INTEGER PRIMARY KEY,"
            "    name TEXT"
            ");");

    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        return false;
    }

    return true;
}

bool createPlaylistTracksTable(QSqlDatabase& database, const QString& tableName) {
    qDebug() << "Creating Plugin playlist tracks table: " << tableName;

    QSqlQuery query(database);
    query.prepare(
            "CREATE TABLE IF NOT EXISTS " + tableName +
            " ("
            "    id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "    playlist_id INTEGER REFERENCES plugin_playlists(id),"
            "    track_id INTEGER REFERENCES plugin_library(id),"
            "    position INTEGER"
            ");");

    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        return false;
    }

    return true;
}

bool dropTable(QSqlDatabase& database, const QString& tableName) {
    qDebug() << "Dropping Plugin table: " << tableName;

    QSqlQuery query(database);
    query.prepare("DROP TABLE IF EXISTS " + tableName);

    if (!query.exec()) {
        LOG_FAILED_QUERY(query);
        return false;
    }

    return true;
}
} // namespace

PluginFeature::PluginFeature(Library* pLibrary, UserSettingsPointer pConfig)
        : BaseExternalLibraryFeature(pLibrary, pConfig, QStringLiteral("plugin")),
          m_pClient(std::make_shared<PluginClient>()),
          m_pSidebarModel(make_parented<PluginTreeModel>(m_pClient, this)) {
    connect(m_pClient.get(), &PluginClient::ready, [this]() {
        emit featureLoadingFinished(this);
    });

    QString idColumn = LIBRARYTABLE_ID;
    QStringList columns = {
            LIBRARYTABLE_ID,
            LIBRARYTABLE_TITLE,
            LIBRARYTABLE_ARTIST,
            LIBRARYTABLE_ALBUM,
            LIBRARYTABLE_GENRE,
            LIBRARYTABLE_COMMENT,
            LIBRARYTABLE_GROUPING,
            LIBRARYTABLE_YEAR,
            LIBRARYTABLE_DURATION,
            LIBRARYTABLE_BPM,
            LIBRARYTABLE_KEY,
            LIBRARYTABLE_TRACKNUMBER,
            TRACKLOCATIONSTABLE_LOCATION,
            LIBRARYTABLE_BPM_LOCK};
    QStringList searchColumns = {
            LIBRARYTABLE_ARTIST,
            LIBRARYTABLE_TITLE,
            LIBRARYTABLE_ALBUM,
            LIBRARYTABLE_GENRE,
            LIBRARYTABLE_COMMENT,
            LIBRARYTABLE_GROUPING};

    m_pTrackSource = QSharedPointer<BaseTrackCache>::create(
            m_pTrackCollection,
            kPluginLibraryTable,
            std::move(idColumn),
            std::move(columns),
            std::move(searchColumns),
            false);
    m_pPluginPlaylistModel = std::make_unique<PluginPlaylistModel>(
            this, pLibrary->trackCollectionManager(), m_pTrackSource, m_pClient);

    QSqlDatabase database = m_pTrackCollection->database();
    ScopedTransaction transaction(database);
    // Drop any leftover temporary Plugin database tables if they exist
    dropTable(database, kPluginPlaylistTracksTable);
    dropTable(database, kPluginPlaylistsTable);
    dropTable(database, kPluginLibraryTable);

    // Create new temporary Plugin database tables
    createLibraryTable(database, kPluginLibraryTable);
    createPlaylistsTable(database, kPluginPlaylistsTable);
    createPlaylistTracksTable(database, kPluginPlaylistTracksTable);
    transaction.commit();

    connect(m_pClient.get(),
            &PluginClient::tracklist_track_fetched,
            this,
            &PluginFeature::onTracksAdded);
    connect(m_pClient.get(),
            &PluginClient::node_received,
            this,
            &PluginFeature::onNodeAdded);
    // connect(&m_databasesFutureWatcher,
    //         &QFutureWatcher<QList<TreeItem*>>::finished,
    //         this,
    //         &PluginFeature::onPluginDatabasesFound);
    // connect(&m_tracksFutureWatcher,
    //         &QFutureWatcher<QString>::finished,
    //         this,
    //         &PluginFeature::onTracksFound);

    // initialize the model
    m_pSidebarModel->setRootItem(TreeItem::newRoot(this));

    m_pPluginTrackModel = std::make_unique<PluginTableModel>(
            this, pLibrary->trackCollectionManager(), m_pTrackSource, m_pClient);

    emit featureIsLoading(this, false);

    connect(m_pClient.get(),
            &PluginClient::tracklist_fetched,
            [this](const QString&, const QList<std::shared_ptr<PluginTrack>>&) {
                // if (m_pPluginPlaylistModel->getPlaylistId() == tracklist_id){
                emit saveModelState();
                emit showTrackModel(m_pPluginPlaylistModel.get());
                // }
            });

    m_pClient->fetch_manifest();
    m_pClient->fetch_node();

    m_pClient->start(QThread::NormalPriority);
}

PluginFeature::~PluginFeature() {
    // m_database.close();
    // m_cancelImport = true;
    // m_future.waitForFinished();
    // delete m_pPluginTableModel;
    // delete m_pPluginPlaylistModel;
    m_pClient->stop();
    VERIFY_OR_DEBUG_ASSERT(m_pClient->wait(10000)) {
        qCritical() << "Unable to stop the plugin client in time";
        m_pClient->quit();
    }
}

QVariant PluginFeature::title() {
    return !m_pClient->initialized() ? "..." : m_pClient->manifest()->name().c_str();
}

TreeItemModel* PluginFeature::sidebarModel() const {
    return m_pSidebarModel.get();
}

void PluginFeature::activate() {
    qDebug() << "PluginFeature::activate()";
    
    TreeItem* item = m_pSidebarModel->getRootItem();
    VERIFY_OR_DEBUG_ASSERT(item){
        qWarning() << "PluginFeature::getRootItem() null - race condition?";
        return;
    }
    for (const auto& item: item->children()){
        auto aData = item->getData().toHash();
        auto node_id = aData.value("id", QVariant()).toString();
        if (!m_pClient->node(node_id)) {
            m_pClient->fetch_node(node_id);
        }
    }

    emit saveModelState();
    emit enableCoverArtDisplay(false);

    std::shared_ptr<mixxx::plugin::BrowseReply> node = m_pClient->node();
    if (!node) {
        qWarning() << "Cannot find the root node";
        m_pClient->fetch_node();
        return;
    }
    if (node->has_tracklist()) {
        m_pPluginPlaylistModel->setTracklist(node->tracklist());
    } else if (node->view().length()) {
        m_pluginView->setView(QByteArray::fromStdString(node->view()));
        emit switchToView("PLUGIN");
    }
}

void PluginFeature::activateChild(const QModelIndex& index) {
    qDebug() << "PluginFeature::activateChild()";
    if (!m_pClient->initialized()) {
        return;
    }

    // disconnect();

    // access underlying TreeItem object
    TreeItem* item = static_cast<TreeItem*>(index.internalPointer());
    auto aData = item->getData().toHash();
    auto node_id = aData.value("id", QVariant()).toString();
    std::shared_ptr<mixxx::plugin::BrowseReply> node = m_pClient->node(node_id);
    if (!node) {
        qWarning() << "Cannot find the node" << node_id;
        m_pClient->fetch_node(node_id);
        return;
    }

    if (!item->hasChildren()) {
        qDebug() << "Activate Plugin Playlist: " << aData.value("id", QVariant());
        if (node->has_tracklist()) {
            m_pPluginPlaylistModel->setTracklist(node->tracklist());
        } else if (node->view().length()) {
            m_pluginView->setView(QByteArray::fromStdString(node->view()), node_id);
            emit switchToView("PLUGIN");
        }
        emit saveModelState();
        emit showTrackModel(m_pPluginPlaylistModel.get());
        emit enableCoverArtDisplay(true);
        return;
    } else {
        for (auto& child : item->children()) {
            auto data = child->getData().toHash();
            VERIFY_OR_DEBUG_ASSERT(data.contains("id")) {
                qWarning() << "Incomplete node data" << data;
                continue;
            }
            m_pClient->fetch_node(data["id"].toString());
        }
    }
    emit enableCoverArtDisplay(false);
}

void PluginFeature::onRightClickChild(const QPoint& globalPos, const QModelIndex& index) {
}
void PluginFeature::bindLibraryWidget(WLibrary* pLibraryWidget,
        KeyboardEventFilter* keyboard) {
    // Q_UNUSED(keyboard);
    m_pluginView = new WLibraryPluginView;
    m_pluginView->setResizeMode(QQuickWidget::SizeRootObjectToView);
    pLibraryWidget->registerView("PLUGIN", m_pluginView);
}

void PluginFeature::onNodeAdded(const QString&, const mixxx::plugin::BrowseReply& node) {
    QSqlDatabase database = m_pTrackCollection->database();
    if (!node.has_tracklist()) {
        return;
    }

    auto tracklist = node.tracklist();

    if (tracklist.search() == mixxx::plugin::SearchMode::DELEGATED) {
        qWarning() << "Plugin playlist" << tracklist.ref().c_str()
                   << "is using delegated search. Unsupported";
    } else {
        qDebug() << "Adding plugin playlist" << tracklist.ref().c_str() << "to database";
    }
    QString tracklist_ref = QString::fromStdString(tracklist.ref());

    int tracklist_id = createPlaylist(database, QString::fromStdString(tracklist.ref()));
    qDebug() << "Plugin playlist" << tracklist_ref << "created as" << tracklist_id;
}
void PluginFeature::onLazyChildExpandation(const QModelIndex& index) {
    qDebug() << "PluginFeature::onLazyChildExpandation()";
    TreeItem* item = static_cast<TreeItem*>(index.internalPointer());

    auto aData = item->getData().toHash();
    qDebug() << "PluginFeature::onLazyChildExpandation()" << aData;
    auto node_id = aData.value("id", QVariant()).toString();
    qDebug() << "PluginFeature::onLazyChildExpandation()" << node_id;
    std::shared_ptr<mixxx::plugin::BrowseReply> node = m_pClient->node(node_id);
    if (!node) {
        qWarning() << "Cannot find the node" << node_id;
        m_pClient->fetch_node(node_id);
        return;
    }
}
void PluginFeature::onTracksAdded(const QString& tracklistRef,
        int position,
        const std::shared_ptr<PluginTrack>& track) {
    QSqlDatabase database = m_pTrackCollection->database();

    // QUrl track_url = QUrl(QString("plugin://%1").arg(QString::fromStdString(track.ref())));
    QString trackUrl = QString("plugin:///%1?format=ogg").arg(track->ref());
    // QUrlQuery query = QUrlQuery(track_url.query());
    // // TODO better handling of queryString
    // // FIXME detect from track.mime()
    // query.addQueryItem("format", "ogg");
    // track_url.setQuery(query);
    int trackId = -1;

    QSqlQuery finder(database);
    finder.prepare("select id from " + kPluginLibraryTable + " where location=:location");
    finder.bindValue(":location", trackUrl);

    if (!finder.exec()) {
        LOG_FAILED_QUERY(finder) << "Could not get track ref:" << trackUrl;
        return;
    }

    ScopedTransaction transaction(database);
    if (finder.next()) {
        trackId = finder.value(finder.record().indexOf(LIBRARYTABLE_ID)).toInt();
        // qDebug() << "Plugin playlist" << trackUrl << "already exist:" << trackId;
    } else {
        QSqlQuery query(database);
        query.prepare(
                "INSERT INTO " +
                kPluginLibraryTable + " (" +
                LIBRARYTABLE_TITLE + ", " +
                LIBRARYTABLE_ARTIST + ", " +
                LIBRARYTABLE_ALBUM + ", " +
                // LIBRARYTABLE_GENRE + ", " +
                // LIBRARYTABLE_COMMENT + ", " +
                // LIBRARYTABLE_GROUPING + ", " +
                // LIBRARYTABLE_YEAR + ", " +
                // LIBRARYTABLE_DURATION + ", " +
                // LIBRARYTABLE_BITRATE + ", " +
                // LIBRARYTABLE_SAMPLERATE + ", " +
                // LIBRARYTABLE_BPM + ", " +
                // LIBRARYTABLE_KEY + ", " +
                TRACKLOCATIONSTABLE_LOCATION +
                //  + ", " +
                // LIBRARYTABLE_BPM_LOCK + ", " +
                // LIBRARYTABLE_DATETIMEADDED + ", " +
                // "label "
                ") VALUES ("
                ":title, "
                ":artist, "
                ":album, "
                // ":genre, "
                // ":comment, "
                // ":grouping, "
                // ":year, "
                // ":duration, "
                // ":bitrate, "
                // ":samplerate, "
                // ":bpm, "
                // ":key, "
                ":location" // ", "
                // ":bpm_lock, "
                // ":datetime_added, "
                // ":label "
                ")");

        query.bindValue(":artist", track->artist());
        query.bindValue(":title", track->title());
        query.bindValue(":album", track->album());
        // query.bindValue(":genre", track.genre);
        // query.bindValue(":comment", track.comment);
        // query.bindValue(":grouping", track.grouping);
        // query.bindValue(":year", track.year);
        // query.bindValue(":duration", track.duration);
        // query.bindValue(":bitrate", track.bitrate);
        // query.bindValue(":samplerate", track.samplerate);
        // query.bindValue(":bpm", track.bpm);
        // query.bindValue(":key", track.key);
        query.bindValue(":location", trackUrl);
        // query.bindValue(":bpm_lock", track.beatgridlocked);
        // query.bindValue(":datetime_added", track.datetimeadded);
        // query.bindValue(":label", track.label);

        if (!query.exec()) {
            LOG_FAILED_QUERY(query);
        } else {
            trackId = query.lastInsertId().toInt();
        }
    }
    insertTrackIntoPlaylist(database, tracklistRef, trackId, position);
    transaction.commit();
    emit saveModelState();
    emit showTrackModel(m_pPluginPlaylistModel.get());
}

// void PluginFeature::linkClicked(const QUrl& link) {
//     if (QString(link.path()) == "refresh") {
//         activate();
//     } else {
//         qDebug() << "Unknown link clicked" << link;
//     }
// }

void PluginFeature::bindSidebarWidget(WLibrarySidebar* pSidebarWidget) {
    // store the sidebar widget pointer for later use in onRightClickChild
    Q_UNUSED(pSidebarWidget);
}
