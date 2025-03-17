#pragma once

#include <qquickitem.h>
#include <qvariant.h>

#include <QAbstractItemModel>
#include <QQmlListProperty>
#include <QQmlParserStatus>
#include <QtQml>

#include "library/libraryfeature.h"
#include "library/sidebarmodel.h"
#include "library/treeitem.h"
#include "qmlconfigproxy.h"
#include "qmllibraryproxy.h"
#include "util/parented_ptr.h"

namespace mixxx {
namespace qml {

class QmlLibrarySource : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString label MEMBER m_label)
    Q_PROPERTY(QString icon MEMBER m_icon)
    QML_ANONYMOUS
  public:
    explicit QmlLibrarySource(QObject* parent = nullptr);
    virtual LibraryFeature* create() = 0;
    const QString& label() const {
        return m_label;
    }
    const QString& icon() const {
        return m_icon;
    }

  protected:
    QString m_label;
    QString m_icon;
};

class QmlLibraryPlaylistSource : public QmlLibrarySource {
    Q_OBJECT
    QML_NAMED_ELEMENT(LibraryPlaylistSource)
  public:
    explicit QmlLibraryPlaylistSource(QObject* parent = nullptr);
    LibraryFeature* create() override;

  private:
    QmlLibraryProxy* m_library;
    QmlConfigProxy* m_config;
};

class QmlLibraryCrateSource : public QmlLibrarySource {
    Q_OBJECT
    QML_NAMED_ELEMENT(LibraryCrateSource)
  public:
    explicit QmlLibraryCrateSource(QObject* parent = nullptr);
    LibraryFeature* create() override;

  private:
    QmlLibraryProxy* m_library;
    QmlConfigProxy* m_config;
};

class QmlLibraryExplorerSource : public QmlLibrarySource {
    Q_OBJECT
    QML_NAMED_ELEMENT(LibraryExplorerSource)
  public:
    explicit QmlLibraryExplorerSource(QObject* parent = nullptr);
    LibraryFeature* create() override;

  private:
    QmlLibraryProxy* m_library;
    QmlConfigProxy* m_config;
};

class QmlSidebarModelProxy : public SidebarModel {
    Q_OBJECT
    QML_ANONYMOUS
  public:
    enum Roles {
        LabelRole = Qt::UserRole,
        IconRole,
    };
    Q_ENUM(Roles);
    Q_DISABLE_COPY_MOVE(QmlSidebarModelProxy)
    explicit QmlSidebarModelProxy(QObject* parent = nullptr);
    ~QmlSidebarModelProxy() override;

    void update(const QList<QmlLibrarySource*>& sources);
    QHash<int, QByteArray> roleNames() const override;
    Q_INVOKABLE QVariant get(int row) const;
};

class QmlLibrarySourceTree : public QQuickItem {
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)
    Q_PROPERTY(QQmlListProperty<QmlLibrarySource> sources READ sources)
    Q_CLASSINFO("DefaultProperty", "sources")
    QML_NAMED_ELEMENT(LibrarySourceTree)

  public:
    Q_DISABLE_COPY_MOVE(QmlLibrarySourceTree)
    explicit QmlLibrarySourceTree(QQuickItem* parent = nullptr);
    ~QmlLibrarySourceTree() override;

    void componentComplete() override;

    QQmlListProperty<QmlLibrarySource> sources();
    Q_INVOKABLE QmlSidebarModelProxy* model() const {
        return m_model.get();
    };

  private:
    static void append_source(QQmlListProperty<QmlLibrarySource>* list, QmlLibrarySource* slice);
    static qsizetype count_source(QQmlListProperty<QmlLibrarySource>* p) {
        return reinterpret_cast<QList<QmlLibrarySource*>*>(p->data)->size();
    }
    static QmlLibrarySource* at_source(QQmlListProperty<QmlLibrarySource>* p, qsizetype idx) {
        return reinterpret_cast<QList<QmlLibrarySource*>*>(p->data)->at(idx);
    }
    static void clear_source(QQmlListProperty<QmlLibrarySource>* p);
    static void replace_source(QQmlListProperty<QmlLibrarySource>* p,
            qsizetype idx,
            QmlLibrarySource* v);
    static void removeLast_source(QQmlListProperty<QmlLibrarySource>* p);

    QList<QmlLibrarySource*> m_sources;
    parented_ptr<QmlSidebarModelProxy> m_model;
};

} // namespace qml
} // namespace mixxx
