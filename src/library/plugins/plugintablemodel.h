#pragma once

#include <QStandardItemModel>

#include "library/baseexternaltrackmodel.h"

class TrackCollectionManager;
class QMimeData;
class BaseTrackCache;
class PluginClient;

class PluginTableModel : public BaseExternalTrackModel {
    Q_OBJECT
  public:
    PluginTableModel(QObject* parent,
            TrackCollectionManager* pTrackCollectionManager,
            QSharedPointer<BaseTrackCache> trackSource,
            std::shared_ptr<PluginClient> client);
    virtual bool isColumnHiddenByDefault(int column);

  private:
    std::shared_ptr<PluginClient> m_pClient;
};
