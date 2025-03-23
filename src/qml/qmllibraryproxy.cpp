#include "qml/qmllibraryproxy.h"

#include <qqmlengine.h>

#include <QAbstractItemModel>

#include "library/library.h"
#include "library/librarytablemodel.h"
#include "moc_qmllibraryproxy.cpp"
#include "track/track.h"

namespace mixxx {
namespace qml {

QmlLibraryProxy::QmlLibraryProxy(QObject* parent)
        : QObject(parent) {
}

QmlLibraryTrackListModel* QmlLibraryProxy::model() const {
    auto* pModel = new QmlLibraryTrackListModel({}, s_pLibrary->trackTableModel());
    QQmlEngine::setObjectOwnership(pModel, QQmlEngine::JavaScriptOwnership);
    return pModel;
}

void QmlLibraryProxy::analyze(const QmlTrackProxy* track) const {
    if (!track->internal()) {
        return;
    }
    emit s_pLibrary->analyzeTracks({track->internal()->getId()});
}

// static
QmlLibraryProxy* QmlLibraryProxy::create(QQmlEngine* pQmlEngine, QJSEngine* pJsEngine) {
    // The implementation of this method is mostly taken from the code example
    // that shows the replacement for `qmlRegisterSingletonInstance()` when
    // using `QML_SINGLETON`.
    // https://doc.qt.io/qt-6/qqmlengine.html#QML_SINGLETON

    // The instance has to exist before it is used. We cannot replace it.
    VERIFY_OR_DEBUG_ASSERT(s_pLibrary) {
        qWarning() << "Library hasn't been registered yet";
        return nullptr;
    }
    return new QmlLibraryProxy(pQmlEngine);
}

} // namespace qml
} // namespace mixxx
