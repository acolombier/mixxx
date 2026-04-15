#include "controllers/rendering/controllerrenderingengine.h"
#include <qthread.h>

#include <QGuiApplication>
#include <QOffscreenSurface>
#include <QOpenGLContext>
#include <QOpenGLFramebufferObject>
#include <QOpenGLFunctions>
#include <QQmlEngine>
#include <QQuickGraphicsDevice>
#include <QQuickRenderControl>
#include <QQuickRenderTarget>
#include <QQuickWindow>
#include <QThread>
#include <QTimer>
#include <QtEndian>
#include <memory>

#include "controllers/controller.h"
#include "controllers/controllerenginethreadcontrol.h"
#include "controllers/scripting/legacy/controllerscriptenginelegacy.h"
#include "moc_controllerrenderingengine.cpp"
#include "util/cmdlineargs.h"
#include "util/logger.h"
#include "util/thread_affinity.h"
#include "util/timer.h"

// Used in the renderFrame method to properly abort the rendering and terminate the engine.
#define VERIFY_OR_ABORT(cond, msg) \
    VERIFY_OR_DEBUG_ASSERT(cond) {     \
        kLogger.warning() << msg;      \
        return;                        \
    }

namespace {
const mixxx::Logger kLogger("ControllerRenderingEngine");
} // anonymous namespace

using Clock = std::chrono::steady_clock;

// static const QEvent::Type INIT = QEvent::Type(QEvent::User + 1);
static const QEvent::Type RENDER = QEvent::Type(QEvent::User + 2);
static const QEvent::Type CLEANUP = QEvent::Type(QEvent::User + 4);
static const QEvent::Type STOP = QEvent::Type(QEvent::User + 5);

QuickRenderer::QuickRenderer(LegacyControllerMapping::ScreenInfo screenInfo)
    : m_context(nullptr),
      m_surface(nullptr),
      m_window(nullptr),
      m_quickWindow(nullptr),
      m_renderControl(nullptr),
      m_textureId(0),
      m_fboId(0),
      m_screenInfo(screenInfo),
          m_GLDataFormat(GL_RGBA),
          m_GLDataType(GL_UNSIGNED_BYTE)
{
    switch (m_screenInfo.pixelFormat) {
    case QImage::Format_RGB16:
        m_GLDataFormat = GL_RGB;
#ifndef QT_OPENGL_ES_2
        if (m_screenInfo.reversedColor) {
            m_GLDataType = GL_UNSIGNED_SHORT_5_6_5_REV;
        } else {
#endif
            m_GLDataType = GL_UNSIGNED_SHORT_5_6_5;
#ifndef QT_OPENGL_ES_2
        }
#endif
        break;
    case QImage::Format_RGB888:
        if (m_screenInfo.reversedColor) {
#ifdef QT_OPENGL_ES_2
            m_isValid = false;
            kLogger.critical() << "Reversed RGB8 format is not supported in OpenGL ES";
#else
            m_GLDataFormat = GL_BGR;
#endif
        } else {
            m_GLDataFormat = GL_RGB;
        }
        m_GLDataType = GL_UNSIGNED_BYTE;
        break;
    case QImage::Format_RGBA8888:
        if (m_screenInfo.reversedColor) {
#ifdef __EMSCRIPTEN__
            m_isValid = false;
            kLogger.critical() << "Reversed RGBA format is not supported in Emscripten/WebAssembly";
#elif !defined(QT_OPENGL_ES_2)
            m_GLDataFormat = GL_BGRA;
#endif
        } else {
            m_GLDataFormat = GL_RGBA;
        }
        m_GLDataType = GL_UNSIGNED_BYTE;
        break;
    default:
        m_isValid = false;
    }
    if (m_isValid){


#ifdef QT_OPENGL_ES_2
    // OpenGL ES doesn't support extended format and type when reading pixel and
    // only support GL_RGBA/GL_UNSIGNED_BYTE On this platform, we fallback to Qt
    // for the pixel transformation, using QImage conversion capabilities
    m_frame = QImage(m_screenInfo.size, QImage::Format_RGBA8888);
#else
    m_frame = QImage(m_screenInfo.size, m_screenInfo.pixelFormat);
#endif
    }
}

