#include "library/plugins/pluginclient.h"

#include <grpcpp/ext/proto_server_reflection_plugin.h>
#include <grpcpp/grpcpp.h>

#include <QUrl>
#include <QtGlobal>
#include <memory>

#include "moc_pluginclient.cpp"
#include "plugin.grpc.pb.h"
#include "util/assert.h"
#include "util/compatibility/qmutex.h"

using namespace grpc;
using namespace mixxx::plugin;

QHash<QString, PluginClient*> PluginTrack::s_pluginHandler = {};
QMutex PluginTrack::s_trackLock;
QHash<QString, std::shared_ptr<PluginTrack>> PluginTrack::s_trackCache;

void PluginTrackDevice::close() {
    if (!openMode()) {
        return;
    }
    // qDebug() << "Closing" << ref();
    setOpenMode(QIODeviceBase::NotOpen);
    m_pClient->track_close(*this);
}
qint64 PluginTrackDevice::skip(qint64 maxSize) {
    if (!(openMode() & ReadOnly)) {
        return -1;
    }
    int newPos = m_pClient->track_seek(*this, m_seek + maxSize);
    if (newPos >= 0) {
        m_seek = newPos;
    }
    return newPos;
}
bool PluginTrackDevice::seek(qint64 pos) {
    if (!(openMode() & ReadOnly)) {
        return -1;
    }
    int newPos = m_pClient->track_seek(*this, pos);
    if (newPos >= 0) {
        m_seek = newPos;
    }
    return newPos == pos;
}
bool PluginTrackDevice::open(QIODeviceBase::OpenMode mode) {
    if (mode & WriteOnly) {
        qDebug() << "Cannot option plugin track in write";
        return false;
    }
    if (openMode() & ReadOnly) {
        qDebug() << "Already opened";
        return true;
    }
    // qDebug() << "Opening" << ref();
    if ((m_filesize = m_pClient->track_open(*this)) < 0) {
        return false;
    }
    m_seek = 0;
    setOpenMode(ReadOnly | Unbuffered);
    return true;

} // setOpenMode
qint64 PluginTrackDevice::readData(char* data, qint64 maxSize) {
    if (!(openMode() | ReadOnly)) {
        qWarning() << "PluginTrackDevice::readData: track" << ref().c_str() << "is not open";
        return -1;
    }

    bool eof;
    qint64 read = m_pClient->track_read(*this, data, maxSize, m_seek, &eof);
    // qDebug() << "PluginTrackDevice::readData: read" << read << "eof" << eof;
    if (read > 0) {
        m_seek += read;
    } else if (read < 0) {
        return read;
    }

    return eof ? -1 : read;
}

std::shared_ptr<PluginTrack> PluginTrack::fetch(const QUrl& url) {
    auto locker = lockMutex(&PluginTrack::s_trackLock);
    PluginClient* pClient = PluginTrack::s_pluginHandler.value(url.scheme(), nullptr);
    if (!pClient) {
        qWarning() << "Unknown plugin scheme" << url.scheme();
        return std::shared_ptr<PluginTrack>();
    }
    if (!PluginTrack::s_trackCache.contains(url.path())) {
        qDebug() << "track" << url.path() << "not found in cache";
        auto track = pClient->track_get(url.path());
        if (!track) {
            return track;
        }
        PluginTrack::s_trackCache.insert(url.path(), std::move(track));
    }
    return PluginTrack::s_trackCache[url.path()];
}

void PluginTracklist::fetch() {
}

PluginClient::PluginClient()
        : m_busySemaphore(0) {
    moveToThread(this);

    connect(this, &PluginClient::manifest_requested, this, &PluginClient::worker_manifest);
    connect(this, &PluginClient::node_requested, this, &PluginClient::worker_browse);
    connect(this, &PluginClient::fetch_requested, this, &PluginClient::worker_fetch);
    connect(this, &QThread::terminate, this, &QThread::quit);

    PluginTrack::s_pluginHandler.insert("plugin", this);
}
PluginClient::~PluginClient() {
    PluginTrack::s_pluginHandler.remove("plugin");
}

bool PluginClient::initialized() {
    auto locker = lockMutex(&m_mutex);
    return m_pManifest && m_nodes.contains("");
}

std::shared_ptr<PluginTrack> PluginClient::track_get(const QString& ref) {
    // m_busySemaphore.acquire();
    mixxx::plugin::TrackRequest request;
    mixxx::plugin::TrackResponse reply;
    ClientContext context;
    request.set_ref(ref.toStdString());
    {
        auto locker = lockMutex(&m_mutex);

        // TODO mark as open

        Status status = m_pTrackStub->Get(&context, request, &reply);
        // m_busySemaphore.release();
        if (!status.ok()) {
            qWarning() << "Cannot get track" << ref << ": "
                       << status.error_code() << ": " << status.error_message().c_str();
            return std::shared_ptr<PluginTrack>(nullptr);
        }
    }
    return std::shared_ptr<PluginTrack>(new PluginTrack(this, reply.track()));
}

