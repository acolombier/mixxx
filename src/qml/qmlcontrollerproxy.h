#pragma once
#include <QObject>
#include <QtQml>
#include <memory>


#include "util/parented_ptr.h"

class ControllerManager;

namespace mixxx {
namespace qml {

class QmlApplication;

class QmlControllerProxy : public QObject {
    Q_OBJECT
    
    QML_NAMED_ELEMENT(ControllerManager)
    QML_SINGLETON

  public:
    explicit QmlControllerProxy(std::shared_ptr<ControllerManager> pControllerManager, QmlApplication* parent = nullptr);

    static QmlControllerProxy* create(QQmlEngine* pQmlEngine, QJSEngine* pJsEngine);
    static inline QmlControllerProxy* s_pInstance = nullptr;

  private:
    static inline QJSEngine* s_pJsEngine = nullptr;
    static inline QQmlApplicationEngine* s_pQmlEngine = nullptr;

    std::shared_ptr<ControllerManager> m_pControllerManager;
    
};

} // namespace qml
} // namespace mixxx