// void QuickRenderer::requestInit()
// {
//     QCoreApplication::postEvent(this, new QEvent(INIT));
// }

void QuickRenderer::requestRender()
{
    QCoreApplication::postEvent(this, new QEvent(RENDER));
}

void QuickRenderer::requestCleanup()
{
    QCoreApplication::postEvent(this, new QEvent(CLEANUP));
}

void QuickRenderer::requestStop()
{
    QCoreApplication::postEvent(this, new QEvent(STOP));
}

bool QuickRenderer::event(QEvent *e)
{
    QMutexLocker lock(&m_mutex);
    if (!m_isValid){
        return true;
    }

    switch (int(e->type())) {
    // case INIT:
    //     init();
    //     return true;
    case RENDER:
        render(&lock);
        return true;
    case CLEANUP:
        cleanup();
        return true;
    case STOP:
        cleanupRhi();
        return true;
    default:
        return QObject::event(e);
    }
}

void QuickRenderer::init()
{
    m_context->makeCurrent(m_surface);

    m_quickWindow->setGraphicsDevice(QQuickGraphicsDevice::fromOpenGLContext(m_context));

    m_renderControl->initialize();
}

void QuickRenderer::cleanup()
{
    m_context->makeCurrent(m_surface);

    m_renderControl->invalidate();

    if (m_fboId){
        m_context->functions()->glDeleteFramebuffers(1, &m_fboId);  
    }

    m_quickWindow->setGraphicsDevice({});
    m_quickWindow->setRenderTarget({});

    m_context->doneCurrent();

    m_cond.wakeOne();
}

void QuickRenderer::cleanupRhi()
{
    m_isValid = false;
    m_context->moveToThread(QCoreApplication::instance()->thread());

    m_cond.wakeOne();
}

void QuickRenderer::ensureTexture(){
    if (m_fboId){
        return;
    }
    qreal dpr = m_quickWindow->devicePixelRatio();
    QSize textureSize = m_quickWindow->size() * dpr;
    QOpenGLFunctions *f = m_context->functions();
    f->glGenFramebuffers(1, &m_fboId);
    f->glBindFramebuffer(GL_FRAMEBUFFER, m_fboId);
    f->glGenTextures(1, &m_textureId);
    f->glBindTexture(GL_TEXTURE_2D, m_textureId);
    f->glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    f->glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    f->glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, textureSize.width(), textureSize.height(), 0,
                GL_RGBA,
                GL_UNSIGNED_BYTE,

 nullptr);
 f->glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, m_textureId, 0);
    m_quickWindow->setRenderTarget(QQuickRenderTarget::fromOpenGLTexture(m_textureId, m_GLDataFormat, textureSize));
}

