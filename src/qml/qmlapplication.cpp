#include "qmlapplication.h"

#include <QtQml/qqmlextensionplugin.h>

#include "control/controlsortfiltermodel.h"
#include "controllers/controllermanager.h"
#include "moc_qmlapplication.cpp"
#include "qml/asyncimageprovider.h"
#include "qml/qmlconfigproxy.h"
#include "qml/qmlcontrolproxy.h"
#include "qml/qmldlgpreferencesproxy.h"
#include "qml/qmleffectmanifestparametersmodel.h"
#include "qml/qmleffectslotproxy.h"
#include "qml/qmleffectsmanagerproxy.h"
#include "qml/qmllibraryproxy.h"
#include "qml/qmllibrarytracklistmodel.h"
#include "qml/qmlplayermanagerproxy.h"
#include "qml/qmlplayerproxy.h"
#include "qml/qmlvisibleeffectsmodel.h"
#include "qml/qmlwaveformoverview.h"
#include "soundio/soundmanager.h"
Q_IMPORT_QML_PLUGIN(MixxxPlugin)
Q_IMPORT_QML_PLUGIN(Mixxx_ControlsPlugin)

namespace {
const QString kMainQmlFileName = QStringLiteral("qml/main.qml");

// Converts a (capturing) lambda into a function pointer that can be passed to
// qmlRegisterSingletonType.
template<class F>
auto lambda_to_singleton_type_factory_ptr(F&& f) {
    static F fn = std::forward<F>(f);
    return [](QQmlEngine* pEngine, QJSEngine* pScriptEngine) -> QObject* {
        return fn(pEngine, pScriptEngine);
    };
}
} // namespace

namespace mixxx {
namespace qml {

QmlApplication::QmlApplication(
        QApplication* app,
        std::shared_ptr<CoreServices> pCoreServices)
        : m_pCoreServices(pCoreServices),
          m_mainFilePath(pCoreServices->getSettings()->getResourcePath() + kMainQmlFileName),
          m_pAppEngine(nullptr),
          m_fileWatcher({m_mainFilePath}) {
    m_pCoreServices->initialize(app);
    SoundDeviceStatus result = m_pCoreServices->getSoundManager()->setupDevices();
    if (result != SoundDeviceStatus::Ok) {
        const int reInt = static_cast<int>(result);
        qCritical() << "Error setting up sound devices:" << reInt;
        exit(reInt);
    }

    // FIXME: DlgPreferences has some initialization logic that must be executed
    // before the GUI is shown, at least for the effects system.
    std::shared_ptr<QDialog> pDlgPreferences = m_pCoreServices->makeDlgPreferences();
    // Without this, QApplication will quit when the last QWidget QWindow is
    // closed because it does not take into account the window created by
    // the QQmlApplicationEngine.
    pDlgPreferences->setAttribute(Qt::WA_QuitOnClose, false);

    loadQml(m_mainFilePath);

    pCoreServices->getControllerManager()->setUpDevices();

    connect(&m_fileWatcher,
            &QFileSystemWatcher::fileChanged,
            this,
            &QmlApplication::loadQml);
}

void QmlApplication::loadQml(const QString& path) {
    // QQmlApplicationEngine::load creates a new window but also leaves the old one,
    // so it is necessary to destroy the old QQmlApplicationEngine and create a new one.
    m_pAppEngine = std::make_unique<QQmlApplicationEngine>();

    const QFileInfo fileInfo(path);
    m_pAppEngine->addImportPath(QStringLiteral(":/mixxx.org/imports"));

    // No memory leak here, the QQmlEngine takes ownership of the provider
    QQuickAsyncImageProvider* pImageProvider = new AsyncImageProvider(
            m_pCoreServices->getTrackCollectionManager());
    m_pAppEngine->addImageProvider(AsyncImageProvider::kProviderName, pImageProvider);

    m_pAppEngine->load(path);
    if (m_pAppEngine->rootObjects().isEmpty()) {
        qCritical() << "Failed to load QML file" << path;
    }
}

} // namespace qml
} // namespace mixxx
