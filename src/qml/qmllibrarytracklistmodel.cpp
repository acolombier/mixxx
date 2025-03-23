#include "qml/qmllibrarytracklistmodel.h"

#include <qnamespace.h>
#include <qobject.h>
#include <qqmlengine.h>
#include <qsortfilterproxymodel.h>
#include <qstandarditemmodel.h>
#include <qvariant.h>

#include "library/librarytablemodel.h"
#include "qml/asyncimageprovider.h"
#include "qml/qmlplayerproxy.h"
#include "qml/qmltreefromlistmodel.h"
#include "track/track.h"
#include "util/assert.h"

#include "moc_qmllibrarytracklistmodel.cpp"

namespace mixxx {
namespace qml {
namespace {
const QHash<int, QByteArray> kRoleNames = {
        {Qt::DisplayRole, "display"},
        {Qt::DecorationRole, "decoration"},
        {QmlLibraryTrackListModel::Delegate, "delegate"},
        {QmlLibraryTrackListModel::Track, "track"},
        {QmlLibraryTrackListModel::FileURL, "file_url"},
        {QmlLibraryTrackListModel::CoverArt, "cover_art"},
};

QColor colorFromRgbCode(double colorValue) {
    if (colorValue < 0 || colorValue > 0xFFFFFF) {
        return {};
    }

    QRgb rgbValue = static_cast<QRgb>(colorValue) | 0xFF000000;
    return QColor(rgbValue);
}
}

QmlLibraryTrackListModel::QmlLibraryTrackListModel(
        const QList<QmlTrackListColumn*>& librarySource,
        QAbstractItemModel* pModel,
        QObject* pParent)
        : QIdentityProxyModel(pParent),
          m_columns(librarySource) { // FIXME need to copy column

    auto* pTrackModel = dynamic_cast<TrackModel*>(pModel);
    VERIFY_OR_DEBUG_ASSERT(pTrackModel) {
        return;
    }
    pTrackModel->select();
    setSourceModel(pModel);
}

QVariant QmlLibraryTrackListModel::data(const QModelIndex& proxyIndex, int role) const {
    if (!proxyIndex.isValid()) {
        return {};
    }

    VERIFY_OR_DEBUG_ASSERT(checkIndex(proxyIndex)) {
        return {};
    }

    auto* const pTrackTableModel = qobject_cast<BaseTrackTableModel*>(sourceModel());

    auto* pColumn = m_columns[proxyIndex.column()];

    switch (role) {
    case Track: {
        if (pTrackTableModel == nullptr) {
            return {};
        }
        // qDebug() << "Track" <<
        // pTrackTableModel->getTrack(QIdentityProxyModel::mapToSource(proxyIndex)).get();
        auto* pTrack = new QmlTrackProxy(pTrackTableModel->getTrack(
                QIdentityProxyModel::mapToSource(proxyIndex)));
        QQmlEngine::setObjectOwnership(pTrack, QQmlEngine::JavaScriptOwnership);
        return QVariant::fromValue(pTrack);
    }
    case Qt::DecorationRole: {
        if (pTrackTableModel == nullptr) {
            return {};
        };
        return colorFromRgbCode(QIdentityProxyModel::data(
                proxyIndex.siblingAtColumn(pTrackTableModel->fieldIndex(
                        ColumnCache::COLUMN_LIBRARYTABLE_COLOR)),
                Qt::DisplayRole)
                        .toDouble());
    }
    case CoverArt: {
        if (pTrackTableModel == nullptr) {
            return {};
        };
        auto location = QIdentityProxyModel::data(
                proxyIndex.siblingAtColumn(pTrackTableModel->fieldIndex(
                        ColumnCache::COLUMN_TRACKLOCATIONSTABLE_LOCATION)),
                Qt::DisplayRole)
                                .toString();
        ;
        if (location.isEmpty()) {
            return {};
        }

        return AsyncImageProvider::trackLocationToCoverArtUrl(location);
    }
    case FileURL: {
        if (pTrackTableModel == nullptr) {
            return {};
        }
        return pTrackTableModel->getTrackUrl(QIdentityProxyModel::mapToSource(proxyIndex));
    }
    case Delegate:
        return QVariant::fromValue(pColumn->delegate());
        break;
    }
    if (pColumn->columnIdx() < 0) {
        // Use proxyIndex.column()
        return QIdentityProxyModel::data(proxyIndex, role);
    }
    return QIdentityProxyModel::data(
            proxyIndex.siblingAtColumn(pTrackTableModel != nullptr
                            ? pTrackTableModel->fieldIndex(
                                      static_cast<ColumnCache::Column>(
                                              pColumn->columnIdx()))
                            : pColumn->columnIdx()),
            role);
}

int QmlLibraryTrackListModel::columnCount(const QModelIndex& parent) const {
    VERIFY_OR_DEBUG_ASSERT(static_cast<QmlLibraryTrackListModel*>(
                                   parent.internalPointer()) != this) {
        return 0;
    }
    return m_columns.length();
}

QVariant QmlLibraryTrackListModel::headerData(
        int section, Qt::Orientation orientation, int role) const {
    VERIFY_OR_DEBUG_ASSERT(section >= 0 || section < m_columns.length()) {
        return {};
    }
    // TODO role
    return m_columns[section]->label();
}

QHash<int, QByteArray> QmlLibraryTrackListModel::roleNames() const {
    return kRoleNames;
}

QUrl QmlLibraryTrackListModel::getUrl(int row) const {
    auto* const pTrackTableModel = qobject_cast<BaseTrackTableModel*>(sourceModel());

    if (pTrackTableModel == nullptr) {
        // TODO search for column with role
        return {};
    }
    return pTrackTableModel->getTrackUrl(pTrackTableModel->index(row, 0));
}

QmlTrackProxy* QmlLibraryTrackListModel::getTrack(int row) const {
    auto* const pTrackTableModel = qobject_cast<BaseTrackTableModel*>(sourceModel());

    if (pTrackTableModel == nullptr) {
        // TODO search for column with role
        return {};
    }
    auto* pTrack = new QmlTrackProxy(pTrackTableModel->getTrack(pTrackTableModel->index(row, 0)));
    QQmlEngine::setObjectOwnership(pTrack, QQmlEngine::JavaScriptOwnership);
    return pTrack;
}

TrackModel::Capabilities QmlLibraryTrackListModel::getCapabilities() const {
    auto* const pTrackTableModel = qobject_cast<BaseTrackTableModel*>(sourceModel());
    if (pTrackTableModel != nullptr) {
        return pTrackTableModel->getCapabilities();
    }
    return TrackModel::Capability::None;
}
bool QmlLibraryTrackListModel::hasCapabilities(TrackModel::Capabilities caps) const {
    return (getCapabilities() & caps) == caps;
}
void QmlLibraryTrackListModel::sort(int column, Qt::SortOrder order) {
    VERIFY_OR_DEBUG_ASSERT(column >= 0 || column < m_columns.length()) {
        return;
    }
    auto* pColumn = m_columns[column];
    emit layoutAboutToBeChanged(QList<QPersistentModelIndex>(),
            QAbstractItemModel::VerticalSortHint);
    if (pColumn->columnIdx() < 0) {
        // Use proxyIndex.column()
        return sourceModel()->sort(column, order);
    }
    auto* const pTrackTableModel = qobject_cast<BaseTrackTableModel*>(sourceModel());
    sourceModel()->sort(pTrackTableModel != nullptr
                    ? pTrackTableModel->fieldIndex(
                              static_cast<ColumnCache::Column>(
                                      pColumn->columnIdx()))
                    : pColumn->columnIdx(),
            order);
    emit layoutChanged(QList<QPersistentModelIndex>(), QAbstractItemModel::VerticalSortHint);
}

} // namespace qml
} // namespace mixxx