void QuickRenderer::render(QMutexLocker<QMutex> *lock) {
    if (!m_context->makeCurrent(m_surface)) {
        qWarning("Failed to make context current on render thread");
        m_isValid = false;
        cleanup();
        cleanupRhi();
        m_cond.wakeOne();
        lock->unlock();
        return;
    }

    ensureTexture();

    m_renderControl->beginFrame();
    // Synchronization and rendering happens here on the render thread.
    m_renderControl->sync();

    // The gui thread can now continue.
    m_cond.wakeOne();
    lock->unlock();

    // Meanwhile on this thread continue with the actual rendering (into the FBO first).
    
    m_context->functions()->glBindFramebuffer(GL_FRAMEBUFFER, m_fboId);  
    GLenum glError;
    // Flush any remaining GL errors.
    while ((glError = m_context->functions()->glGetError()) != GL_NO_ERROR) {
        kLogger.debug() << "Retrieved a previously unhandled GL error: " << glError;
    }
#ifndef QT_OPENGL_ES_2
    m_context->functions()->glFlush();
    glError = m_context->functions()->glGetError();
    VERIFY_OR_ABORT(glError == GL_NO_ERROR, "GLError after glFlush: " << glError);
    if (static_cast<std::endian>(m_screenInfo.endian) != std::endian::native) {
        m_context->functions()->glPixelStorei(GL_PACK_SWAP_BYTES, GL_TRUE);
    }
    glError = m_context->functions()->glGetError();
    VERIFY_OR_ABORT(glError == GL_NO_ERROR, "GLError after glPixelStorei: " << glError);
#endif

    QDateTime timestamp = QDateTime::currentDateTime();
    m_renderControl->render();
    m_renderControl->endFrame();

    // Flush any remaining GL errors.
    while ((glError = m_context->functions()->glGetError()) != GL_NO_ERROR) {
        kLogger.debug() << "Retrieved a previously unhandled GL error: " << glError;
    }
    {
        ScopedTimer t(QStringLiteral("ControllerRenderingEngine::renderFrame::glReadPixels"));
        m_context->functions()->glReadPixels(0,
                0,
                m_screenInfo.size.width(),
                m_screenInfo.size.height(),
#ifndef QT_OPENGL_ES_2
                m_GLDataFormat,
                m_GLDataType,
#else
                GL_RGBA,
                GL_UNSIGNED_BYTE,
#endif
                m_frame.bits());
    }
    glError = m_context->functions()->glGetError();
    VERIFY_OR_ABORT(glError == GL_NO_ERROR, "GLError after glReadPixels: " << glError);
    m_context->functions()->glBindFramebuffer(GL_FRAMEBUFFER, 0);   


    m_context->doneCurrent();

#ifdef QT_OPENGL_ES_2
    m_frame.convertTo(m_screenInfo.pixelFormat);

    // OpenGL ES doesn't support extended reverse format (suffixed with _REV) so
    // we use QImage function for this
    if (static_cast<std::endian>(m_screenInfo.endian) != std::endian::native) {
        m_frame.rgbSwap();
    }

    // OpenGL ES doesn't support explicit endianness (GL_PACK_SWAP_BYTES) se we
    // use Qt helper function to convert the pixel buffer. Only 16 and 32 bit
    // pixel format are supported currently.
    switch (static_cast<std::endian>(m_screenInfo.endian)) {
    case std::endian::big:
        switch (m_screenInfo.pixelFormat) {
        case QImage::Format_RGB16:
            qToBigEndian<quint16>(m_frame.bits(), m_frame.sizeInBytes() / 2, m_frame.bits());
            break;
        case QImage::Format_RGBA8888:
            qToBigEndian<quint32>(m_frame.bits(), m_frame.sizeInBytes() / 4, m_frame.bits());
            break;
        default:
            kLogger.critical()
                    << "Screen endianness mismatches native endianness, but OpenGL "
                       "ES does not let us specify a reverse pixel store order. "
                       "This will likely lead to invalid colors.";
        }
        break;
    case std::endian::little:
        switch (m_screenInfo.pixelFormat) {
        case QImage::Format_RGB16:
            qToLittleEndian<quint16>(m_frame.bits(), m_frame.sizeInBytes(), m_frame.bits());
            break;
        case QImage::Format_RGBA8888:
            qToLittleEndian<quint32>(m_frame.bits(), m_frame.sizeInBytes(), m_frame.bits());
            break;
        default:
            kLogger.critical()
                    << "Screen endianness mismatches native endianness, but OpenGL "
                       "ES does not let us specify a reverse pixel store order. "
                       "This will likely lead to invalid colors.";
        }
        break;
    }
#endif

#if QT_VERSION >= QT_VERSION_CHECK(6, 9, 0)
    m_frame.flip(Qt::Vertical);
#else
    m_frame.mirror(false, true);
#endif

    emit frameRendered(m_screenInfo, m_frame.copy(), timestamp);
}

