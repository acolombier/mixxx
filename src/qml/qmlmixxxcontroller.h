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

class QmlRenderedArea : public QObject {
    Q_OBJECT
    QML_NAMED_ELEMENT(RenderedArea)

    Q_PROPERTY(int x MEMBER m_x);
    Q_PROPERTY(int y MEMBER m_y);
    Q_PROPERTY(int width MEMBER m_width);
    Q_PROPERTY(int height MEMBER m_height);

  public:
    explicit QmlRenderedArea(const ControllerRenderingEngine::UpdatedRect& rect,
            QObject* parent = nullptr)
            : QObject(parent),
              m_x(rect.x),
              m_y(rect.y),
              m_width(rect.width),
              m_height(rect.height) {
        // setProperty("x", m_x);
        // setProperty("y", m_y);
        // setProperty("width", m_width);
        // setProperty("height", m_height);
    }

  private:
    int m_x;
    int m_y;
    int m_width;
    int m_height;
};

} // namespace qml
} // namespace mixxx

Q_DECLARE_METATYPE(mixxx::qml::QmlRenderedArea);
