#include "controllers/rendering/controllerrenderingengine.h"

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

#include "controllers/controller.h"
#include "controllers/controllerenginethreadcontrol.h"
#include "controllers/scripting/legacy/controllerscriptenginelegacy.h"
#include "controllers/scripting/legacy/controllerscriptinterfacelegacy.h"
#include "moc_controllerrenderingengine.cpp"
#include "qml/qmlwaveformoverview.h"
#include "util/cmdlineargs.h"
#include "util/logger.h"
#include "util/thread_affinity.h"
#include "util/time.h"
#include "util/timer.h"

// Used in the renderFrame method to properly abort the rendering and terminate the engine.
#define VERIFY_OR_TERMINATE(cond, msg) \
    VERIFY_OR_DEBUG_ASSERT(cond) {     \
        kLogger.warning() << msg;      \
        m_pThread->quit();             \
        return;                        \
    }

namespace {
const mixxx::Logger kLogger("ControllerRenderingEngine");
} // anonymous namespace

using Clock = std::chrono::steady_clock;

ControllerRenderingEngine::ControllerRenderingEngine(
        const LegacyControllerMapping::ScreenInfo& info,
        gsl::not_null<ControllerEngineThreadControl*> engineThreadControl)
        : QObject(),
          m_screenInfo(info),
          m_GLDataFormat(GL_RGBA),
          m_GLDataType(GL_UNSIGNED_BYTE),
          m_isValid(true),
          m_pEngineThreadControl(engineThreadControl) {
    switch (m_screenInfo.pixelFormat) {
    case QImage::Format_RGB16:
        m_GLDataFormat = GL_RGB;
        if (m_screenInfo.reversedColor) {
#ifdef QT_OPENGL_ES_2
            m_isValid = false;
            kLogger.critical() << "Reversed RGB16 format is not supported in OpenGL ES";
#else
            m_GLDataType = GL_UNSIGNED_SHORT_5_6_5_REV;
#endif
        } else {
            m_GLDataType = GL_UNSIGNED_SHORT_5_6_5;
        }
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
#else
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

    if (!m_isValid) {
        DEBUG_ASSERT(!"Unsupported format");
        return;
    }

    mUpdatedRectMatrix.resize(info.size.width() * info.size.height());
    mPixelDiff.resize(info.size.width() * info.size.height());

    prepare();
}

void ControllerRenderingEngine::prepare() {
    m_pThread = std::make_unique<QThread>();
    m_pThread->setObjectName("ControllerScreenRenderer");

#if QT_VERSION >= QT_VERSION_CHECK(6, 7, 0)
    [[maybe_unused]] bool successful = moveToThread(m_pThread.get());
    DEBUG_ASSERT(successful);
#else
    moveToThread(m_pThread.get());
#endif

    // these at first sight weird-looking connections facilitate thread-safe communication.
    connect(this,
            &ControllerRenderingEngine::sendFrameDataRequested,
            this,
            &ControllerRenderingEngine::send);
    connect(m_pThread.get(),
            &QThread::finished,
            this,
            &ControllerRenderingEngine::finish);

    m_pThread->start(QThread::NormalPriority);
}

ControllerRenderingEngine::~ControllerRenderingEngine() {
    DEBUG_ASSERT_THIS_QOBJECT_THREAD_ANTI_AFFINITY();
    m_pThread->wait();
    VERIFY_OR_DEBUG_ASSERT(!m_fbo) {
        kLogger.critical() << "The ControllerEngine is being deleted but hasn't been "
                              "cleaned up. Brace for impact";
    };
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
    return m_pThread && m_pThread->isRunning();
}

void ControllerRenderingEngine::requestEngineSetup(std::shared_ptr<QQmlEngine> qmlEngine) {
    DEBUG_ASSERT(!m_quickWindow);
    VERIFY_OR_DEBUG_ASSERT(qmlEngine) {
        kLogger.critical() << "No QML engine was passed!";
        return;
    }
    VERIFY_OR_DEBUG_ASSERT_THIS_QOBJECT_THREAD_ANTI_AFFINITY() {
        kLogger.warning() << "Unable to setup OpenGL rendering context from the same "
                             "thread as the render object";
        return;
    }

    QMetaObject::invokeMethod(
            this,
            [this, qmlEngine]() {
                setup(qmlEngine);
            },
            // This invocation will block the current thread!
            Qt::BlockingQueuedConnection);

    if (m_quickWindow) {
        m_renderControl->prepareThread(m_pThread.get());
    }
}

void ControllerRenderingEngine::requestSendingFrameData(
        Controller* controller, const QByteArray& frame) {
    emit sendFrameDataRequested(controller, frame);
}

void ControllerRenderingEngine::setup(std::shared_ptr<QQmlEngine> qmlEngine) {
    VERIFY_OR_DEBUG_ASSERT_THIS_QOBJECT_THREAD_AFFINITY() {
        kLogger.warning() << "The ControllerRenderingEngine setup must be done by its own thread!";
        return;
    }
    QSurfaceFormat format;
    format.setSamples(m_screenInfo.msaa);
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

    // offscreen surface needs to be created from application main thread.
    VERIFY_OR_DEBUG_ASSERT(QMetaObject::invokeMethod(
                                   qApp,
                                   [this] {
                                       m_offscreenSurface->create();
                                   },
                                   // This invocation will block the current thread!
                                   Qt::BlockingQueuedConnection) &&
            m_offscreenSurface->isValid()) {
        kLogger.warning() << "Unable to create the OffscreenSurface for controller "
                             "screen rendering. Giving up";
        m_offscreenSurface.reset();
        return;
    }

    m_renderControl = std::make_unique<QQuickRenderControl>(this);
    m_quickWindow = std::make_unique<QQuickWindow>(m_renderControl.get());

    if (!qmlEngine->incubationController()) {
        qmlEngine->setIncubationController(m_quickWindow->incubationController());
    }

    m_quickWindow->setGeometry(0, 0, m_screenInfo.size.width(), m_screenInfo.size.height());
}

void ControllerRenderingEngine::finish() {
    DEBUG_ASSERT_THIS_QOBJECT_THREAD_AFFINITY();
    emit stopping();

    m_isValid = false;

    if (m_context && m_context->isValid()) {
        disconnect(m_context.get(),
                &QOpenGLContext::aboutToBeDestroyed,
                this,
                &ControllerRenderingEngine::finish);
        m_context->makeCurrent(m_offscreenSurface.get());
        m_renderControl.reset();

        std::shared_ptr<QOffscreenSurface> pOffscreenSurface = std::move(m_offscreenSurface);
        QMetaObject::invokeMethod(
                qApp,
                [pOffscreenSurface] {
                    pOffscreenSurface->destroy();
                });
        m_quickWindow.reset();

        // Free the engine and FBO.
        m_fbo.reset();

        m_context->doneCurrent();
    }
    m_context.reset();
}

void ControllerRenderingEngine::renderFrame() {
    ScopedTimer t(QStringLiteral("ControllerRenderingEngine::renderFrame"));
    if (!m_isValid) {
        DEBUG_ASSERT(!"Trying to render frame on an invalid engine");
        return;
    }

    VERIFY_OR_TERMINATE(m_offscreenSurface->isValid(), "OffscreenSurface isn't valid anymore.");
    VERIFY_OR_TERMINATE(m_context->isValid(), "GLContext isn't valid anymore.");
    VERIFY_OR_TERMINATE(m_context->makeCurrent(m_offscreenSurface.get()),
            "Couldn't make the GLContext current to the OffscreenSurface.");

    if (!m_fbo) {
        ScopedTimer t(QStringLiteral("ControllerRenderingEngine::renderFrame::initFBO"));
        VERIFY_OR_TERMINATE(
                QOpenGLFramebufferObject::hasOpenGLFramebufferObjects(),
                "OpenGL doesn't support FBO");

        m_fbo = std::make_unique<QOpenGLFramebufferObject>(
                m_screenInfo.size, QOpenGLFramebufferObject::CombinedDepthStencil);

        GLenum glError;
        glError = m_context->functions()->glGetError();

        VERIFY_OR_TERMINATE(glError == GL_NO_ERROR, "GLError: " << glError);
        VERIFY_OR_TERMINATE(m_fbo->isValid(), "Failed to initialize FBO");

        m_quickWindow->setGraphicsDevice(QQuickGraphicsDevice::fromOpenGLContext(m_context.get()));

        VERIFY_OR_TERMINATE(m_renderControl->initialize(),
                "Failed to initialize redirected Qt Quick rendering");

        m_quickWindow->setRenderTarget(QQuickRenderTarget::fromOpenGLTexture(m_fbo->texture(),
                m_screenInfo.size));

        m_quickWindow->setGeometry(0, 0, m_screenInfo.size.width(), m_screenInfo.size.height());
    }

    m_nextFrameStart = Clock::now();

    m_renderControl->beginFrame();

    if (m_pEngineThreadControl) {
        m_pEngineThreadControl->pause();
    }

    m_renderControl->polishItems();

    {
        ScopedTimer t(QStringLiteral("ControllerRenderingEngine::renderFrame::sync"));
        VERIFY_OR_DEBUG_ASSERT(m_renderControl->sync()) {
            kLogger.warning() << "Couldn't sync the render control. Scene may be stuck";
        };
    }

    if (m_pEngineThreadControl) {
        m_pEngineThreadControl->resume();
    }
    QImage fboImage(m_screenInfo.size, m_screenInfo.pixelFormat);

    VERIFY_OR_DEBUG_ASSERT(m_fbo->bind()) {
        kLogger.warning() << "Couldn't bind the FBO.";
    }
    GLenum glError;
    m_context->functions()->glFlush();
    glError = m_context->functions()->glGetError();
    VERIFY_OR_TERMINATE(glError == GL_NO_ERROR, "GLError: " << glError);
    if (static_cast<std::endian>(m_screenInfo.endian) != std::endian::native) {
#ifdef QT_OPENGL_ES_2
        kLogger.critical()
                << "Screen endianness mismatches native endianness, but OpenGL "
                   "ES does not let us specify a reverse pixel store order. "
                   "This will likely lead to invalid colors.";
#else
        m_context->functions()->glPixelStorei(GL_PACK_SWAP_BYTES, GL_TRUE);
#endif
    }
    glError = m_context->functions()->glGetError();
    VERIFY_OR_TERMINATE(glError == GL_NO_ERROR, "GLError: " << glError);

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
                m_GLDataFormat,
                m_GLDataType,
                fboImage.bits());
    }
    glError = m_context->functions()->glGetError();
    VERIFY_OR_TERMINATE(glError == GL_NO_ERROR, "GLError: " << glError);
    VERIFY_OR_DEBUG_ASSERT(!fboImage.isNull()) {
        kLogger.warning() << "Screen frame is null!";
    }
    VERIFY_OR_DEBUG_ASSERT(m_fbo->release()) {
        kLogger.debug() << "Couldn't release the FBO.";
    }

    fboImage.mirror(false, true);

    QList<UpdatedRect> updatedAreas;

    if (!mLastFrame.isNull()) {
        ScopedTimer t(
                QStringLiteral("ControllerRenderingEngine::renderFrame::"
                               "calculateUpdatedArea"));
        mPixelDiff.fill(0);
        mUpdatedRectMatrix.fill(nullptr);
        mUpdatedRect.clear();
        auto pixelByteSize = fboImage.sizeInBytes() / mPixelDiff.size();

        for (int p = 0; p < mPixelDiff.size(); p++) {
            for (int b = 0; b < pixelByteSize; b++) {
                if (fboImage.constBits()[p * pixelByteSize + b] !=
                        mLastFrame.constBits()[p * pixelByteSize + b]) {
                    mPixelDiff[p] |= 0xff;
                }
            }
        }

        for (int y = 0; y < m_screenInfo.size.height(); y++) {
            for (int x = 0; x < m_screenInfo.size.width(); x++) {
                if (mPixelDiff[y * m_screenInfo.size.width() + x]) {
                    mUpdatedRectMatrix[y * m_screenInfo.size.width() + x] = getUpdatedArea(x, y);
                }
            }
        }
        auto pixelChangedCount = mPixelDiff.count(0xff);
        if (pixelChangedCount) {
            // qDebug() << "pixel updated:"<<pixelChangedCount;
            // qDebug() << "area updated:"<<mUpdatedRect.size();
            for (auto& area : mUpdatedRect) {
                updatedAreas.append(*area);
            }
        }
    } else {
        updatedAreas.push_back(UpdatedRect(
                0, 0, m_screenInfo.size.width(), m_screenInfo.size.height()));
    }
    mLastFrame = fboImage;

    emit frameRendered(m_screenInfo, fboImage.copy(), updatedAreas, timestamp);

    m_context->doneCurrent();
}

