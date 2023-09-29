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
#include "moc_controllerrenderingengine.cpp"
#include "qml/qmlwaveformoverview.h"

ControllerRenderingEngine::ControllerRenderingEngine(
        const LegacyControllerMapping::ScreenInfo& info)
        : QObject(),
          m_screenInfo(info),
          m_imageFormat(QImage::Format_ARGB32),
          m_GLDataType(GL_RGBA) {
    switch (m_screenInfo.pixelFormat) {
    case GL_UNSIGNED_SHORT_5_6_5:
        m_imageFormat = QImage::Format_RGB16;
        m_GLDataType = GL_RGB;
        m_screenInfo.pixelFormat = m_screenInfo.reversedColor
                ? GL_UNSIGNED_SHORT_5_6_5_REV
                : GL_UNSIGNED_SHORT_5_6_5;
        break;
    case GL_UNSIGNED_INT_8_8_8_8:
        m_imageFormat = QImage::Format_ARGB32;
        m_GLDataType = m_screenInfo.reversedColor ? GL_RGBA : GL_BGRA;
        break;
    default:
        DEBUG_ASSERT(!"Unsupported format");
    }
    // m_pThread = std::make_unique<QThread>();
    // m_pThread->setObjectName("ControllerScreenRenderer");

    // if (!m_fileWatcher.addPath(qml.file.absoluteFilePath())) {
    //     qCWarning(logger) << "Failed to watch render file" << qml.file.absoluteFilePath();
    // }

    // for (auto path : qml.libraries) {
    //     // TODO make recursive?
    //     QDir libDirectory(path.absoluteFilePath());
    //     QFileInfoList fileEntries(libDirectory.entryInfoList(QStringList{"*.qml"}));
    //     QStringList files;
    //     for (auto entry : fileEntries) {
    //         files << entry.absoluteFilePath();
    //     }
    //     files << path.absoluteFilePath();

    //     QStringList failed(m_fileWatcher.addPaths(files));
    //     if (!failed.isEmpty()) {
    //         qCWarning(logger) << "Failed to watch render files" << failed
    //                           << "in library path" << path.absoluteFilePath();
    //     }
    // }

    // moveToThread(m_pThread.get());
    moveToThread(QCoreApplication::instance()->thread());

    // connect(&m_fileWatcher,
    //         &QFileSystemWatcher::fileChanged,
    //         this,
    //         &ControllerRenderingEngine::reload);

    // connect(m_pThread.get(), &QThread::started, this, &ControllerRenderingEngine::start);
    // connect(m_pThread.get(), &QThread::finished, this, &ControllerRenderingEngine::cleanup);
    connect(this,
            &ControllerRenderingEngine::setupRequested,
            this,
            &ControllerRenderingEngine::setup,
            Qt::BlockingQueuedConnection);

    // m_pThread->start(QThread::NormalPriority);
}

// TODO
// - We need to make sure the OpemGL-related resource are tore down by the
// object's thread and not the COntrolerEngine destructor
ControllerRenderingEngine::~ControllerRenderingEngine() {
    VERIFY_OR_DEBUG_ASSERT(QThread::currentThread() == this->thread()) {
        qWarning() << "Cannot delete rendering screen from another thead. Skipping cleanup.";
        return;
    };

    m_context->makeCurrent(m_offscreenSurface.get());
    m_renderControl->deleteLater();
    m_offscreenSurface->deleteLater();
    m_quickWindow->deleteLater();

    // Free the engine and FBO
    m_fbo.reset();

    m_context->doneCurrent();
    qDebug() << "About to destroy";
}

void ControllerRenderingEngine::start() {
    if (m_pFrameClock) {
        return;
    }

    m_pFrameClock = std::make_unique<QTimer>(this);
    connect(m_pFrameClock.get(), &QTimer::timeout, this, &ControllerRenderingEngine::renderFrame);
    m_pFrameClock->start(1000 / m_screenInfo.target_fps);
    m_pFrameClock->moveToThread(thread());
}

