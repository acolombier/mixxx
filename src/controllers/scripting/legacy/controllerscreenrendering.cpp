#include "controllers/scripting/legacy/controllerscreenrendering.h"

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

ControllerScreenRendering::ControllerScreenRendering(Controller* controller,
        LegacyControllerMapping::QMLFileInfo qml,
        const RuntimeLoggingCategory& logger,
        uint8_t screenId)
        : ControllerScriptEngineBase(controller, logger),
          m_screenId(screenId),
          m_renderingInfo(qml),
          m_size(320, 240) {
    m_pThread = std::make_unique<QThread>();
    m_pThread->setObjectName("ControllerScreenRenderer");

    moveToThread(m_pThread.get());

    connect(m_pThread.get(), &QThread::started, this, &ControllerScreenRendering::start);
    connect(m_pThread.get(), &QThread::finished, this, &ControllerScreenRendering::cleanup);

    m_pThread->start(QThread::NormalPriority);
    // start();
}

ControllerScreenRendering::~ControllerScreenRendering() {
    m_pThread->requestInterruption();
    m_pThread->wait();
    // if (m_pDebugWindow){
    //   m_pDebugWindow->hide();
    //   m_pDebugWindow->deleteLater();
    // }
    m_pThread.reset();
}

void ControllerScreenRendering::start() {
    QSurfaceFormat format;
    // Qt Quick may need a depth and stencil buffer. Always make sure these are available.
    format.setDepthBufferSize(16);
    format.setStencilBufferSize(8);

    m_context = std::make_unique<QOpenGLContext>();
    m_context->setFormat(format);
    RELEASE_ASSERT(m_context->create());

    m_offscreenSurface = std::make_unique<QOffscreenSurface>();
    m_offscreenSurface->setFormat(m_context->format());
    m_offscreenSurface->create();

    m_renderControl = std::make_unique<QQuickRenderControl>(this);
    m_quickWindow = std::make_unique<QQuickWindow>(m_renderControl.get());

    m_qmlEngine = std::make_unique<QQmlEngine>();
    if (!m_qmlEngine->incubationController())
        m_qmlEngine->setIncubationController(m_quickWindow->incubationController());

    // No memory leak here, the QQmlEngine takes ownership of the provider
    // QQuickAsyncImageProvider* pImageProvider = std::make_unique<AsyncImageProvider>(
    //         m_pCoreServices->getTrackCollectionManager());
    // m_pAppEngine->addImageProvider(AsyncImageProvider::kProviderName, pImageProvider);

    m_pScrintInterface = std::make_unique<ControllerScriptInterfaceLegacy>(this, m_logger);
    QJSValue qmlGlobalObject = m_qmlEngine->globalObject();
    qmlGlobalObject.setProperty(
            "engine", m_qmlEngine->newQObject(m_pScrintInterface.get()));

    m_qmlEngine->addImportPath(QStringLiteral(":/mixxx.org/imports"));

    for (const auto& path : m_renderingInfo.libraries) {
        m_qmlEngine->addImportPath(path.absoluteFilePath());
    }

    m_transformFunction = m_qmlEngine->evaluate(QStringLiteral(
            // arg2 is the timestamp for ControllerScriptModuleEngine.
            // In ControllerScriptEngineLegacy it is the length of the array.
            "(function(input, screen_id) {"
            " data = new Array(320*240*2 + 20).fill(0); "
            " input = new Uint8Array(input); "
            " data[0] = 0x84; "
            " data[3] = 0x21; "
            " data[12] = 0x1; "
            " data[13] = 0x40; "
            " data[15] = 0xf0; "
            " data[320*240*2 + 16] = 0x40; "
            " data[2] = screen_id; "
            " for (var i = 0; i < 320 * 240; i ++){ "
            "     data[16 + 2 * i] = (input[i * 4] & 0xf8) | (input[i * 4 + 1] >> 5); "
            "     data[16 + 2 * i + 1] = (input[i * 4 + 1] << 3) & 0xe0 | (input[i * 4 + 2] >> 3); "
            " } "
            " return data; "
            "})"));
    RELEASE_ASSERT(m_transformFunction.isCallable());
    // m_transformFunction = m_qmlEngine->evaluate(QStringLiteral(
    //         // arg2 is the timestamp for ControllerScriptModuleEngine.
    //         // In ControllerScriptEngineLegacy it is the length of the array.
    //         "(function(input) {"
    //         "    const output = std::make_unique<Uint8Array>(153620);"
    //         "    const out = std::make_unique<DataView>(output);"
    //         "    out.setUint8(3, 0x21);"
    //         "    out.setUint8(12, 0x1);"
    //         "    out.setUint8(13, 0x40);"
    //         "    out.setUint8(15, 0xf0);"
    //         "    out.setUint8(320*240*2 + 16, 0x40);"
    //         "    out.setUint8(2, count);"
    //         "    for (var i = 0; i < 320 * 240; i ++){"
    //         "        out.setUint16(16 + 2 * i, (in.getUint8(i * 4) & 0xf8) <<
    //         8 | (in.getUint8(i * 4 + 1) & 0xfc) << 3 | (in.getUint8(i * 4 +
    //         2) >> 3));" "    }"
    //         "})"));

    if (!load(m_renderingInfo.file.absoluteFilePath(), m_size)) {
        qCritical() << "Unable to load the QML file";
        cleanup();
        return;
    }

    // Debug
    // m_pDebugWindow = std::make_unique<QLabel>;
    // m_pDebugWindow->resize(m_size);
    // m_pDebugWindow->show();

    if (!m_context->makeCurrent(m_offscreenSurface.get())) {
        qCritical() << "Unable to start the GL context";
        cleanup();
        return;
    }

    createFbo();

    // Start the renderer
    // m_pTimer = std::make_unique<QTimer>(this);
    // m_pTimer->callOnTimeout(this, &ControllerScreenRendering::renderNext);
    // m_pTimer->start(1000 / m_renderingInfo.target_fps);
    renderNext();
}