bool ControllerRenderingEngine::stop() {
    m_pThread->quit();
    return m_pThread->wait();
}

void ControllerRenderingEngine::send(Controller* controller, const QByteArray& frame) {
    DEBUG_ASSERT_THIS_QOBJECT_THREAD_AFFINITY();
    ScopedTimer t(QStringLiteral("ControllerRenderingEngine::send"));
    if (!frame.isEmpty()) {
        controller->sendBytes(frame);
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

    m_nextFrameStart += std::chrono::microseconds(1000000 / m_screenInfo.target_fps);

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

ControllerRenderingEngine::UpdatedRect* searchOnX(
        QVector<ControllerRenderingEngine::UpdatedRect*>& matrix,
        int width,
        int x,
        int y,
        int max) {
    for (int d = 1; d < max; d++) {
        if (x > d - 1 && matrix[y * width + (x - d)]) {
            return matrix[y * width + (x - d)];
        }
    }
    return nullptr;
}

ControllerRenderingEngine::UpdatedRect* searchOnY(
        QVector<ControllerRenderingEngine::UpdatedRect*>& matrix,
        int width,
        int x,
        int y,
        int max) {
    QVector<int> cols = {x};
    for (int d = 1; d < max; d++) {
        if (x > d - 1) {
            cols.push_front(x - d);
        }
        if (x < width - d) {
            cols.push_back(x + d);
        }
    }

    for (auto dx : cols) {
        for (int d = 1; d < max; d++) {
            if (y > d - 1 && matrix[(y - d) * width + dx]) {
                return matrix[(y - d) * width + dx];
            }
        }
    }
    return nullptr;
}

ControllerRenderingEngine::UpdatedRect* ControllerRenderingEngine::getUpdatedArea(int x, int y) {
    auto width = m_screenInfo.size.width();
    auto height = m_screenInfo.size.height();
    UpdatedRect* area = searchOnX(mUpdatedRectMatrix, width, x, y, 10);
    if (!area) {
        area = searchOnY(mUpdatedRectMatrix, width, x, y, 10);
    }
    if (!area) {
        mUpdatedRect.push_back(std::make_unique<UpdatedRect>(x, y));
        return mUpdatedRect.back().get();
    }

    if (area->x + area->width <= x) {
        area->width++;
    } else if (area->x > x) {
        area->x--;
        area->width++;
    }
    if (area->y + area->height <= y) {
        area->height++;
    } else if (area->y > y) {
        area->y--;
        area->height++;
    }
    return area;
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