void ControllerRenderingEngine::requestSetup(std::shared_ptr<QQmlEngine> qmlEngine) {
    VERIFY_OR_DEBUG_ASSERT(QThread::currentThread() != thread()) {
        qWarning() << "Unable to setup OpenGL rendering context from the same "
                      "thread as the render object";
        return;
    }
    emit setupRequested(qmlEngine);
}

void ControllerRenderingEngine::setup(std::shared_ptr<QQmlEngine> qmlEngine) {
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

    connect(
            m_quickWindow.get(), &QQuickWindow::sceneGraphInitialized, this, [=]() {
                qDebug() << "QQuickWindow::sceneGraphInitialized";
                // if (!m_context->makeCurrent(m_offscreenSurface.get())) {
                //     qWarning() << "Unable to start the GL context";
                //     cleanup();
                //     return;
                // }

                // m_fbo = std::make_shared<QOpenGLFramebufferObject>(
                //         m_screenInfo.size, QOpenGLFramebufferObject::CombinedDepthStencil);

                // m_quickWindow->setGraphicsDevice(QQuickGraphicsDevice::fromOpenGLContext(m_context.get()));

                // VERIFY_OR_DEBUG_ASSERT(m_renderControl->initialize()){
                //     qWarning() << "Failed to initialize redirected Qt Quick rendering";
                // };

                // m_quickWindow->setRenderTarget(QQuickRenderTarget::fromOpenGLTexture(m_fbo->texture(),
                //         m_screenInfo.size));
            });

    connect(
            m_quickWindow.get(), &QQuickWindow::sceneGraphInvalidated, this, []() {
                qDebug() << "QQuickWindow::sceneGraphInvalidated";
            });

    connect(
            m_renderControl.get(), &QQuickRenderControl::renderRequested, this, []() {
                qDebug() << "QQuickRenderControl::renderRequested";
            });

    // connect(
    // 	m_renderControl.get(), &QQuickRenderControl::sceneChanged,
    // 	this,             [](){
    //         qDebug() << "QQuickRenderControl::sceneChanged";
    // This means we need to polish+sync the rendercontrol
    //     }
    // );

    // m_qmlEngine = std::make_shared<QQmlEngine>();
    if (!qmlEngine->incubationController())
        qmlEngine->setIncubationController(m_quickWindow->incubationController());

    m_quickWindow->setGeometry(0, 0, m_screenInfo.size.width(), m_screenInfo.size.height());

    // No memory leak here, the QQmlEngine takes ownership of the provider
    // QQuickAsyncImageProvider* pImageProvider = std::make_unique<AsyncImageProvider>(
    //         m_pCoreServices->getTrackCollectionManager());
    // m_qmlEngine->addImageProvider(AsyncImageProvider::kProviderName, pImageProvider);

    // switch (m_screenInfo.transformFunctionType) {
    // case ControllerRenderingTransformFunctionType::JAVASCRIPT:
    //     m_pTransformFunction =
    //             std::make_unique<ControllerRenderingJSTransformFunction>(
    //                     m_screenInfo.transformFunctionPayload);
    //     break;
    // }

    // VERIFY_OR_DEBUG_ASSERT(!m_pTransformFunction || m_pTransformFunction->prepare(this)) {
    //     qDebug() << "the transformation function isn't ready to be used.";
    //     cleanup();
    //     return;
    // }

    // quickWindow->setGeometry(0, 0, m_screenInfo.size.width(), m_screenInfo.size.height()); ?

    // if (!load(m_screenInfo.file.absoluteFilePath())) {
    //     qWarning() << "Unable to load the QML file";
    //     // cleanup();
    //     return;
    // }

    // connect(m_context.get(), &QOpenGLContext::aboutToBeDestroyed, [=](){
    //     qWarning() << "GLCTX LOST!!!!!!!!";
    //     // m_pThread->quit();
    // });

    // connect(QCoreApplication::instance(), &QCoreApplication::aboutToQuit, [=](){
    //     qWarning() << "QT CLOSING!!!!!!!!";
    //     // cleanup();
    //     // m_pThread->quit();
    // });

    // QCoreApplication::postEvent(this, new QEvent(QEvent::UpdateRequest));
}

