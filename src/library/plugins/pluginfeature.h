#pragma once

#include <QSharedPointer>

#include "library/baseexternallibraryfeature.h"
#include "library/treeitemmodel.h"

namespace mixxx {
namespace plugin {
class BrowseReply;
}
} // namespace mixxx

class PluginTreeModel;
class PluginClient;
class PluginTrack;
class WLibrary;
class PluginTableModel;
class PluginPlaylistModel;
class BaseTrackCache;
class WLibraryPluginView;

class PluginFeature : public BaseExternalLibraryFeature {
    Q_OBJECT
  public:
    PluginFeature(Library* pLibrary, UserSettingsPointer pConfig);
    virtual ~PluginFeature();

    QVariant title() override;

    void bindLibraryWidget(WLibrary* libraryWidget,
            KeyboardEventFilter* keyboard) override;
    void bindSidebarWidget(WLibrarySidebar* pSidebarWidget) override;

    TreeItemModel* sidebarModel() const override;

  public slots:
    void activate() override;
    void activateChild(const QModelIndex& index) override;
    void onRightClickChild(const QPoint& globalPos, const QModelIndex& index) override;
    void onLazyChildExpandation(const QModelIndex& index) override;
    void onTracksAdded(const QString&, int position, const std::shared_ptr<PluginTrack>& track);
    void onNodeAdded(const QString&, const mixxx::plugin::BrowseReply& node);

  private:
    std::shared_ptr<PluginClient> m_pClient;

    std::unique_ptr<PluginTreeModel> m_pSidebarModel;

    WLibraryPluginView* m_pluginView;

    // BrowseTableModel m_browseModel;
    std::unique_ptr<PluginTableModel> m_pPluginTrackModel;
    std::unique_ptr<PluginPlaylistModel> m_pPluginPlaylistModel;
    QSharedPointer<BaseTrackCache> m_pTrackSource;
};
