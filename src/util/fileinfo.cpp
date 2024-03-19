#include "util/fileinfo.h"

#include "library/plugins/pluginclient.h"

namespace mixxx {

FileInfo::FileInfo(
        const QUrl& file)
        : m_url(file), m_bIsPlugin(file.scheme() == "plugin") {
    if (!m_bIsPlugin) {
        m_fileInfo = QFileInfo(file.toLocalFile());
    } else {
        m_plugintrack = PluginTrack::fetch(m_url);
    }
    DEBUG_ASSERT(m_bIsPlugin || !file.toLocalFile().isEmpty());
}
void FileInfo::refresh() {
    if (m_bIsPlugin) {
        m_plugintrack = PluginTrack::fetch(m_url);
    } else {
        m_fileInfo.refresh();
    }
}

// static
bool FileInfo::isRootSubCanonicalLocation(
        const QString& rootCanonicalLocation,
        const QString& subCanonicalLocation) {
    VERIFY_OR_DEBUG_ASSERT(!rootCanonicalLocation.isEmpty()) {
        return false;
    }
    VERIFY_OR_DEBUG_ASSERT(!subCanonicalLocation.isEmpty()) {
        return false;
    }
    DEBUG_ASSERT(QDir::isAbsolutePath(rootCanonicalLocation));
    DEBUG_ASSERT(QDir::isAbsolutePath(subCanonicalLocation));
    if (subCanonicalLocation.size() < rootCanonicalLocation.size()) {
        return false;
    }
    if (subCanonicalLocation.size() > rootCanonicalLocation.size() &&
            subCanonicalLocation[rootCanonicalLocation.size()] != QChar('/')) {
        return false;
    }
    return subCanonicalLocation.startsWith(rootCanonicalLocation);
}

QString FileInfo::resolveCanonicalLocation() {
    // Note: We return here the cached value, that was calculated just after
    // init this FileInfo object. This will avoid repeated use of the time
    // consuming file I/O.
    QString currentCanonicalLocation = canonicalLocation();
    if (!currentCanonicalLocation.isEmpty()) {
        return currentCanonicalLocation;
    }
    m_fileInfo.refresh();
    // Return whatever is available after the refresh
    return canonicalLocation();
}

std::unique_ptr<QIODevice> FileInfo::toQIODevice(QObject* parent) const {
    if (m_bIsPlugin) {
        return m_plugintrack->device();
        ;
    }
    return std::make_unique<QFile>(location(), parent);
}

qint64 FileInfo::sizeInBytes() const {
    if (m_bIsPlugin) {
        return m_plugintrack->size();
    }
    return m_fileInfo.size();
}

QDateTime FileInfo::birthTime() const {
    if (m_bIsPlugin) {
        return m_plugintrack->birthTime();
    }
    return m_fileInfo.birthTime();
}

QDateTime FileInfo::lastModified() const {
    if (m_bIsPlugin) {
        return m_plugintrack->lastModified();
    }
    return m_fileInfo.lastModified();
}

} // namespace mixxx