ControllerRenderingEngine::ControllerRenderingEngine(
        const LegacyControllerMapping::ScreenInfo& screen,
        gsl::not_null<ControllerEngineThreadControl*> engineThreadControl)
        : QObject(),
          m_quickRenderer(std::make_unique<QuickRenderer>(screen)),
          m_pEngineThreadControl(engineThreadControl) {
    DEBUG_ASSERT_MAIN_THREAD_AFFINITY();

    if (!m_quickRenderer->isValid()) {
        DEBUG_ASSERT(!"Unsupported format");
        return;
    }
    QSurfaceFormat format;
    // FIXME multi sampling appears to be unsupported when using offscreen
    // rendering on Wayland QPA:
    //   warning [CtrlScreen_rightdeck] QWaylandGLContext::makeCurrent:
    //   eglError: 0x3009, this: 0x7ffd9c001770 warning [CtrlScreen_rightdeck]
    //   QRhiGles2: Failed to make context current. Expect bad things to happen.
    //   warning [CtrlScreen_rightdeck] Failed to create RHI (backend 2)
    if (QGuiApplication::platformName() != QStringLiteral("wayland")) {
        format.setSamples(screen.msaa);
    }
    format.setDepthBufferSize(16);
    format.setStencilBufferSize(8);

    m_context = std::make_unique<QOpenGLContext>();
    m_context->setFormat(format);
    VERIFY_OR_DEBUG_ASSERT(m_context->create()) {
        kLogger.warning() << "Unable to initialize controller screen rendering. Giving up";
        return;
    }
    connect(m_context.get(),
            &QOpenGLContext::aboutToBeDestroyed,
            this,
            &ControllerRenderingEngine::finish);

    m_offscreenSurface = std::make_unique<QOffscreenSurface>();
    m_offscreenSurface->setFormat(m_context->format());
    m_offscreenSurface->create();

    // offscreen surface needs to be created from application main thread.
    VERIFY_OR_DEBUG_ASSERT(m_offscreenSurface->isValid()) {
        kLogger.warning() << "Unable to create the OffscreenSurface for controller "
                             "screen rendering. Giving up";
        m_offscreenSurface.reset();
        return;
    }

    m_renderControl = std::make_unique<QQuickRenderControl>(this);
    m_renderControl->setSamples(format.samples());

    m_quickWindow = std::make_unique<QQuickWindow>(m_renderControl.get());
    m_quickWindow->setGeometry(0, 0, screen.size.width(), screen.size.height());

    m_quickRenderer->setContext(m_context.get());

    // These live on the gui thread. Just give access to them on the render thread.
    m_quickRenderer->setSurface(m_offscreenSurface.get());
    m_quickRenderer->setQuickWindow(m_quickWindow.get());
    m_quickRenderer->setRenderControl(m_renderControl.get());

    connect(this, &ControllerRenderingEngine::finalizeSetup, this, [this](){        
        m_pQuickRendererThread = std::make_unique<QThread>();
        m_pQuickRendererThread->setObjectName("ControllerScreenRenderer");

        // Notify the render control that some scenegraph internals have to live on
        // m_quickRenderThread.
        // TODO does this need to happen after setting up the incubator?
        m_renderControl->prepareThread(m_pQuickRendererThread.get());
        m_quickRenderer->init();

        // The QOpenGLContext and the QObject representing the rendering logic on
        // the render thread must live on that thread.
        m_context->moveToThread(m_pQuickRendererThread.get());
        m_quickRenderer->moveToThread(m_pQuickRendererThread.get());

        // these at first sight weird-looking connections facilitate thread-safe communication.
        connect(m_pQuickRendererThread.get(),
                &QThread::finished,
                this,
                &ControllerRenderingEngine::finish);
        connect(m_pQuickRendererThread.get(),
                &QThread::started,
                this,
                [this](){
                    m_startedCond.wakeOne();;
                });

        m_pQuickRendererThread->start(QThread::NormalPriority);
    });
}

void ControllerRenderingEngineDeleter::operator()(ControllerRenderingEngine* pEngine) const {
    pEngine->deleteLater();
}

ControllerRenderingEngine::~ControllerRenderingEngine() {
    DEBUG_ASSERT_THIS_QOBJECT_THREAD_AFFINITY();

    stop();

    m_renderControl.reset();
    m_quickWindow.reset();
    m_context.reset();
}

void ControllerRenderingEngine::start() {
    VERIFY_OR_DEBUG_ASSERT(!thread()->isFinished() && !thread()->isInterruptionRequested()) {
        kLogger.critical() << "Render thread has or is about to terminate. Cannot "
                              "start this render anymore.";
        return;
    }
    QCoreApplication::postEvent(this, new QEvent(QEvent::UpdateRequest));
}
bool ControllerRenderingEngine::isRunning() const {
    return m_pQuickRendererThread && m_pQuickRendererThread->isRunning();
}

void ControllerRenderingEngine::setup(QQmlEngine* qmlEngine) {
    DEBUG_ASSERT_THIS_QOBJECT_THREAD_ANTI_AFFINITY();
    QMutexLocker lock(&m_mutex);
    m_engine = qmlEngine;
    emit finalizeSetup();    
    m_startedCond.wait(&m_mutex);
}