qint64 PluginClient::track_open(const PluginTrackDevice& track) {
    // m_busySemaphore.acquire();
    mixxx::plugin::OpenRequest request;
    mixxx::plugin::OpenResponse reply;
    ClientContext context;
    request.mutable_track()->set_ref(track.ref());
    {
        auto locker = lockMutex(&m_mutex);

        // TODO mark as open

        Status status = m_pTrackStub->Open(&context, request, &reply);
        // m_busySemaphore.release();
        if (!status.ok()) {
            qWarning() << "Cannot open track" << track.ref().c_str() << ": "
                       << status.error_code() << ": " << status.error_message().c_str();
            return -1;
        }
    }
    return reply.filesize();
}

qint64 PluginClient::track_seek(const PluginTrackDevice& track, qint64 maxSize) {
    // m_busySemaphore.acquire();
    mixxx::plugin::SeekRequest request;
    mixxx::plugin::SeekResponse reply;
    ClientContext context;
    request.mutable_track()->set_ref(track.ref());
    request.set_position(maxSize);
    qDebug() << "Seeking to" << maxSize << "bytes on" << track.ref().c_str();
    {
        auto locker = lockMutex(&m_mutex);

        // TODO mark as open

        Status status = m_pTrackStub->Seek(&context, request, &reply);
        // m_busySemaphore.release();
        if (!status.ok()) {
            qWarning() << "Cannot seek track" << track.ref().c_str() << ": "
                       << status.error_code() << ": " << status.error_message().c_str();
            return -1;
        }
        return reply.position();
    }
}

void PluginClient::track_close(const PluginTrackDevice& track) {
    // m_busySemaphore.acquire();
    mixxx::plugin::CloseRequest request;
    mixxx::plugin::CloseResponse reply;
    ClientContext context;
    request.mutable_track()->set_ref(track.ref());
    {
        auto locker = lockMutex(&m_mutex);

        // TODO mark as open

        Status status = m_pTrackStub->Close(&context, request, &reply);
        // m_busySemaphore.release();
        if (!status.ok()) {
            qWarning() << "Cannot close track" << track.ref().c_str() << ": "
                       << status.error_code() << ": " << status.error_message().c_str();
        }
    }
}

qint64 PluginClient::track_read(const PluginTrackDevice& track,
        char* data,
        qint64 maxSize,
        qint64 offset,
        bool* isEof) {
    // m_busySemaphore.acquire();
    mixxx::plugin::ReadRequest request;
    mixxx::plugin::ReadChunk chunk;
    ClientContext context;
    request.mutable_track()->set_ref(track.ref());
    request.set_limit(maxSize);
    request.set_offset(offset);
    // qDebug() << "Reading up to" << maxSize << "bytes from " << offset << "
    // on" << track.ref().c_str();
    {
        // TODO verify mark as open
        auto locker = lockMutex(&m_mutex);

        std::unique_ptr<ClientReader<mixxx::plugin::ReadChunk>> reader(
                m_pTrackStub->Read(&context, request));

        qint64 read = 0;
        while (reader->Read(&chunk)) {
            std::size_t toCopy = qMin(chunk.data().size(),
                    static_cast<std::size_t>(maxSize - read));
            // qDebug() << "Got chunk of " << chunk.data().size() << " bytes.
            // Copying" << toCopy << "bytes";
            memcpy(data, chunk.data().c_str(), toCopy);
            data += toCopy;
            read += toCopy;
        }
        if (isEof) {
            *isEof = chunk.eof();
        }
        Status status = reader->Finish();
        // m_busySemaphore.release();
        // qDebug() << "Read" << read << "bytes on" << maxSize << "requested
        // from " << offset << " on" << track.ref().c_str();
        if (!status.ok()) {
            qWarning() << "Cannot read track" << track.ref().c_str() << ": "
                       << status.error_code() << ": " << status.error_message().c_str();
            return -1;
        }
        return read;
    }
}

std::shared_ptr<mixxx::plugin::BrowseReply> PluginClient::node(const QString& node_id) const {
    return m_nodes.value(node_id, std::shared_ptr<mixxx::plugin::BrowseReply>());
}

void PluginClient::worker_manifest() {
    // m_busySemaphore.acquire();
    mixxx::plugin::ManifestRequest request;
    mixxx::plugin::ManifestReply reply;
    ClientContext context;
    Status status = m_pPluginStub->Manifest(&context, request, &reply);
    if (!status.ok()) {
        qWarning() << status.error_code() << ": " << status.error_message().c_str();
    } else {
        emit manifest_received(reply);
        auto locker = lockMutex(&m_mutex);
        m_pManifest = std::make_shared<mixxx::plugin::ManifestReply>(std::move(reply));
    }
    // m_busySemaphore.release();
}

