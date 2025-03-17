#include "qml/qmltreefromlistmodel.h"

#include <qalgorithms.h>
#include <qvariant.h>

#include <QAbstractListModel>
#include <QVariant>
#include <QtDebug>

#include "library/browse/browsefeature.h"
#include "library/trackset/crate/cratefeature.h"
#include "library/trackset/playlistfeature.h"
#include "moc_qmltreefromlistmodel.cpp"

namespace mixxx {
namespace qml {

namespace {
const QHash<int, QByteArray> kRoleNames = {
        {Qt::DisplayRole, "label"},
        {QmlSidebarModelProxy::IconRole, "icon"},
};
} // namespace

QHash<int, QByteArray> QmlSidebarModelProxy::roleNames() const {
    return kRoleNames;
}

QVariant QmlSidebarModelProxy::get(int row) const {
    QModelIndex idx = index(row, 0);
    QVariantMap dataMap;
    for (auto it = kRoleNames.constBegin(); it != kRoleNames.constEnd(); it++) {
        dataMap.insert(it.value(), data(idx, it.key()));
    }
    return dataMap;
}

QmlLibrarySource::QmlLibrarySource(QObject* parent)
        : QObject(parent) {
}

QmlLibraryPlaylistSource::QmlLibraryPlaylistSource(QObject* parent)
        : QmlLibrarySource(parent) {
}

QmlLibraryCrateSource::QmlLibraryCrateSource(QObject* parent)
        : QmlLibrarySource(parent) {
}

QmlLibraryExplorerSource::QmlLibraryExplorerSource(QObject* parent)
        : QmlLibrarySource(parent) {
}

LibraryFeature* QmlLibraryPlaylistSource::create() {
    return new PlaylistFeature(QmlLibraryProxy::get(), QmlConfigProxy::get());
}

LibraryFeature* QmlLibraryCrateSource::create() {
    return new CrateFeature(QmlLibraryProxy::get(), QmlConfigProxy::get());
}

LibraryFeature* QmlLibraryExplorerSource::create() {
    return new BrowseFeature(QmlLibraryProxy::get(), QmlConfigProxy::get(), nullptr);
}

QmlSidebarModelProxy::QmlSidebarModelProxy(QObject* parent)
        : SidebarModel(parent) {
}

QmlLibrarySourceTree::QmlLibrarySourceTree(QQuickItem* parent)
        : QQuickItem(parent),
          m_model(new QmlSidebarModelProxy(this)) {
}
QmlLibrarySourceTree::~QmlLibrarySourceTree() = default;

void QmlLibrarySourceTree::append_source(
        QQmlListProperty<QmlLibrarySource>* list, QmlLibrarySource* source) {
    reinterpret_cast<QList<QmlLibrarySource*>*>(list->data)->append(source);
    QmlLibrarySourceTree* librarySourceTree = qobject_cast<QmlLibrarySourceTree*>(list->object);
    if (librarySourceTree && librarySourceTree->isComponentComplete()) {
        librarySourceTree->m_model->update(librarySourceTree->m_sources);
    }
}

void QmlLibrarySourceTree::clear_source(QQmlListProperty<QmlLibrarySource>* p) {
    reinterpret_cast<QList<QmlLibrarySource*>*>(p->data)->clear();
    QmlLibrarySourceTree* librarySourceTree = qobject_cast<QmlLibrarySourceTree*>(p->object);
    if (librarySourceTree) {
        librarySourceTree->m_model->update(librarySourceTree->m_sources);
    }
}
void QmlLibrarySourceTree::replace_source(QQmlListProperty<QmlLibrarySource>* p,
        qsizetype idx,
        QmlLibrarySource* v) {
    return reinterpret_cast<QList<QmlLibrarySource*>*>(p->data)->replace(idx, v);
    QmlLibrarySourceTree* librarySourceTree = qobject_cast<QmlLibrarySourceTree*>(p->object);
    if (librarySourceTree && librarySourceTree->isComponentComplete()) {
        librarySourceTree->m_model->update(librarySourceTree->m_sources);
    }
}
void QmlLibrarySourceTree::removeLast_source(QQmlListProperty<QmlLibrarySource>* p) {
    return reinterpret_cast<QList<QmlLibrarySource*>*>(p->data)->removeLast();
    QmlLibrarySourceTree* librarySourceTree = qobject_cast<QmlLibrarySourceTree*>(p->object);
    if (librarySourceTree && librarySourceTree->isComponentComplete()) {
        librarySourceTree->m_model->update(librarySourceTree->m_sources);
    }
}

QQmlListProperty<QmlLibrarySource> QmlLibrarySourceTree::sources() {
    return QQmlListProperty<QmlLibrarySource>(this,
            &m_sources,
            &QmlLibrarySourceTree::append_source,
            &QmlLibrarySourceTree::count_source,
            &QmlLibrarySourceTree::at_source,
            &QmlLibrarySourceTree::clear_source,
            &QmlLibrarySourceTree::replace_source,
            &QmlLibrarySourceTree::removeLast_source);
}

void QmlLibrarySourceTree::componentComplete() {
    m_model->update(m_sources);
}

void QmlSidebarModelProxy::update(const QList<QmlLibrarySource*>& sources) {
    beginResetModel();
    qDeleteAll(m_sFeatures);
    for (const auto& librarySource : sources) {
        addLibraryFeature(librarySource->create());
        qDebug() << "LibrarySource:" << librarySource;
    }
    endResetModel();
}

QmlSidebarModelProxy::~QmlSidebarModelProxy() = default;

} // namespace qml
} // namespace mixxx