void ControllerScreenRendering::cleanup() {
    m_fbo.reset();

    // m_pTimer->stop();
    // m_pTimer.reset();

    m_pScrintInterface.reset();
    m_renderControl.reset();
    m_qmlComponent.reset();
    m_quickWindow.reset();
    m_qmlEngine.reset();

    m_offscreenSurface.reset();

    m_context.reset();

    m_pThread->quit();
}

void ControllerScreenRendering::createFbo() {
    m_fbo = std::make_unique<QOpenGLFramebufferObject>(
            m_size * 1.0, QOpenGLFramebufferObject::CombinedDepthStencil);
    // m_quickWindow->setRenderTarget(QQuickRenderTarget::fromOpenGLRenderBuffer(m_fbo->handle(),
    // m_size * 1.0));

    m_quickWindow->setGraphicsDevice(QQuickGraphicsDevice::fromOpenGLContext(m_context.get()));

    if (!m_renderControl->initialize())
        qWarning("Failed to initialize redirected Qt Quick rendering");

    m_quickWindow->setRenderTarget(QQuickRenderTarget::fromOpenGLTexture(m_fbo->texture(),
            m_size * 1.0));
}

bool ControllerScreenRendering::load(const QString& qmlFile, const QSize& size) {
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

    m_rootItem->setWidth(size.width());
    m_rootItem->setHeight(size.height());

    // m_rootItem->setProperty("screenId", m_screenId);

    m_quickWindow->setGeometry(0, 0, size.width(), size.height());

    return true;
}

void ControllerScreenRendering::renderNext() {
    auto durationToWaitBeforeFrame = (m_nextFrameStart - mixxx::Time::elapsed());
    auto usecToWaitBeforeFrame = durationToWaitBeforeFrame.toIntegerMicros();

    if (usecToWaitBeforeFrame > 0) {
        qDebug() << "Sleeping for "
                 << durationToWaitBeforeFrame.formatMillisWithUnit()
                 << " before render";
        QThread::usleep(usecToWaitBeforeFrame);
    }

    RELEASE_ASSERT(m_context->makeCurrent(m_offscreenSurface.get()));
    RELEASE_ASSERT(m_context->isValid());

    m_nextFrameStart = mixxx::Time::elapsed();
    m_renderControl->polishItems();

    m_renderControl->beginFrame();
    RELEASE_ASSERT(m_renderControl->sync());
    m_renderControl->render();
    m_renderControl->endFrame();

    m_context->functions()->glFlush();

    const QImage frame = m_fbo->toImage();
    RELEASE_ASSERT(!frame.isNull());

    auto startOfTransform = mixxx::Time::elapsed();

    // emit frameRendered(frame);

    QByteArray input((const char*)frame.constBits(), frame.sizeInBytes());
    QJSValue dataToSend = m_transformFunction.call(
            QJSValueList{m_qmlEngine->toScriptValue(input), m_screenId});

    if (dataToSend.isError()) {
        qWarning() << "Could not transform rendering buffer. Error:" << dataToSend.toString();
        cleanup();
        return;
    }

    QByteArray output;

    if (dataToSend.isArray()) {
        int length = dataToSend.property("length").toInt();
        for (int i = 0; i < length; i++) {
            int value = dataToSend.property(i).toInt();
            output.append(static_cast<char>(value));
        }
    }
    auto endOfTransform = mixxx::Time::elapsed();
    m_pController->sendBytes(output);
    auto endOfRender = mixxx::Time::elapsed();
    qDebug() << "Fame took "
             << (endOfRender - m_nextFrameStart).formatMillisWithUnit()
             << "(Render: "
             << (startOfTransform - m_nextFrameStart).formatMillisWithUnit()
             << "/ Transform: "
             << (endOfTransform - startOfTransform).formatMillisWithUnit()
             << ") and buffer has" << output.size() << "bytes. Had error?"
             << dataToSend.isError();

    m_nextFrameStart += mixxx::Duration::fromMillis(1000 / m_renderingInfo.target_fps);

    m_context->doneCurrent();

    if (m_pDebugWindow) {
        m_pDebugWindow->setPixmap(QPixmap::fromImage(frame));
    }

    if (!m_pThread->isInterruptionRequested()) {
        // Schedule the next update
        QEvent* updateRequest = new QEvent(QEvent::UpdateRequest);
        QCoreApplication::postEvent(this, updateRequest);
    } else {
        cleanup();
    }
}

bool ControllerScreenRendering::event(QEvent* event) {
    if (event->type() == QEvent::UpdateRequest) {
        renderNext();
        return true;
    }

    return QObject::event(event);
}
