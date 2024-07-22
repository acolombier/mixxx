#include "qml/qmlmixxxcontroller.h"

#include <QSGNode>
#include <QSGSimpleRectNode>

#include "moc_qmlmixxxcontroller.cpp"

namespace mixxx {
namespace qml {

QmlMixxxController::QmlMixxxController(QQuickItem* parent)
        : QQuickItem(parent) {
    qDebug() << "QmlMixxxController created";
    // setFlag(ItemHasContents, true);
}

QSGNode* QmlMixxxController::updatePaintNode(QSGNode* oldnode, UpdatePaintNodeData* data) {
    // QSGSimpleRectNode *n = static_cast<QSGSimpleRectNode *>(oldnode);
    // if (!n) {
    //     n = new QSGSimpleRectNode();
    //     n->setColor(Qt::red);
    // }
    // n->setRect(boundingRect());
    // qDebug() << "QmlMixxxController" << n->childCount() << data;
    // return n;
    QSGNode* node = QQuickItem::updatePaintNode(oldnode, data);
    return node;
}

} // namespace qml
} // namespace mixxx
