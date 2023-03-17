#include "controllers/scripting/legacy/controllerscreenrendering.h"

#include <QEvent>
#include <QOffscreenSurface>
#include <QOpenGLBuffer>
#include <QOpenGLContext>
#include <QOpenGLFramebufferObject>
#include <QOpenGLFunctions>
#include <QOpenGLShaderProgram>
#include <QOpenGLVertexArrayObject>
#include <QQmlComponent>
#include <QQmlEngine>
#include <QQuickItem>
#include <QQuickRenderControl>
#include <QQuickWindow>
#include <QScreen>
#include <QLabel>
#include <QQuickRenderTarget>
#include <QQuickGraphicsDevice>

#include "qml/qmlwaveformoverview.h"

#include "controllers/scripting/legacy/controllerscriptenginelegacy.h"
#include "controllers/scripting/legacy/controllerscriptinterfacelegacy.h"

ControllerScreenRendering::ControllerScreenRendering(Controller* controller, LegacyControllerMapping::QMLFileInfo qml, const RuntimeLoggingCategory& logger, uint8_t screenId)
        : ControllerScriptEngineBase(controller, logger), m_pTimer(nullptr), m_screenId(screenId), m_context(nullptr), m_offscreenSurface(nullptr), m_renderControl(nullptr), m_quickWindow(nullptr), m_renderingInfo(qml), m_qmlEngine(nullptr), m_qmlComponent(nullptr), m_rootItem(nullptr), m_fbo(nullptr), m_pDebugWindow(nullptr), m_pScrintInterface(nullptr), m_size(320, 240) {

    m_pThread = new QThread;
    m_pThread->setObjectName("ControllerScreenRenderer");

    moveToThread(m_pThread);

    connect(m_pThread, &QThread::started, this, &ControllerScreenRendering::start);
    connect(m_pThread, &QThread::finished, this, &ControllerScreenRendering::cleanup);

    m_pThread->start(QThread::LowPriority);
    // start();
}

ControllerScreenRendering::~ControllerScreenRendering() {
    m_pThread->requestInterruption();
    VERIFY_OR_DEBUG_ASSERT(m_pThread->wait(1000)){
        qCritical() << "Unable to terminate thread gracefully. Killing it now.";
        m_pThread->terminate();
        VERIFY_OR_DEBUG_ASSERT(m_pThread->wait()){
            qCritical() << "Unable to kill thread. What the hell is going on?";
        }
    }
    // if (m_pDebugWindow){
    //   m_pDebugWindow->hide();
    //   m_pDebugWindow->deleteLater();
    // }
    m_pThread->deleteLater();
}

void ControllerScreenRendering::start() {
    QSurfaceFormat format;
    // Qt Quick may need a depth and stencil buffer. Always make sure these are available.
    format.setDepthBufferSize(16);
    format.setStencilBufferSize(8);


    m_context = new QOpenGLContext;
    m_context->setFormat(format);
    RELEASE_ASSERT(m_context->create());

    m_offscreenSurface = new QOffscreenSurface;
    m_offscreenSurface->setFormat(m_context->format());
    m_offscreenSurface->create();

    m_renderControl = new QQuickRenderControl(this);
    m_quickWindow = new QQuickWindow(m_renderControl);

    m_qmlEngine = new QQmlEngine;
    if (!m_qmlEngine->incubationController())
        m_qmlEngine->setIncubationController(m_quickWindow->incubationController());

    // No memory leak here, the QQmlEngine takes ownership of the provider
    // QQuickAsyncImageProvider* pImageProvider = new AsyncImageProvider(
    //         m_pCoreServices->getTrackCollectionManager());
    // m_pAppEngine->addImageProvider(AsyncImageProvider::kProviderName, pImageProvider);   

    m_pScrintInterface = new ControllerScriptInterfaceLegacy(this, m_logger);
    QJSValue qmlGlobalObject = m_qmlEngine->globalObject();
    qmlGlobalObject.setProperty(
            "engine", m_qmlEngine->newQObject(m_pScrintInterface));

    m_qmlEngine->addImportPath(QStringLiteral(":/mixxx.org/imports"));
    // m_qmlEngine->addImportPath("/home/antoine/dev/mixxx/");

    for (const auto& path : m_renderingInfo.libraries) {
        m_qmlEngine->addImportPath(path.absoluteFilePath());
    }
    
    if (!load(m_renderingInfo.file.absoluteFilePath(), m_size)){
        qCritical() << "Unable to load the QML file";
        return;
    }

    // Debug
    // m_pDebugWindow = new QLabel;
    // m_pDebugWindow->resize(m_size);
    // m_pDebugWindow->show();

    if (!m_context->makeCurrent(m_offscreenSurface))
        return;

    createFbo();

    // Start the renderer
    m_pTimer = new QTimer(this);
    m_pTimer->callOnTimeout(this, &ControllerScreenRendering::renderNext);
    m_pTimer->start(1000 / m_renderingInfo.target_fps);
}

