#pragma once

#include <memory>

#include "backend/basenode.h"

namespace rendergraph {
class Engine; // fwd decl to avoid circular dependency
class TreeNode;
} // namespace rendergraph

class rendergraph::TreeNode {
  public:
    TreeNode(rendergraph::BaseNode* pBackendNode);
    virtual ~TreeNode();

    void appendChildNode(std::unique_ptr<TreeNode>&& pChild);

    // remove all child nodes. returns the list of child nodes
    // by returning the node in the list. the caller can keep
    // the pointer, thus transferring ownership. otherwise the
    // nodes will be destroyed
    std::unique_ptr<TreeNode> removeAllChildNodes();

    // remove a single child node for the list of child nodes.
    // the caller can keep the pointer, thus transferring ownership.
    // otherwise the node will be destroyed
    std::unique_ptr<TreeNode> removeChildNode(TreeNode* pChild);

    TreeNode* parent() const {
        return m_pParent;
    }
    TreeNode* firstChild() const {
        return m_pFirstChild.get();
    }
    TreeNode* lastChild() const {
        return m_pLastChild;
    }
    TreeNode* nextSibling() const {
        return m_pNextSibling.get();
    }
    TreeNode* previousSibling() const {
        return m_pPreviousSibling;
    }

    void setUsePreprocess(bool value);

    rendergraph::BaseNode* backendNode() {
        return m_pBackendNode;
    }

  private:
    void onAppendChildNode(TreeNode* pChild);
    void onRemoveAllChildNodes();
    void onRemoveChildNode(TreeNode* pChild);

    rendergraph::BaseNode* m_pBackendNode;
    TreeNode* m_pParent{};
    std::unique_ptr<TreeNode> m_pFirstChild;
    TreeNode* m_pLastChild{};
    std::unique_ptr<TreeNode> m_pNextSibling;
    TreeNode* m_pPreviousSibling{};
};
