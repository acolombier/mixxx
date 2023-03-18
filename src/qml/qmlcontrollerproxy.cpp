#include "qml/qmlcontrollerproxy.h"

#include <QAbstractItemModel>

#include "controllers/controllermanager.h"
#include "qml/qmlapplication.h"

namespace mixxx {
namespace qml {

QmlControllerProxy::QmlControllerProxy(std::shared_ptr<ControllerManager> pControllerManager, QmlApplication* parent)
        : QObject(parent),
          m_pControllerManager(pControllerManager) {
    connect(m_pControllerManager.get(), &ControllerManager::mappingOpened, this, [=](std::shared_ptr<LegacyControllerMapping> mapping){
        auto pEngine = parent->appEngine();
        if (!pEngine.get()){
            qCritical() << "QML engine not ready";
            return;
        }
        for (const auto& qml: qAsConst(mapping->getQMLFiles())){
            for (const auto& path: qml.libraries){
                pEngine->addImportPath(path.absolutePath());
            }
            pEngine->load(qml.file.absolutePath());
        }
    });
}

// static
QmlControllerProxy* QmlControllerProxy::create(QQmlEngine* pQmlEngine, QJSEngine* pJsEngine) {
    // The implementation of this method is mostly taken from the code example
    // that shows the replacement for `qmlRegisterSingletonInstance()` when
    // using `QML_SINGLETON`.
    // https://doc.qt.io/qt-6/qqmlengine.html#QML_SINGLETON

    // The instance has to exist before it is used. We cannot replace it.
    DEBUG_ASSERT(s_pInstance);

    // The engine has to have the same thread affinity as the singleton.
    DEBUG_ASSERT(pJsEngine->thread() == s_pInstance->thread());

    // There can only be one engine accessing the singleton.
    if (s_pJsEngine) {
        DEBUG_ASSERT(pJsEngine == s_pJsEngine);
    } else {
        s_pJsEngine = pJsEngine;
    }

    if (s_pQmlEngine) {
        DEBUG_ASSERT(pQmlEngine == s_pQmlEngine);
    } else {
        s_pQmlEngine = dynamic_cast<QQmlApplicationEngine*>(pQmlEngine); //qobject_cast?

        connect(s_pInstance->m_pControllerManager.get(), &ControllerManager::mappingOpened, s_pInstance, [=](std::shared_ptr<LegacyControllerMapping> mapping){
            for (const auto& qml: qAsConst(mapping->getQMLFiles())){
                for (const auto& path: qml.libraries){
                    s_pQmlEngine->addImportPath(path.absolutePath());
                }
                s_pQmlEngine->load(qml.file.absolutePath());
            }
        });

        connect(s_pQmlEngine, &QQmlApplicationEngine::objectCreated, s_pInstance, [=](QObject *object, const QUrl &url){
            qDebug() << "object is" << object << "with URL" <<url;
        });
        // connect(s_pQmlEngine, &QQmlApplicationEngine::objectCreationFailed, s_pInstance, [=](QObject *object, const QUrl &url){
        //     qDebug() << "FAILED object with URL" <<url;
        // });
    }

    // Explicitly specify C++ ownership so that the engine doesn't delete
    // the instance.
    QJSEngine::setObjectOwnership(s_pInstance, QJSEngine::CppOwnership);
    return s_pInstance;
}

} // namespace qml
} // namespace mixxx
