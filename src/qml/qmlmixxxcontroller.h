#pragma once

#include <QQuickItem>

#include "controllers/rendering/controllerrenderingengine.h"

namespace mixxx {
namespace qml {

class QmlMixxxController : public QQuickItem {
    Q_OBJECT
    QML_NAMED_ELEMENT(Controller)
    Q_PROPERTY(QJSValue transformFrame READ getTransform WRITE setTransform
                    NOTIFY transformChanged REQUIRED);

  public:
    explicit QmlMixxxController(QQuickItem* parent = nullptr);

    void setTransform(const QJSValue& value) {
        qDebug() << "setTransform" << value.isCallable();

        if (!value.isCallable()) {
            return;
        }
        m_transformFunc = value;
        emit transformChanged();
    }

    QJSValue getTransform() const {
        return m_transformFunc;
    }

  signals:
    void transformChanged();

  protected:
    QSGNode* updatePaintNode(QSGNode*, UpdatePaintNodeData*) override;

  private:
    QJSValue m_transformFunc;
};

} // namespace qml
} // namespace mixxx
