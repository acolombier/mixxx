#include "controllers/rendering/controllerrenderingengine.h"

#include <QEvent>
#include <QLabel>
#include <QOffscreenSurface>
#include <QOpenGLBuffer>
#include <QOpenGLContext>
#include <QOpenGLFramebufferObject>
#include <QOpenGLFunctions>
#include <QOpenGLShaderProgram>
#include <QOpenGLVertexArrayObject>
#include <QQmlComponent>
#include <QQmlEngine>
#include <QQuickGraphicsDevice>
#include <QQuickItem>
#include <QQuickRenderControl>
#include <QQuickRenderTarget>
#include <QQuickWindow>
#include <QScreen>

#include "controllers/controller.h"
#include "controllers/scripting/legacy/controllerscriptenginelegacy.h"
#include "controllers/scripting/legacy/controllerscriptinterfacelegacy.h"
#include "qml/qmlwaveformoverview.h"

ControllerRenderingEngine::ControllerRenderingEngine(Controller* controller,
        LegacyControllerMapping::QMLFileInfo qml,
        const RuntimeLoggingCategory& logger,
        uint8_t screenId)
        : QObject(),
          m_screenId(screenId),
          m_renderingInfo(qml) {
    m_pThread = std::make_unique<QThread>();
    m_pThread->setObjectName("ControllerScreenRenderer");

    if (!m_fileWatcher.addPath(qml.file.absoluteFilePath())) {
        qCWarning(logger) << "Failed to watch render file" << qml.file.absoluteFilePath();
    }

    for (auto path : qml.libraries) {
        // TODO make recursive?
        QDir libDirectory(path.absoluteFilePath());
        QFileInfoList fileEntries(libDirectory.entryInfoList(QStringList{"*.qml"}));
        QStringList files;
        for (auto entry : fileEntries) {
            files << entry.absoluteFilePath();
        }
        files << path.absoluteFilePath();

        QStringList failed(m_fileWatcher.addPaths(files));
        if (!failed.isEmpty()) {
            qCWarning(logger) << "Failed to watch render files" << failed
                              << "in library path" << path.absoluteFilePath();
        }
    }

    moveToThread(m_pThread.get());

    connect(&m_fileWatcher,
            &QFileSystemWatcher::fileChanged,
            this,
            &ControllerRenderingEngine::reload);

    connect(m_pThread.get(), &QThread::started, this, &ControllerRenderingEngine::start);

    m_pThread->start(QThread::NormalPriority);
}

void ControllerRenderingEngine::reload() {
    m_fbo.reset();

    m_renderControl.reset();
    m_qmlComponent.reset();
    m_quickWindow.reset();
    m_qmlEngine.reset();

    m_offscreenSurface.reset();

    m_context.reset();

    start();
}

void ControllerRenderingEngine::start() {
    QSurfaceFormat format;
    // Qt Quick may need a depth and stencil buffer. Always make sure these are available.
    format.setDepthBufferSize(16);
    format.setStencilBufferSize(8);

    m_context = std::make_unique<QOpenGLContext>();
    m_context->setFormat(format);
    VERIFY_OR_DEBUG_ASSERT(m_context->create()) {
        qWarning() << "Unable to intiliaze controller screen rendering. Giving up";
        cleanup();
        return;
    }

    m_offscreenSurface = std::make_unique<QOffscreenSurface>();
    m_offscreenSurface->setFormat(m_context->format());
    m_offscreenSurface->create();

    m_renderControl = std::make_unique<QQuickRenderControl>(this);
    m_quickWindow = std::make_unique<QQuickWindow>(m_renderControl.get());

    m_qmlEngine = std::make_shared<QQmlEngine>();
    if (!m_qmlEngine->incubationController())
        m_qmlEngine->setIncubationController(m_quickWindow->incubationController());

    // No memory leak here, the QQmlEngine takes ownership of the provider
    // QQuickAsyncImageProvider* pImageProvider = std::make_unique<AsyncImageProvider>(
    //         m_pCoreServices->getTrackCollectionManager());
    // m_pAppEngine->addImageProvider(AsyncImageProvider::kProviderName, pImageProvider);

    m_qmlEngine->addImportPath(QStringLiteral(":/mixxx.org/imports"));

    for (const auto& path : m_renderingInfo.libraries) {
        m_qmlEngine->addImportPath(path.absoluteFilePath());
    }

    switch (m_renderingInfo.transformFunctionType) {
    case ControllerRenderingTransformFunctionType::JAVASCRIPT:
        m_pTransformFunction =
                std::make_unique<ControllerRenderingJSTransformFunction>(
                        m_renderingInfo.transformFunctionPayload);
        break;
    }

    VERIFY_OR_DEBUG_ASSERT(!m_pTransformFunction || m_pTransformFunction->prepare(this)) {
        qDebug() << "the transformation function isn't ready to be used.";
        cleanup();
        return;
    }

    if (!load(m_renderingInfo.file.absoluteFilePath())) {
        qWarning() << "Unable to load the QML file";
        cleanup();
        return;
    }

    if (!m_context->makeCurrent(m_offscreenSurface.get())) {
        qWarning() << "Unable to start the GL context";
        cleanup();
        return;
    }

    m_fbo = std::make_shared<QOpenGLFramebufferObject>(
            m_renderingInfo.size, QOpenGLFramebufferObject::CombinedDepthStencil);

    m_quickWindow->setGraphicsDevice(QQuickGraphicsDevice::fromOpenGLContext(m_context.get()));

    if (!m_renderControl->initialize())
        qWarning("Failed to initialize redirected Qt Quick rendering");

    m_quickWindow->setRenderTarget(QQuickRenderTarget::fromOpenGLTexture(m_fbo->texture(),
            m_renderingInfo.size));

    renderNext();
}

