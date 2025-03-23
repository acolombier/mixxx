#pragma once
#include <QObject>
#include <QQmlEngine>
#include <memory>

#include "qml/qmllibrarytracklistmodel.h"
#include "qml/qmllibrarytreeviewmodel.h"
#include "qmlplayerproxy.h"
#include "util/parented_ptr.h"

class Library;

namespace mixxx {
namespace qml {

class QmlLibraryTrackListModel;

class QmlLibraryProxy : public QObject {
    Q_OBJECT
    Q_PROPERTY(mixxx::qml::QmlLibraryTreeviewModel* sidebar MEMBER m_pSidebarProperty CONSTANT)
    Q_PROPERTY(QmlLibraryTrackListModel* model READ model CONSTANT)
    QML_NAMED_ELEMENT(Library)
    QML_SINGLETON

  public:
    explicit QmlLibraryProxy(QObject* parent = nullptr);

    static QmlLibraryProxy* create(QQmlEngine* pQmlEngine, QJSEngine* pJsEngine);
    static void registerLibrary(std::shared_ptr<Library> pLibrary) {
        s_pLibrary = std::move(pLibrary);
    }

    static Library* get() {
        return s_pLibrary.get();
    }

    QmlLibraryTrackListModel* model() const;
    Q_INVOKABLE void analyze(const QmlTrackProxy* track) const;

  private:
    static inline std::shared_ptr<Library> s_pLibrary;

    /// This needs to be a plain pointer because it's used as a `Q_PROPERTY` member variable.
    QmlLibraryTreeviewModel* m_pSidebarProperty;
};

} // namespace qml
} // namespace mixxx
