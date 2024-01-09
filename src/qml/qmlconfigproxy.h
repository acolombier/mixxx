#pragma once
#include <QColor>
#include <QObject>
#include <QVariantList>
#include <QtQml>

#include "preferences/usersettings.h"

namespace mixxx {
namespace qml {

class QmlConfigProxy : public QObject {
    Q_OBJECT
    QML_NAMED_ELEMENT(Config)
    QML_SINGLETON
  public:
    explicit QmlConfigProxy(
            UserSettingsPointer pConfig,
            QObject* parent = nullptr);

    Q_INVOKABLE QVariantList getHotcueColorPalette();
    Q_INVOKABLE QVariantList getTrackColorPalette();
    Q_INVOKABLE int getInt(QString group, QString item, int defaultValue = 0);
    Q_INVOKABLE bool getBool(QString group, QString item, bool defaultValue = false);
    Q_INVOKABLE double getDouble(QString group, QString item, double defaultValue = 0.0);
    Q_INVOKABLE QString getString(QString group, QString item, QString defaultValue = "");

    static QmlConfigProxy* create(QQmlEngine* pQmlEngine, QJSEngine* pJsEngine);
    static inline void registerUserSettings(UserSettingsPointer pConfig) {
        s_pUserSettings = std::move(pConfig);
    }

  private:
    static inline UserSettingsPointer s_pUserSettings = nullptr;

    const UserSettingsPointer m_pConfig;
};

} // namespace qml
} // namespace mixxx
