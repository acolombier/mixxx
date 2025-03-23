#pragma once

#include <qobject.h>
#include <qquickitem.h>
#include <qvariant.h>

#include <QAbstractItemModel>
#include <QQmlListProperty>
#include <QQmlParserStatus>
#include <QtQml>

#include "library/columncache.h"
#include "library/libraryfeature.h"
#include "library/sidebarmodel.h"
#include "library/treeitem.h"
#include "qmlconfigproxy.h"
#include "qmllibraryproxy.h"
#include "util/parented_ptr.h"

namespace mixxx {
namespace qml {

class QmlTrackListColumn : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString label MEMBER m_label FINAL)
    Q_PROPERTY(int fillSpan MEMBER m_fillSpan FINAL)
    Q_PROPERTY(int columnIdx MEMBER m_columnIdx FINAL)
    Q_PROPERTY(double preferredWidth MEMBER m_preferredWidth FINAL)
    Q_PROPERTY(QQmlComponent* delegate MEMBER m_delegate FINAL)
    QML_NAMED_ELEMENT(TrackListColumn)
  public:
    enum class SQLColumns {
        Album = ColumnCache::COLUMN_LIBRARYTABLE_ALBUM,
        Artist = ColumnCache::COLUMN_LIBRARYTABLE_ARTIST,
        Title = ColumnCache::COLUMN_LIBRARYTABLE_TITLE,
        Year = ColumnCache::COLUMN_LIBRARYTABLE_YEAR,
        Bpm = ColumnCache::COLUMN_LIBRARYTABLE_BPM,
        Key = ColumnCache::COLUMN_LIBRARYTABLE_KEY,
        FileType = ColumnCache::COLUMN_LIBRARYTABLE_FILETYPE,
        Bitrate = ColumnCache::COLUMN_LIBRARYTABLE_BITRATE,
    };
    Q_ENUM(SQLColumns)
    explicit QmlTrackListColumn(QObject* parent = nullptr)
            : QObject(parent) {
    }
    const QString& label() const {
        return m_label;
    }
    int columnIdx() const {
        return m_columnIdx;
    }
    QQmlComponent* delegate() const {
        return m_delegate;
    }

  private:
    QString m_label;
    int m_fillSpan{0};
    int m_columnIdx{-1};
    double m_preferredWidth{-1};
    QQmlComponent* m_delegate;
};

class QmlLibrarySource : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString label MEMBER m_label)
    Q_PROPERTY(QString icon MEMBER m_icon)
    Q_PROPERTY(QQmlListProperty<QmlTrackListColumn> columns READ columnsQml)
    Q_CLASSINFO("DefaultProperty", "columns")
    QML_ANONYMOUS
  public:
    explicit QmlLibrarySource(QObject* parent = nullptr,
            const QList<QmlTrackListColumn*>& columns = {});
    virtual LibraryFeature* create() = 0;
    QQmlListProperty<QmlTrackListColumn> columnsQml() {
        return {this, &m_columns};
    }

    const QList<QmlTrackListColumn*>& columns() const {
        return m_columns;
    }

  protected:
    QString m_label;
    QString m_icon;
    QList<QmlTrackListColumn*> m_columns;
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
class QmlLibraryAllTrackSource : public QmlLibrarySource {
    Q_OBJECT
    QML_ANONYMOUS
  public:
    explicit QmlLibraryAllTrackSource(QObject* parent = nullptr,
            const QList<QmlTrackListColumn*>& columns = {});
    LibraryFeature* create() override {
        return nullptr;
    }
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
    Q_INVOKABLE void activate(const QModelIndex& index);
  signals:
    void trackModelRequested(QAbstractItemModel*);
};

class QmlLibrarySourceTree : public QQuickItem {
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)
    Q_PROPERTY(QQmlListProperty<QmlLibrarySource> sources READ sources)
    Q_PROPERTY(QQmlListProperty<QmlTrackListColumn> defaultColumns READ defaultColumns FINAL)
    Q_CLASSINFO("DefaultProperty", "sources")
    QML_NAMED_ELEMENT(LibrarySourceTree)

  public:
    Q_DISABLE_COPY_MOVE(QmlLibrarySourceTree)
    explicit QmlLibrarySourceTree(QQuickItem* parent = nullptr);
    ~QmlLibrarySourceTree() override;

    void componentComplete() override;

    QQmlListProperty<QmlTrackListColumn> defaultColumns() {
        return {this, &m_defaultColumns};
    }

    QQmlListProperty<QmlLibrarySource> sources();
    Q_INVOKABLE QmlSidebarModelProxy* sidebar() const {
        return m_model.get();
    };
    Q_INVOKABLE QmlLibraryTrackListModel* allTracks() const;

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
    QList<QmlTrackListColumn*> m_defaultColumns;
};

} // namespace qml
} // namespace mixxx