void ControllerRenderingEngine::cleanup() {
    m_fbo.reset();

    m_renderControl.reset();
    m_qmlComponent.reset();
    m_quickWindow.reset();
    m_qmlEngine.reset();

    m_offscreenSurface.reset();

    m_context.reset();

    if (m_pThread) {
        m_pThread->quit();
    }
}

bool ControllerRenderingEngine::load(const QString& qmlFile) {
    if (m_qmlComponent != nullptr)
        m_qmlComponent.reset();
    m_qmlComponent = std::make_unique<QQmlComponent>(
            m_qmlEngine.get(), QUrl(qmlFile), QQmlComponent::PreferSynchronous);

    if (m_qmlComponent->isError()) {
        const QList<QQmlError> errorList = m_qmlComponent->errors();
        for (const QQmlError& error : errorList)
            qWarning() << error.url() << error.line() << error;
        return false;
    }

    QObject* pRootObject = m_qmlComponent->createWithInitialProperties(
            QVariantMap{{"screenId", m_screenId}});
    if (m_qmlComponent->isError()) {
        const QList<QQmlError> errorList = m_qmlComponent->errors();
        for (const QQmlError& error : errorList)
            qWarning() << error.url() << error.line() << error;
        return false;
    }

    m_rootItem = std::unique_ptr<QQuickItem>(qobject_cast<QQuickItem*>(pRootObject));
    if (!m_rootItem) {
        qWarning("run: Not a QQuickItem");
        delete pRootObject;
        return false;
    }

    // The root item is ready. Associate it with the window.
    m_rootItem->setParentItem(m_quickWindow->contentItem());

    m_rootItem->setWidth(m_renderingInfo.size.width());
    m_rootItem->setHeight(m_renderingInfo.size.height());

    m_quickWindow->setGeometry(0, 0, m_renderingInfo.size.width(), m_renderingInfo.size.height());

    return true;
}

void ControllerRenderingEngine::renderNext() {
    auto durationToWaitBeforeFrame = (m_nextFrameStart - mixxx::Time::elapsed());
    auto usecToWaitBeforeFrame = durationToWaitBeforeFrame.toIntegerMicros();

    if (usecToWaitBeforeFrame > 0) {
        qDebug() << "Waiting for "
                 << durationToWaitBeforeFrame.formatMillisWithUnit()
                 << " before render";
        QThread::usleep(usecToWaitBeforeFrame);
    }

    DEBUG_ASSERT(m_context->makeCurrent(m_offscreenSurface.get()));
    DEBUG_ASSERT(m_context->isValid());

    m_nextFrameStart = mixxx::Time::elapsed();
    m_renderControl->polishItems();

    m_renderControl->beginFrame();
    DEBUG_ASSERT(m_renderControl->sync());
    m_renderControl->render();
    m_renderControl->endFrame();

    m_context->functions()->glFlush();

    // TODO if debug
    emit debugScreenRendered(m_fbo->toImage());

    VERIFY_OR_DEBUG_ASSERT(!m_pTransformFunction ||
            m_pTransformFunction->transform(this, m_screenBuffer, m_screenId)) {
        qWarning() << "Unable to transform the screen rendering";
        cleanup();
        return;
    }

    auto endOfRender = mixxx::Time::elapsed();

    emit frameRendered(m_screenBuffer);

    qDebug() << "Fame took "
             << (endOfRender - m_nextFrameStart).formatMillisWithUnit()
             << " and buffer has" << m_screenBuffer.size() << "bytes.";

    m_nextFrameStart += mixxx::Duration::fromMillis(1000 / m_renderingInfo.target_fps);

    m_context->doneCurrent();

    if (!m_pThread->isInterruptionRequested()) {
        QEvent* updateRequest = new QEvent(QEvent::UpdateRequest);
        QCoreApplication::postEvent(this, updateRequest);
    } else {
        cleanup();
    }
}

bool ControllerRenderingEngine::event(QEvent* event) {
    if (event->type() == QEvent::UpdateRequest) {
        renderNext();
        return true;
    }

    return QObject::event(event);
}
