#pragma once

#include <QHash>
#include <QModelIndex>

#include "library/treeitemmodel.h"

// This class represents a Plugin item within the Browse Feature
// The class is derived from TreeItemModel to support lazy model
// initialization.
class PluginClient;
class TreeItem;
class PluginFeature;

class PluginTreeModel : public TreeItemModel {
    Q_OBJECT
  public:
    PluginTreeModel(std::shared_ptr<PluginClient> client, PluginFeature* parent = 0);
    virtual ~PluginTreeModel();
    virtual bool hasChildren(const QModelIndex& parent = QModelIndex()) const override;

    // QVariant data(const QModelIndex &index, int role) const override;
    QModelIndex index(int row,
            int column,
            const QModelIndex& parent = QModelIndex()) const override;
    // QModelIndex parent(const QModelIndex &index) const override;

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;

  private:
    std::shared_ptr<PluginClient> m_pClient;
    QHash<QString, TreeItem*> m_pTreeItems;
};
