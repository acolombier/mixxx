#pragma once

#include "library/baseexternalplaylistmodel.h"

namespace mixxx {
namespace plugin {
class Tracklist;
}
} // namespace mixxx

class PluginClient;

class PluginPlaylistModel : public BaseExternalPlaylistModel {
    Q_OBJECT
  public:
    PluginPlaylistModel(QObject* parent,
            TrackCollectionManager* pTrackCollectionManager,
            QSharedPointer<BaseTrackCache> trackSource,
            std::shared_ptr<PluginClient> client);
    virtual bool isColumnHiddenByDefault(int column);
    QString getTrackLocation(const QModelIndex& index) const override;
    QUrl getTrackUrl(const QModelIndex& index) const override;

  public slots:
    void setTracklist(const mixxx::plugin::Tracklist& tracklist_id);

  private:
    std::shared_ptr<PluginClient> m_pClient;
};