void ControllerScreenRendering::cleanup() {
    destroyFbo();

    m_pTimer->stop();
    delete m_pTimer;

    delete m_pScrintInterface;
    m_context->makeCurrent(m_offscreenSurface);
    delete m_renderControl;
    delete m_qmlComponent;
    delete m_quickWindow;
    m_qmlEngine->deleteLater();
    delete m_fbo;

    m_context->doneCurrent();

    delete m_offscreenSurface;
    delete m_context;
}

void ControllerScreenRendering::createFbo() {
    m_fbo = new QOpenGLFramebufferObject(m_size * 1.0, QOpenGLFramebufferObject::CombinedDepthStencil);
    // m_quickWindow->setRenderTarget(QQuickRenderTarget::fromOpenGLRenderBuffer(m_fbo->handle(), m_size * 1.0));

    m_quickWindow->setGraphicsDevice(QQuickGraphicsDevice::fromOpenGLContext(m_context));

    if (!m_renderControl->initialize())
        qWarning("Failed to initialize redirected Qt Quick rendering");

    m_quickWindow->setRenderTarget(QQuickRenderTarget::fromOpenGLTexture(m_fbo->texture(),
                                                                        m_size * 1.0));
}

void ControllerScreenRendering::destroyFbo() {
    delete m_fbo;
    m_fbo = nullptr;
}

bool ControllerScreenRendering::load(const QString& qmlFile, const QSize& size) {
    if (m_qmlComponent != nullptr)
        delete m_qmlComponent;
    m_qmlComponent = new QQmlComponent(m_qmlEngine, QUrl(qmlFile), QQmlComponent::PreferSynchronous);

    if (m_qmlComponent->isError()) {
        const QList<QQmlError> errorList = m_qmlComponent->errors();
        for (const QQmlError& error : errorList)
            qWarning() << error.url() << error.line() << error;
        return false;
    }

    QObject* rootObject = m_qmlComponent->create();
    if (m_qmlComponent->isError()) {
        const QList<QQmlError> errorList = m_qmlComponent->errors();
        for (const QQmlError& error : errorList)
            qWarning() << error.url() << error.line() << error;
        return false;
    }

    m_rootItem = qobject_cast<QQuickItem*>(rootObject);
    if (!m_rootItem) {
        qWarning("run: Not a QQuickItem");
        delete rootObject;
        return false;
    }

    // The root item is ready. Associate it with the window.
    m_rootItem->setParentItem(m_quickWindow->contentItem());

    m_rootItem->setWidth(size.width());
    m_rootItem->setHeight(size.height());

    m_rootItem->setProperty("screenId", m_screenId);

    m_quickWindow->setGeometry(0, 0, size.width(), size.height());

    return true;
}

void ControllerScreenRendering::renderNext() {
    RELEASE_ASSERT(m_context->isValid());

    m_renderControl->polishItems();

    m_renderControl->beginFrame();
    RELEASE_ASSERT(m_renderControl->sync());
    m_renderControl->render();
    m_renderControl->endFrame();

    m_context->functions()->glFlush();

    const QImage frame = m_fbo->toImage();
    emit frameRendered(frame);

    RELEASE_ASSERT(!frame.isNull());

    if (m_pDebugWindow){
      m_pDebugWindow->setPixmap(QPixmap::fromImage(frame));
    }

    if (m_pThread->isInterruptionRequested()) {
    // //     //Schedule the next update
    //     QEvent* updateRequest = new QEvent(QEvent::UpdateRequest);
    //     QCoreApplication::postEvent(this, updateRequest);
    // } else {
        m_pThread->quit();
    }
}

bool ControllerScreenRendering::event(QEvent* event) {
    if (event->type() == QEvent::UpdateRequest) {
        renderNext();
        return true;
    }

    return QObject::event(event);
}
