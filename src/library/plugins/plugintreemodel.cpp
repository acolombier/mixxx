
#include "library/plugins/plugintreemodel.h"

#include "library/plugins/pluginclient.h"
#include "library/plugins/pluginfeature.h"
#include "library/treeitem.h"
#include "moc_plugintreemodel.cpp"

PluginTreeModel::PluginTreeModel(std::shared_ptr<PluginClient> client, PluginFeature* parent)
        : TreeItemModel(parent), m_pClient(client) {
    setRootItem(TreeItem::newRoot(parent));
    // TODO connect received_event
    // TODO connect node_received

    connect(client.get(),
            &PluginClient::node_received,
            [this](const QString& node_id,
                    const mixxx::plugin::BrowseReply& node) {
                TreeItem* pParent;
                if (node_id.isEmpty()) {
                    pParent = getRootItem();
                } else {
                    pParent = m_pTreeItems.value(node_id, nullptr);
                    VERIFY_OR_DEBUG_ASSERT(pParent) {
                        qDebug() << "NO PARENT!! FOR" << node_id;
                        return;
                    }
                    qDebug() << "Adding node" << node_id << "to parent" << pParent->getData();
                }
                VERIFY_OR_DEBUG_ASSERT(pParent) {
                    qDebug() << "NO PARENT FOR" << node_id;
                    return;
                }

                int childIdx = 0;
                int childrenCount = pParent->children().size();
                for (auto& child : node.nodes()) {
                    QString nodeId = QString::fromStdString(child.id());
                    TreeItem* item = pParent->child(childIdx++);
                    if (!item){
                        qDebug() << "Adding child" << nodeId << "to parent" << node_id;
                        item = pParent->appendChild(
                            QString::fromStdString(child.label()),
                            QHash<QString, QVariant>({
                                    {"id", nodeId},
                                    {"type", child.type()},
                            })
                        );
                    } else {
                        qDebug() << "Update child" << nodeId << "to parent" << node_id;
                        item->setLabel(QString::fromStdString(child.label()));
                        item->setData(QHash<QString, QVariant>({
                                {"id", nodeId},
                                {"type", child.type()},
                        }));

                    }
                    m_pTreeItems.insert(nodeId, item);
                }
            });
}

PluginTreeModel::~PluginTreeModel() {
}

/* A tree model of the filesystem should be initialized lazy.
 * It will take the universe to iterate over all files over filesystem
 * hasChildren() returns true if a plugin has subplugins although
 * we do not know the precise number of subplugins.
 *
 * Note that BrowseFeature inserts plugin trees dynamically and rowCount()
 * is only called if necessary.
 */
bool PluginTreeModel::hasChildren(const QModelIndex& parent) const {
    qDebug() << "PluginTreeModel::hasChildren";
    TreeItem* parentItem;
    if (parent.isValid()) {
        parentItem = static_cast<TreeItem*>(parent.internalPointer());
    } else {
        parentItem = getRootItem();
    }
    qDebug() << "PluginTreeModel::hasChildren"<<parentItem->getData().toHash();
    auto nodeType = parentItem->getData().toHash().value("type", QVariant());
    return nodeType.isValid() && nodeType != mixxx::plugin::NodeType::LEAF;
}

QModelIndex PluginTreeModel::index(int row, int column, const QModelIndex& parent) const {
    if (!hasIndex(row, column, parent)) {
        return QModelIndex();
    }

    TreeItem *parentItem;
    if (parent.isValid()) {
        parentItem = static_cast<TreeItem*>(parent.internalPointer());
    } else {
        parentItem = getRootItem();
    }

    qDebug() << "PluginTreeModel::index parentItem" << parentItem->getData();

    TreeItem *childItem = parentItem->child(row);
    if (childItem) {
        qDebug() << "PluginTreeModel::index childItem" << childItem->getData();
        return createIndex(row, column, childItem);
    } else if(row == 0) {
        return createIndex(row, column, parentItem->appendChild("(Loading)", ""));
    } else {
        return QModelIndex();
    }

    // TreeItem* parentItem;
    // if (parent.isValid()) {
    //     parentItem = static_cast<TreeItem*>(parent.internalPointer());
    // } else {
    //     parentItem = getRootItem();
    // }
    // qDebug() << "PluginTreeModel::index"<<row<<column<<parentItem->getData();

    // TreeItem* childItem = parentItem->child(row);
    // qDebug() << "PluginTreeModel::index"<<childItem;
    // if (childItem) {
    //     return createIndex(row, column, childItem);
    // } else {
    //     return createIndex(row, column, parentItem->appendChild("(Loading)", ""));
    // }
}

// QModelIndex PluginTreeModel::parent(const QModelIndex &index) const {
//     qDebug() << "PluginTreeModel::parent";
//     return createIndex(0, 0, getRootItem());
// }

int PluginTreeModel::rowCount(const QModelIndex& parent) const {
    // qDebug() << "PluginTreeModel::rowCount";
    TreeItem* parentItem;
    if (parent.isValid()) {
        parentItem = static_cast<TreeItem*>(parent.internalPointer());
    } else {
        parentItem = getRootItem();
    }
    auto nodeType = parentItem->getData().toHash().value("type", QVariant());
    if (nodeType.isValid() ||
            (nodeType != mixxx::plugin::NodeType::LEAF &&
                    parentItem->children().isEmpty())) {
        return 1;
    }
    return parentItem->children().size();
}
