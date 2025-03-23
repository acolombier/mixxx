#pragma once

#include <QByteArray>
#include <QJsonArray>
#include <QJsonObject>
#include <QQuickItem>
#include <QVariantMap>
#include <QtAlgorithms>
#include <chrono>

// #include "hidlearner.h"
// #include "modifier.h"

namespace mixxx {
namespace qml {

class QmlControllerElement : public QQuickItem {
    Q_OBJECT
    Q_PROPERTY(QList<QmlControllerElement*> children READ children)
    Q_PROPERTY(Type type MEMBER m_type NOTIFY typeChanged)
    // Q_PROPERTY(QVariantList modifiers READ getModifiers WRITE setModifiers
    //                 NOTIFY modifiersChanged)
    Q_PROPERTY(QList<uint> values READ getValues
                    NOTIFY valuesChanged)
    QML_NAMED_ELEMENT(ControllerElement)

  public:
    enum class Type {
        Button,
        Knob,
        Encoder,
        Fader,
        Zone,
        Controller,
    };
    Q_ENUM(Type)

    QmlControllerElement(QQuickItem* parent = nullptr);
    ~QmlControllerElement();

    // const QVariantMap& getProperties() const {
    //     return m_properties;
    // }
    const QList<uint>& getValues() const {
        return m_values;
    }
    // void setProperties(QVariantMap properties) {
    //     m_properties = properties;
    //     emit propertiesChanged();
    // }
    Q_INVOKABLE QJsonObject seed();
    Q_INVOKABLE void learn();
    // Q_INVOKABLE void setProperty(QString key, QVariant value) {
    //     m_properties[key] = value;
    //     emit propertiesChanged();
    // }

    QList<QmlControllerElement*> children() {
        return findChildren<QmlControllerElement*>(QString(), Qt::FindDirectChildrenOnly);
    }
    Q_INVOKABLE QVariantMap properties() const;
    Q_INVOKABLE void setParent(QmlControllerElement* newParent) {
        qDebug() << parent() << newParent->children().contains(this);
        QQuickItem::setParent(newParent);
        setParentItem(newParent);
        qDebug() << newParent->children().contains(this);
    }

    // void clearModifiers() {
    //     qDeleteAll(m_modifiers.begin(), m_modifiers.end());
    //     m_modifiers.clear();
    //     emit modifiersChanged();
    // }
    // void addModifier(uchar reportId, uchar offset, uint mask){
    //     m_modifiers.push_back(new Modifier(reportId, offset, mask));
    //     m_values.push_back(0);
    //     emit modifiersChanged();
    // }
    // QVariantList getModifiers() const {
    //     QVariantList modifiers;

    //     for(const auto& modifier: m_modifiers) {
    //         modifiers.push_back(QVariantMap{
    //             {"reportId", modifier->getReportId()},
    //             {"byteOffset", modifier->getByteOffset()},
    //             {"valueCount", modifier->valueCount()},
    //             {"mask", static_cast<int>(modifier->getMask())},
    //         });
    //     }

    //     return modifiers;
    // }
    // void setModifiers(QVariantList modifiers) {
    //     qDeleteAll(m_modifiers.begin(), m_modifiers.end());
    //     m_modifiers.clear();
    //     m_values.clear();
    //     for(const auto& modifier: modifiers) {
    //         auto map = modifier.toMap();
    //         m_modifiers.push_back(new
    //         Modifier(map.value("reportId").toUInt(),
    //         map.value("byteOffset").toUInt(), map.value("mask").toUInt()));
    //     }
    //     m_values.resize(m_modifiers.size(), 0);
    //     emit modifiersChanged();
    // }

  signals:
    // void propertiesChanged();
    void typeChanged();
    void valuesChanged();
    // void modifiersChanged();

  public slots:
    void slotReceivePacket(const QByteArray& data,
            std::chrono::time_point<std::chrono::system_clock>);

  private:
    void save(QJsonArray* data);

    // QList<Modifier*> m_modifiers;
    // QVariantMap m_properties;
    // QList<QmlControllerElement*> m_children;
    Type m_type;
    QList<uint> m_values;
};

} // namespace qml
} // namespace mixxx