void PluginClient::worker_browse(const QString& node_id) {
    // m_busySemaphore.acquire();
    mixxx::plugin::BrowseRequest request;
    if (!node_id.isEmpty()) {
        request.mutable_node()->set_id(node_id.toStdString());
    }
    mixxx::plugin::BrowseReply reply;
    ClientContext context;
    Status status = m_pPluginStub->Browse(&context, request, &reply);
    if (!status.ok()) {
        qWarning() << status.error_code() << ": " << status.error_message().c_str();
    } else {
        auto locker = lockMutex(&m_mutex);
        emit node_received(node_id, reply);
        m_nodes.insert(node_id, std::make_shared<mixxx::plugin::BrowseReply>(std::move(reply)));
    }
    // m_busySemaphore.release();
}

void PluginClient::send_event(const QString& username, const QString& password) {
    // m_busySemaphore.acquire();
    mixxx::plugin::ViewEvent request;
    mixxx::plugin::SideEffect reply;
    ClientContext context;
    request.mutable_submit()->set_id("login");
    request.mutable_submit()->set_payload("username=&password=");
    Status status = m_pPluginStub->Event(&context, request, &reply);
    if (!status.ok()) {
        qWarning() << status.error_code() << ": " << status.error_message().c_str();
    }
    // m_busySemaphore.release();
}

void PluginClient::read(const QString& track_ref) {
    // m_busySemaphore.acquire();
    mixxx::plugin::ReadRequest request;
    mixxx::plugin::ReadChunk chunk;
    ClientContext context;
    request.mutable_track()->set_ref(track_ref.toStdString());
    std::unique_ptr<ClientReader<ReadChunk>> reader(m_pTrackStub->Read(&context, request));

    while (reader->Read(&chunk)) {
        // emit chunk.data().c_str(), chunk.data().size();
        qDebug() << "Got chunk of " << chunk.data().size() << " bytes";
    }

    Status status = reader->Finish();
    if (!status.ok()) {
        qWarning() << status.error_code() << ": " << status.error_message().c_str();
    }
    // m_busySemaphore.release();
}

void PluginClient::worker_fetch(const mixxx::plugin::Tracklist& tracklist) {
    // m_busySemaphore.acquire();
    mixxx::plugin::FetchContentRequest request;
    mixxx::plugin::Track reply;
    ClientContext context;
    request.mutable_tracklist()->set_ref(tracklist.ref());
    std::unique_ptr<ClientReader<Track>> reader(m_pTracklistStub->FetchContent(&context, request));

    QList<std::shared_ptr<PluginTrack>> tracks;

    qDebug() << "Fetching plugin tracklist" << tracklist.ref().c_str();

    while (reader->Read(&reply)) {
        auto lock = lockMutex(&PluginTrack::s_trackLock);
        QString ref = "/" + QString::fromStdString(reply.ref());
        // qDebug() << "Fetched track with ref" << ref;
        if (!PluginTrack::s_trackCache.contains(ref)) {
            PluginTrack::s_trackCache.insert(ref,
                    std::shared_ptr<PluginTrack>(new PluginTrack(this, reply)));
        }
        emit tracklist_track_fetched(QString::fromStdString(tracklist.ref()),
                tracks.size(),
                PluginTrack::s_trackCache[ref]);
        tracks << PluginTrack::s_trackCache[ref];
    }

    Status status = reader->Finish();
    if (!status.ok()) {
        qWarning() << status.error_code() << ": " << status.error_message().c_str();
    } else {
        emit tracklist_fetched(QString::fromStdString(tracklist.ref()), tracks);
    }
    // m_busySemaphore.release();
}

void PluginClient::stop() {
    VERIFY_OR_DEBUG_ASSERT(QThread::currentThread() != this) {
        return;
    }
    // m_busySemaphore.acquire();
    terminate();
}
void PluginClient::run() {
    VERIFY_OR_DEBUG_ASSERT(QThread::currentThread() == this) {
        return;
    };
    QThread::currentThread()->setObjectName("PluginGRPCClient");
    std::string target_str("unix:/tmp/mixxx_plugin_test.sock");
    grpc::ChannelArguments args;
    args.SetString(GRPC_ARG_DEFAULT_AUTHORITY, "librespot");
    auto channel = grpc::CreateCustomChannel(target_str, grpc::InsecureChannelCredentials(), args);
    m_pPluginStub = mixxx::plugin::PluginService::NewStub(channel);
    m_pTrackStub = mixxx::plugin::TrackService::NewStub(channel);
    m_pTracklistStub = mixxx::plugin::TracklistService::NewStub(channel);

    // m_busySemaphore.release();

    exec();

    qDebug() << "Plugin client exited";
}