void ControllerRenderingEngine::cleanup() {
    disconnect(this);
    m_fbo.reset();
    if (m_pFrameClock) {
        m_pFrameClock->deleteLater();
        m_pFrameClock = nullptr;
    }

    // if (m_pThread) {
    //     m_pThread->quit();
    // }
}

// bool ControllerRenderingEngine::load(const QString& qmlFile) {
//     if (m_qmlComponent != nullptr)
//         m_qmlComponent.reset();
//     m_qmlComponent = std::make_unique<QQmlComponent>(
//             m_qmlEngine.get(), QUrl(qmlFile), QQmlComponent::PreferSynchronous);

//     if (m_qmlComponent->isError()) {
//         const QList<QQmlError> errorList = m_qmlComponent->errors();
//         for (const QQmlError& error : errorList)
//             qWarning() << error.url() << error.line() << error;
//         return false;
//     }

//     QObject* pRootObject = m_qmlComponent->createWithInitialProperties(
//             QVariantMap{{"screenId", m_screenId}});
//     if (m_qmlComponent->isError()) {
//         const QList<QQmlError> errorList = m_qmlComponent->errors();
//         for (const QQmlError& error : errorList)
//             qWarning() << error.url() << error.line() << error;
//         return false;
//     }

//     m_rootItem = std::unique_ptr<QQuickItem>(qobject_cast<QQuickItem*>(pRootObject));
//     if (!m_rootItem) {
//         qWarning("run: Not a QQuickItem");
//         delete pRootObject;
//         return false;
//     }

//     // The root item is ready. Associate it with the window.
//     m_rootItem->setParentItem(m_quickWindow->contentItem());

//     m_rootItem->setWidth(m_screenInfo.size.width());
//     m_rootItem->setHeight(m_screenInfo.size.height());

//     m_quickWindow->setGeometry(0, 0, m_screenInfo.size.width(), m_screenInfo.size.height());

//     return true;
// }