void ControllerRenderingEngine::finish() {
    DEBUG_ASSERT_THIS_QOBJECT_THREAD_AFFINITY();
    emit stopping();
}

void ControllerRenderingEngine::renderFrame() {    
    ScopedTimer t(QStringLiteral("ControllerRenderingEngine::renderFrame"));
    if (!m_quickRenderer->isValid()) {
        DEBUG_ASSERT(!"Trying to render frame on an invalid engine");
        return;
    }

    m_nextFrameStart = Clock::now();

    if (m_pEngineThreadControl) {
        if (!m_pEngineThreadControl->pause()) {
            kLogger.debug() << "Couldn't pause the QML engine thread. Rescheduling frame rendering";
            QCoreApplication::postEvent(this, new QEvent(QEvent::UpdateRequest));
            return;
        }
    }
    
    m_engine->setIncubationController(m_quickWindow->incubationController());

    // Polishing happens on the gui thread.
    m_renderControl->polishItems();

    if (m_pEngineThreadControl) {
        m_pEngineThreadControl->resume();
    }

    // Sync happens on the render thread with the gui thread (this one) blocked.
    QMutexLocker lock(m_quickRenderer->mutex());
    m_quickRenderer->requestRender();
    // Wait until sync is complete.
    m_quickRenderer->cond()->wait(m_quickRenderer->mutex());
    // Rendering happens on the render thread without blocking the gui (main)
    // thread. This is good because the blocking swap (waiting for vsync)
    // happens on the render thread, not blocking other work.
}

bool ControllerRenderingEngine::stop() {
    if (!isRunning()){
        return true;
    }
    m_quickRenderer->mutex()->lock();

    m_quickRenderer->requestCleanup();
    m_quickRenderer->cond()->wait(m_quickRenderer->mutex());

    m_quickRenderer->requestStop();
    m_quickRenderer->cond()->wait(m_quickRenderer->mutex());

    m_quickRenderer->mutex()->unlock();
    m_pQuickRendererThread->quit();
    return m_pQuickRendererThread->wait();
}

void ControllerRenderingEngine::sendFrameData(Controller* controller, const QByteArray& frame) {
    DEBUG_ASSERT_THIS_QOBJECT_THREAD_ANTI_AFFINITY();
    ScopedTimer t(QStringLiteral("ControllerRenderingEngine::send"));
    if (!frame.isEmpty()) {
        VERIFY_OR_ABORT(controller->sendBytes(frame), "Unable to send frame to device");
    }

    if (CmdlineArgs::Instance()
                    .getControllerDebug()) {
        auto endOfFrameCycle = Clock::now();
        kLogger.debug()
                << "Frame took "
                << std::chrono::duration_cast<std::chrono::milliseconds>(
                           endOfFrameCycle - m_nextFrameStart)
                           .count()
                << "milliseconds and frame has" << frame.size() << "bytes";
    }

    m_nextFrameStart += std::chrono::microseconds(1000000 / m_quickRenderer->screen().target_fps);

    auto durationToWaitBeforeFrame =
            std::chrono::duration_cast<std::chrono::milliseconds>(
                    m_nextFrameStart - Clock::now());

    if (durationToWaitBeforeFrame > std::chrono::milliseconds(0)) {
        if (CmdlineArgs::Instance()
                        .getControllerDebug()) {
            kLogger.debug() << "Waiting for "
                            << durationToWaitBeforeFrame.count()
                            << "milliseconds before rendering next frame";
        }
        QTimer::singleShot(durationToWaitBeforeFrame,
                Qt::PreciseTimer,
                this,
                &ControllerRenderingEngine::renderFrame);
    } else {
        QCoreApplication::postEvent(this, new QEvent(QEvent::UpdateRequest));
    }
}

bool ControllerRenderingEngine::event(QEvent* event) {
    // In case there is a request for update (e.g using QWindow::requestUpdate),
    // we emit the signal to request rendering using the engine.
    if (event->type() == QEvent::UpdateRequest) {
        renderFrame();
        return true;
    }

    return QObject::event(event);
}
