#ifndef CUSTOMITEM_H
#define CUSTOMITEM_H

#include <QQuickItem>

class CustomItem : public QQuickItem {
    Q_OBJECT

    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)

    QML_ELEMENT

  public:
    explicit CustomItem(QQuickItem* parent = nullptr);

    QColor color() const {
        return m_color;
    }

  public slots:
    void setColor(QColor color);

  signals:
    void colorChanged(QColor color);

  protected:
    QSGNode* updatePaintNode(QSGNode*, UpdatePaintNodeData*) override;
    void geometryChange(const QRectF& newGeometry, const QRectF& oldGeometry) override;

  private:
    bool m_geometryChanged = true;
    QColor m_color;
    bool m_colorChanged = true;
};

#endif // CUSTOMITEM_H
