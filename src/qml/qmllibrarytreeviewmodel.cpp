#include "qml/qmllibrarytreeviewmodel.h"

#include "library/sidebarmodel.h"
#include "library/treeitem.h"
#include "moc_qmllibrarytreeviewmodel.cpp"
#include "qml/asyncimageprovider.h"

namespace mixxx {
namespace qml {
namespace {
const QHash<int, QByteArray> kRoleNames = {
        {Qt::DisplayRole, "label"},
        {QmlLibraryTreeviewModel::IconRole, "icon"},
};

}

QmlLibraryTreeviewModel::QmlLibraryTreeviewModel(SidebarModel* pModel, QObject* pParent)
        : QIdentityProxyModel(pParent) {
    // pModel->select();
    setSourceModel(pModel);
}

QVariant QmlLibraryTreeviewModel::data(const QModelIndex& proxyIndex, int role) const {
    if (!proxyIndex.isValid()) {
        return {};
    }

    VERIFY_OR_DEBUG_ASSERT(checkIndex(proxyIndex)) {
        return {};
    }

    if (proxyIndex.column() > 0) {
        return {};
    }

    int column = -1;
    switch (role) {
    case LabelRole:
        return QIdentityProxyModel::data(proxyIndex, Qt::DisplayRole);
        break;
    case IconRole:
        return QIdentityProxyModel::data(proxyIndex, SidebarModel::IconNameRole);
        break;
    // case ArtistRole:
    //     column = pSourceModel->fieldIndex(ColumnCache::COLUMN_LIBRARYTABLE_ARTIST);
    //     break;
    // case BitrateRole:
    //     column = pSourceModel->fieldIndex(ColumnCache::COLUMN_LIBRARYTABLE_BITRATE);
    //     break;
    // case BpmLockRole:
    //     column = pSourceModel->fieldIndex(ColumnCache::COLUMN_LIBRARYTABLE_BPM_LOCK);
    //     break;
    // case BpmRole:
    //     column = pSourceModel->fieldIndex(ColumnCache::COLUMN_LIBRARYTABLE_BPM);
    //     break;
    // case ColorRole: {
    //     column = pSourceModel->fieldIndex(ColumnCache::COLUMN_LIBRARYTABLE_COLOR);
    //     const double colorValue = QIdentityProxyModel::data(
    //             proxyIndex.siblingAtColumn(column), Qt::DisplayRole)
    //                                       .toDouble();
    //     return colorFromRgbCode(colorValue);
    //     break;
    // }
    // case CommentRole:
    //     column = pSourceModel->fieldIndex(ColumnCache::COLUMN_LIBRARYTABLE_COMMENT);
    //     break;
    // case ComposerRole:
    //     column = pSourceModel->fieldIndex(ColumnCache::COLUMN_LIBRARYTABLE_COMPOSER);
    //     break;
    // case CoverArtUrlRole: {
    //     column = pSourceModel->fieldIndex(ColumnCache::COLUMN_TRACKLOCATIONSTABLE_LOCATION);
    //     const QString location = QIdentityProxyModel::data(
    //             proxyIndex.siblingAtColumn(column), Qt::DisplayRole)
    //                                      .toString();
    //     if (location.isEmpty()) {
    //         return {};
    //     }

    //     return AsyncImageProvider::trackLocationToCoverArtUrl(location);
    // }
    // case CoverArtColorRole: {
    //     column = pSourceModel->fieldIndex(ColumnCache::COLUMN_LIBRARYTABLE_COVERART_COLOR);
    //     const double colorValue = QIdentityProxyModel::data(
    //             proxyIndex.siblingAtColumn(column), Qt::DisplayRole)
    //                                       .toDouble();
    //     return colorFromRgbCode(colorValue);
    //     break;
    // }
    // case DatetimeAddedRole:
    //     column = pSourceModel->fieldIndex(ColumnCache::COLUMN_LIBRARYTABLE_DATETIMEADDED);
    //     break;
    // case DeletedRole:
    //     column = pSourceModel->fieldIndex(ColumnCache::COLUMN_LIBRARYTABLE_MIXXXDELETED);
    //     break;
    // case DurationSecondsRole:
    //     column = pSourceModel->fieldIndex(ColumnCache::COLUMN_LIBRARYTABLE_DURATION);
    //     break;
    // case FileTypeRole:
    //     column = pSourceModel->fieldIndex(ColumnCache::COLUMN_LIBRARYTABLE_FILETYPE);
    //     break;
    // case FileUrlRole: {
    //     column = pSourceModel->fieldIndex(ColumnCache::COLUMN_TRACKLOCATIONSTABLE_LOCATION);
    //     const QString location = QIdentityProxyModel::data(
    //             proxyIndex.siblingAtColumn(column), Qt::DisplayRole)
    //                                      .toString();
    //     if (location.isEmpty()) {
    //         return {};
    //     }
    //     return QUrl::fromLocalFile(location);
    // }
    // case GenreRole:
    //     column = pSourceModel->fieldIndex(ColumnCache::COLUMN_LIBRARYTABLE_GENRE);
    //     break;
    // case GroupingRole:
    //     column = pSourceModel->fieldIndex(ColumnCache::COLUMN_LIBRARYTABLE_GROUPING);
    //     break;
    // case KeyIdRole:
    //     column = pSourceModel->fieldIndex(ColumnCache::COLUMN_LIBRARYTABLE_KEY_ID);
    //     break;
    // case KeyRole:
    //     column = pSourceModel->fieldIndex(ColumnCache::COLUMN_LIBRARYTABLE_KEY);
    //     break;
    // case LastPlayedAtRole:
    //     column = pSourceModel->fieldIndex(ColumnCache::COLUMN_LIBRARYTABLE_LAST_PLAYED_AT);
    //     break;
    // case PlayedRole:
    //     column = pSourceModel->fieldIndex(ColumnCache::COLUMN_LIBRARYTABLE_PLAYED);
    //     break;
    // case RatingRole:
    //     column = pSourceModel->fieldIndex(ColumnCache::COLUMN_LIBRARYTABLE_RATING);
    //     break;
    // case ReplayGainRole:
    //     column = pSourceModel->fieldIndex(ColumnCache::COLUMN_LIBRARYTABLE_REPLAYGAIN);
    //     break;
    // case TimesPlayedRole:
    //     column = pSourceModel->fieldIndex(ColumnCache::COLUMN_LIBRARYTABLE_TIMESPLAYED);
    //     break;
    // case TitleRole:
    //     column = pSourceModel->fieldIndex(ColumnCache::COLUMN_LIBRARYTABLE_TITLE);
    //     break;
    // case TrackNumberRole:
    //     column = pSourceModel->fieldIndex(ColumnCache::COLUMN_LIBRARYTABLE_TRACKNUMBER);
    //     break;
    // case YearRole:
    //     column = pSourceModel->fieldIndex(ColumnCache::COLUMN_LIBRARYTABLE_YEAR);
    //     break;
    default:
        return QIdentityProxyModel::data(proxyIndex, role);
        break;
    }

    // if (column < 0) {
    return {};
    // }

    // return QIdentityProxyModel::data(proxyIndex.siblingAtColumn(column), Qt::DisplayRole);
}

int QmlLibraryTreeviewModel::columnCount(const QModelIndex& parent) const {
    return 1;
}
int QmlLibraryTreeviewModel::rowCount(const QModelIndex& parent) const {
    // VERIFY_OR_DEBUG_ASSERT(!parent.isValid()) {
    //     return 0;
    // }
    const auto pSourceModel = static_cast<SidebarModel*>(sourceModel());
    VERIFY_OR_DEBUG_ASSERT(pSourceModel) {
        return 0;
    }
    return pSourceModel->rowCount(parent);
}

QModelIndex QmlLibraryTreeviewModel::index(int row, int column, const QModelIndex& parent) const {
    return QIdentityProxyModel::index(row, column, parent);
}

QModelIndex QmlLibraryTreeviewModel::parent(const QModelIndex& index) const {
    return QIdentityProxyModel::parent(index);
}

QHash<int, QByteArray> QmlLibraryTreeviewModel::roleNames() const {
    return kRoleNames;
}

QVariant QmlLibraryTreeviewModel::get(int row) const {
    QModelIndex idx = index(row, 0);
    QVariantMap dataMap;
    for (auto it = kRoleNames.constBegin(); it != kRoleNames.constEnd(); it++) {
        dataMap.insert(it.value(), data(idx, it.key()));
    }
    return dataMap;
}

} // namespace qml
} // namespace mixxx