void ControllerRenderingEngine::renderFrame() {
    // if (m_pThread->isInterruptionRequested()) {
    //     qDebug() << "Interruption is requested.";
    //     m_pThread->quit();
    //     return;
    // }
    VERIFY_OR_DEBUG_ASSERT(m_offscreenSurface->isValid()){
        qDebug() << "OffscrenSurface isn't valid anymore.";
        cleanup();
        return;
    };
    VERIFY_OR_DEBUG_ASSERT(m_context->isValid()){
        qDebug() << "GLContext isn't valid anymore.";
        cleanup();
        return;
    };
    VERIFY_OR_DEBUG_ASSERT(m_context->makeCurrent(m_offscreenSurface.get())){
        qDebug() << "Couldn't set the OffscrenSurface has GLContext.";
        cleanup();
        return;
    };

    if (!m_fbo) {
        m_fbo = std::make_unique<QOpenGLFramebufferObject>(
                m_screenInfo.size, QOpenGLFramebufferObject::CombinedDepthStencil);

        m_quickWindow->setGraphicsDevice(QQuickGraphicsDevice::fromOpenGLContext(m_context.get()));

        VERIFY_OR_DEBUG_ASSERT(m_renderControl->initialize()) {
            qWarning() << "Failed to initialize redirected Qt Quick rendering";
        };

        m_quickWindow->setRenderTarget(QQuickRenderTarget::fromOpenGLTexture(m_fbo->texture(),
                m_screenInfo.size));

        m_quickWindow->setGeometry(0, 0, m_screenInfo.size.width(), m_screenInfo.size.height());
    }

    m_nextFrameStart = mixxx::Time::elapsed();
    m_renderControl->polishItems();

    m_renderControl->beginFrame();
    VERIFY_OR_DEBUG_ASSERT(m_renderControl->sync()) {
        qDebug() << "Couldn't sync the render control.";
    };
    QImage fboImage(m_screenInfo.size, m_imageFormat);

    VERIFY_OR_DEBUG_ASSERT(m_fbo->bind()){
        qDebug() << "Couldn't bind the FBO.";
    }
    GLenum glError;
    m_context->functions()->glFlush();
    glError = m_context->functions()->glGetError();
    VERIFY_OR_DEBUG_ASSERT(glError == GL_NO_ERROR) {
        qDebug() << "GLError: " << glError;
        cleanup();
    }
    if (m_screenInfo.endian != std::endian::native) {
        m_context->functions()->glPixelStorei(GL_PACK_SWAP_BYTES, GL_TRUE);
    }
    glError = m_context->functions()->glGetError();
    VERIFY_OR_DEBUG_ASSERT(glError == GL_NO_ERROR){
        qDebug() << "GLError: " << glError;
        cleanup();
    }

    m_renderControl->render();
    m_renderControl->endFrame();

    while (m_context->functions()->glGetError());
    m_context->functions()->glReadPixels(0,
            0,
            m_screenInfo.size.width(),
            m_screenInfo.size.height(),
            m_GLDataType,
            m_screenInfo.pixelFormat,
            fboImage.bits());
    glError = m_context->functions()->glGetError();
    VERIFY_OR_DEBUG_ASSERT(glError == GL_NO_ERROR){
        qDebug() << "GLError: " << glError;
        cleanup();
    }
    VERIFY_OR_DEBUG_ASSERT(m_fbo->release()){
        qDebug() << "Couldn't release the FBO.";
    }

    fboImage.mirror(false, true);

    // if (mDebug){
    //     QImage debugFboImage(fboImage);

    //     if constexpr (m_screenInfo.endian != std::endian::native){
    //         kPlatformEndian((const void*)frame.constBits(),
    //         frame.sizeInBytes(), debugFboImage.bits())
    //     }
    //     // TODO Reverse - configurable
    //     // debugFboImage.rgbSwap();

    //     emit debugScreenRendered(debugFboImage.convertToFormat(QImage::Format_RGB32));
    // }

    // VERIFY_OR_DEBUG_ASSERT(!m_pTransformFunction ||
    //         m_pTransformFunction->transform(this, fboImage, m_screenBuffer, m_screenId)) {
    //     qWarning() << "Unable to transform the screen rendering";
    //     cleanup();
    //     return;
    // }

    auto endOfRender = mixxx::Time::elapsed();

    emit frameRendered(m_screenInfo, fboImage);

    qDebug() << "Fame took "
             << (endOfRender - m_nextFrameStart).formatMillisWithUnit()
             << " and frame has" << fboImage.sizeInBytes() << "bytes";

    m_nextFrameStart += mixxx::Duration::fromMillis(1000 / m_screenInfo.target_fps);

    m_context->doneCurrent();

    // auto durationToWaitBeforeFrame = (m_nextFrameStart - mixxx::Time::elapsed());
    // auto msecToWaitBeforeFrame = durationToWaitBeforeFrame.toIntegerMillis();

    // if (msecToWaitBeforeFrame > 0) {
    //     qDebug() << "Waiting for "
    //             << durationToWaitBeforeFrame.formatMillisWithUnit()
    //             << " before render";
    //     QTimer::singleShot(msecToWaitBeforeFrame, this, &ControllerRenderingEngine::renderNext);
    // } else {
    //     QCoreApplication::postEvent(this, new QEvent(QEvent::UpdateRequest));
    // }
}

bool ControllerRenderingEngine::stop() {
    // TODO implement
    return false;
}

bool ControllerRenderingEngine::event(QEvent* event) {
    // if (event->type() == QEvent::UpdateRequest) {
    //     renderNext();
    //     return true;
    // }

    return QObject::event(event);
}
