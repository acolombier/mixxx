#pragma once

#include <QDateTime>
#include <QHash>
#include <QIODevice>
#include <QMutex>
#include <QSemaphore>
#include <QThread>
#include <QVariant>

#include "plugin.grpc.pb.h"
#include "track/trackid.h"

class PluginTrack;
class PluginTrackDevice;
class PluginTracklist;

class PluginClient : public QThread {
    Q_OBJECT
  public:
    PluginClient();
    ~PluginClient();

    void run();
    void stop();

    bool initialized();

    std::shared_ptr<mixxx::plugin::ManifestReply> manifest() const {
        return m_pManifest;
    }

    std::shared_ptr<mixxx::plugin::BrowseReply> node(const QString& node_id = "") const;

    bool isTrackOpened(const PluginTrack&) const {
        // TODO implement
        return true;
    }

  public slots:
    void fetch_manifest() {
        emit manifest_requested();
    }
    void fetch_node(const QString& node_id = "") {
        emit node_requested(node_id);
    }
    void fetch_tracklist(const mixxx::plugin::Tracklist& tracklist) {
        emit fetch_requested(tracklist);
    }
    void send_event(const QString& username, const QString& password);
    void read(const QString& track_ref);

  protected:
    std::shared_ptr<PluginTrack> track_get(const QString& ref);
    qint64 track_open(const PluginTrackDevice&);
    void track_close(const PluginTrackDevice&);
    qint64 track_seek(const PluginTrackDevice&, qint64 maxSize);
    qint64 track_read(const PluginTrackDevice&,
            char* data,
            qint64 maxSize,
            qint64 offset,
            bool* isEof = nullptr);

    friend class PluginTrack;
    friend class PluginTrackDevice;

  private slots:
    void worker_manifest();
    void worker_browse(const QString& node_id);
    void worker_fetch(const mixxx::plugin::Tracklist& tracklist_id);

  signals:
    void manifest_requested();
    void node_requested(const QString& node_id);
    void fetch_requested(const mixxx::plugin::Tracklist& tracklist);

    void manifest_received(const mixxx::plugin::ManifestReply& manifest);
    void node_received(const QString& node_id, const mixxx::plugin::BrowseReply& node);
    void tracklist_track_fetched(const QString&,
            int position,
            const std::shared_ptr<PluginTrack>& track);
    void tracklist_fetched(const QString&, const QList<std::shared_ptr<PluginTrack>>& tracks);

    void ready();

  private:
    std::unique_ptr<mixxx::plugin::PluginService::Stub> m_pPluginStub;
    std::unique_ptr<mixxx::plugin::TrackService::Stub> m_pTrackStub;
    std::unique_ptr<mixxx::plugin::TracklistService::Stub> m_pTracklistStub;

    QHash<QString, std::shared_ptr<mixxx::plugin::BrowseReply>> m_nodes;

    std::shared_ptr<mixxx::plugin::ManifestReply> m_pManifest;

    QMutex m_mutex;

    /// Semaphore with capacity 1, which is left acquired, as long as the run
    /// loop of the thread runs
    QSemaphore m_busySemaphore;
};

class PluginTracklist : public QObject {
    Q_OBJECT
  public:
    qint64 id() const {
        return m_internal.id();
    }
    QString ref() const {
        return m_internal.ref().c_str();
    }
    QList<PluginTrack> tracks() const {
        return m_tracks;
    }
  public slots:
    void fetch();

  private:
    PluginTracklist(
            PluginClient* client,
            mixxx::plugin::Tracklist internal)
            : QObject(client), m_internal(internal) {
    }

    QList<PluginTrack> m_tracks;

    PluginClient* m_pClient;
    mixxx::plugin::Tracklist m_internal;

    friend class PluginClient;
};

class PluginTrackDevice : public QIODevice {
    Q_OBJECT
  public:
    PluginTrackDevice(const PluginTrackDevice&) = delete;

    bool atEnd() const override {
        return m_filesize >= 0 && m_seek == m_filesize;
    }
    qint64 bytesAvailable() const override {
        return 0;
    }
    qint64 bytesToWrite() const override {
        return 0;
    }
    bool isSequential() const override {
        return false;
    }
    qint64 pos() const override {
        return m_seek;
    }
    void close() override;
    qint64 skip(qint64 maxSize);
    bool seek(qint64 pos) override;
    bool open(QIODeviceBase::OpenMode mode) override; // setOpenMode
    qint64 readData(char* data, qint64 maxSize) override;
    qint64 writeData(const char* data, qint64 len) override {
        return -1;
    }
    qint64 size() const override {
        return m_filesize;
    }

  protected:
    const std::string& ref() const {
        return m_ref;
    }

  private:
    PluginTrackDevice(
            PluginClient* client,
            std::string ref)
            : QIODevice(), m_pClient(client), m_ref(ref) {
    }

    PluginClient* m_pClient;

    qint64 m_filesize{-1};
    qint64 m_seek{-1};

    std::string m_ref;

    friend class PluginTrack;
    friend class PluginClient;
};

class PluginTrack : public QObject {
    Q_OBJECT
  public:
    PluginTrack(const PluginTrack&) = delete;

    QString ref() const {
        return m_internal.ref().c_str();
    }
    QString title() const {
        return m_internal.title().c_str();
    }
    QString artist() const {
        return m_internal.artist().c_str();
    }
    QString album() const {
        return m_internal.album().c_str();
    }
    QString artwork() const {
        return m_internal.artwork().c_str();
    }
    qint64 size() const {
        return m_filesize;
    }
    QDateTime birthTime() const {
        // TODO
        return {};
    }
    QDateTime lastModified() const {
        // TODO
        return {};
    }
    std::unique_ptr<PluginTrackDevice> device() const {
        return std::unique_ptr<PluginTrackDevice>(
                new PluginTrackDevice(m_pClient, m_internal.ref()));
    }

    static std::shared_ptr<PluginTrack> fetch(const QUrl&);

  protected:
    const mixxx::plugin::Track& internal() const {
        return m_internal;
    }

  private:
    PluginTrack(
            PluginClient* client,
            mixxx::plugin::Track internal)
            : QObject(), m_pClient(client), m_internal(internal) {
    }

    PluginClient* m_pClient;

    qint64 m_filesize{-1};
    qint64 m_seek{-1};

    mixxx::plugin::Track m_internal;

    TrackId m_id;

    static QHash<QString, PluginClient*> s_pluginHandler;
    static QMutex s_trackLock;
    static QHash<QString, std::shared_ptr<PluginTrack>> s_trackCache;

    friend class PluginClient;
};
