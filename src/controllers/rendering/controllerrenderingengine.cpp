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
#include "controllers/rendering/controllerrenderingscheduler.h"
#include "controllers/scripting/legacy/controllerscriptenginelegacy.h"
#include "controllers/scripting/legacy/controllerscriptinterfacelegacy.h"
#include "moc_controllerrenderingengine.cpp"
#include "qml/qmlwaveformoverview.h"
#include "util/cmdlineargs.h"
#include "util/logger.h"
#include "util/time.h"

namespace {
const mixxx::Logger kLogger("ControllerRenderingEngine");
} // anonymous namespace

QMutex ControllerRenderingEngine::s_glMutex = QMutex();

ControllerRenderingEngine::ControllerRenderingEngine(
        const LegacyControllerMapping::ScreenInfo& info,
        ControllerScriptEngineBase* parent)
        : QObject(),
          m_screenInfo(info),
          m_GLDataFormat(GL_RGBA),
          m_GLDataType(GL_UNSIGNED_BYTE),
          m_isValid(true),
          m_pControllerEngine(parent) {
    switch (m_screenInfo.pixelFormat) {
    case QImage::Format_RGB16:
        m_GLDataFormat = GL_RGB;
        m_GLDataType = m_screenInfo.reversedColor
                ? GL_UNSIGNED_SHORT_5_6_5_REV
                : GL_UNSIGNED_SHORT_5_6_5;
        break;
    case QImage::Format_RGB888:
        m_GLDataFormat = m_screenInfo.reversedColor ? GL_BGR : GL_RGB;
        m_GLDataType = GL_UNSIGNED_BYTE;
        break;
    case QImage::Format_RGBA8888:
        m_GLDataFormat = m_screenInfo.reversedColor ? GL_BGRA : GL_RGBA;
        m_GLDataType = GL_UNSIGNED_BYTE;
        break;
    default:
        m_isValid = false;
        DEBUG_ASSERT(!"Unsupported format");
    }

    if (!m_isValid) {
        return;
    }

    prepare();
}

void ControllerRenderingEngine::prepare() {
    m_pScheduler = std::make_unique<ControllerRenderingScheduler>(m_screenInfo);

    connect(this,
            &ControllerRenderingEngine::setupRequested,
            this,
            &ControllerRenderingEngine::setup);
    connect(this,
            &ControllerRenderingEngine::stopRequested,
            this,
            &ControllerRenderingEngine::finish);
    connect(m_pScheduler.get(),
            &ControllerRenderingScheduler::frameRequested,
            this,
            &ControllerRenderingEngine::renderFrame);

    moveToThread(qApp->thread());
}

ControllerRenderingEngine::~ControllerRenderingEngine() {
    VERIFY_OR_DEBUG_ASSERT(!m_fbo) {
        kLogger.warning() << "The ControllerEngine is being deleted but hasn't been "
                             "cleaned up. Brace for impact";
    };
}

void ControllerRenderingEngine::start() {
    VERIFY_OR_DEBUG_ASSERT(!m_pScheduler->isFinished() &&
            !m_pScheduler->isInterruptionRequested()) {
        kLogger.warning() << "Render thread has or ir about to terminate. Cannot "
                             "start this render anymore.";
        return;
    }
    m_pScheduler->start(QThread::NormalPriority);
}
bool ControllerRenderingEngine::isRunning() const {
    return m_pScheduler && m_pScheduler->isRunning();
}

void ControllerRenderingEngine::requestSetup(std::shared_ptr<QQmlEngine> qmlEngine) {
    m_isValid = false;
    VERIFY_OR_DEBUG_ASSERT(QThread::currentThread() != thread()) {
        kLogger.warning() << "Unable to setup OpenGL rendering context from the same "
                             "thread as the render object";
        return;
    }
    emit setupRequested(qmlEngine);

    const auto lock = lockMutex(&m_mutex);
    if (!m_quickWindow) {
        m_waitCondition.wait(&m_mutex);
    }
    // if (m_isValid) {
    //     m_renderControl->prepareThread(thread());
    // }
}

void ControllerRenderingEngine::requestSend(Controller* controller, const QByteArray& frame) {
    VERIFY_OR_DEBUG_ASSERT(m_pScheduler) {
        return;
    }
    m_pScheduler->requestSend(controller, frame);
}

void ControllerRenderingEngine::setup(std::shared_ptr<QQmlEngine> qmlEngine) {
    QSurfaceFormat format;
    // format.setSamples(16);
    // format.setDepthBufferSize(16);
    // format.setStencilBufferSize(8);

    const auto lock = lockMutex(&s_glMutex);

    m_context = std::make_unique<QOpenGLContext>();
    m_context->setFormat(format);
    VERIFY_OR_DEBUG_ASSERT(m_context->create()) {
        kLogger.warning() << "Unable to initialize controller screen rendering. Giving up";
        m_waitCondition.wakeAll();
        return;
    }
    connect(m_context.get(),
            &QOpenGLContext::aboutToBeDestroyed,
            this,
            &ControllerRenderingEngine::finish,
            Qt::BlockingQueuedConnection);

    m_offscreenSurface = std::make_unique<QOffscreenSurface>();
    m_offscreenSurface->setFormat(m_context->format());

    m_offscreenSurface->create();
    VERIFY_OR_DEBUG_ASSERT(m_offscreenSurface->isValid()) {
        kLogger.warning() << "Unable to create the OffscreenSurface for controller "
                             "screen rendering. Giving up";
        m_offscreenSurface.reset();
        m_waitCondition.wakeAll();
        return;
    }

    m_renderControl = std::make_unique<QQuickRenderControl>(this);
    m_quickWindow = std::make_unique<QQuickWindow>(m_renderControl.get());

    if (!qmlEngine->incubationController()) {
        qmlEngine->setIncubationController(m_quickWindow->incubationController());
    }

    m_quickWindow->setGeometry(0, 0, m_screenInfo.size.width(), m_screenInfo.size.height());

    m_isValid = true;
    m_waitCondition.wakeAll();
}

void ControllerRenderingEngine::finish() {
    m_isValid = false;
    disconnect(this);

    const auto lock = lockMutex(&s_glMutex);

    if (m_context && m_context->isValid()) {
        disconnect(m_context.get(),
                &QOpenGLContext::aboutToBeDestroyed,
                this,
                &ControllerRenderingEngine::finish);
        m_context->makeCurrent(m_offscreenSurface.get());
        m_renderControl.reset();

        m_offscreenSurface->destroy();
        m_quickWindow.reset();

        // Free the engine and FBO
        m_fbo.reset();

        m_context->doneCurrent();
    }
    m_context.reset();
    m_pScheduler->terminate();
}

void ControllerRenderingEngine::renderFrame() {
    if (!m_isValid) {
        DEBUG_ASSERT(!"Trying to render frame on an invalid engine");
        return;
    }

    VERIFY_OR_DEBUG_ASSERT(m_offscreenSurface->isValid()) {
        kLogger.warning() << "OffscreenSurface isn't valid anymore.";
        finish();
        return;
    };
    VERIFY_OR_DEBUG_ASSERT(m_context->isValid()) {
        kLogger.warning() << "GLContext isn't valid anymore.";
        finish();
        return;
    };

    auto lock = lockMutex(&s_glMutex);

    VERIFY_OR_DEBUG_ASSERT(m_context->makeCurrent(m_offscreenSurface.get())) {
        kLogger.warning() << "Couldn't make the GLContext current to the OffscreenSurface.";
        lock.unlock();
        finish();
        return;
    };

    if (!m_fbo) {
        VERIFY_OR_DEBUG_ASSERT(QOpenGLFramebufferObject::hasOpenGLFramebufferObjects()) {
            kLogger.warning() << "OpenGL doesn't support FBO";
            lock.unlock();
            finish();
            return;
        };

        m_fbo = std::make_unique<QOpenGLFramebufferObject>(
                m_screenInfo.size, QOpenGLFramebufferObject::NoAttachment);

        GLenum glError;
        glError = m_context->functions()->glGetError();

        VERIFY_OR_DEBUG_ASSERT(glError == GL_NO_ERROR) {
            kLogger.warning() << "GLError: " << glError;
            lock.unlock();
            finish();
            return;
        };

        VERIFY_OR_DEBUG_ASSERT(m_fbo->isValid()) {
            kLogger.warning() << "Failed to initialize FBO";
            lock.unlock();
            finish();
            return;
        };

        m_quickWindow->setGraphicsDevice(QQuickGraphicsDevice::fromOpenGLContext(m_context.get()));

        VERIFY_OR_DEBUG_ASSERT(m_renderControl->initialize()) {
            kLogger.warning() << "Failed to initialize redirected Qt Quick rendering";
            lock.unlock();
            finish();
            return;
        };

        m_quickWindow->setRenderTarget(QQuickRenderTarget::fromOpenGLTexture(m_fbo->texture(),
                m_screenInfo.size));

        m_quickWindow->setGeometry(0, 0, m_screenInfo.size.width(), m_screenInfo.size.height());
    }

    m_nextFrameStart = mixxx::Time::elapsed();

    m_renderControl->polishItems();
    m_renderControl->beginFrame();

    if (m_pControllerEngine) {
        m_pControllerEngine->pause();
    }


    VERIFY_OR_DEBUG_ASSERT(m_renderControl->sync()) {
        kLogger.warning() << "Couldn't sync the render control.";
        lock.unlock();
        finish();
        if (m_pControllerEngine) {
            m_pControllerEngine->resume();
        }

        return;
    };

    if (m_pControllerEngine) {
        m_pControllerEngine->resume();
    }
    QImage fboImage(m_screenInfo.size, m_screenInfo.pixelFormat);

    VERIFY_OR_DEBUG_ASSERT(m_fbo->bind()) {
        kLogger.warning() << "Couldn't bind the FBO.";
    }
    GLenum glError;
    m_context->functions()->glFlush();
    glError = m_context->functions()->glGetError();
    VERIFY_OR_DEBUG_ASSERT(glError == GL_NO_ERROR) {
        kLogger.warning() << "GLError: " << glError;
        lock.unlock();
        finish();
        return;
    }
    if (m_screenInfo.endian != std::endian::native) {
        m_context->functions()->glPixelStorei(GL_PACK_SWAP_BYTES, GL_TRUE);
    }
    glError = m_context->functions()->glGetError();
    VERIFY_OR_DEBUG_ASSERT(glError == GL_NO_ERROR) {
        kLogger.warning() << "GLError: " << glError;
        lock.unlock();
        finish();
        return;
    }

    QDateTime timestamp = QDateTime::currentDateTime();
    m_renderControl->render();
    m_renderControl->endFrame();

    // Flush any remaining GL errors
    while (m_context->functions()->glGetError()) {
    }
    m_context->functions()->glReadPixels(0,
            0,
            m_screenInfo.size.width(),
            m_screenInfo.size.height(),
            m_GLDataFormat,
            m_GLDataType,
            fboImage.bits());
    glError = m_context->functions()->glGetError();
    VERIFY_OR_DEBUG_ASSERT(glError == GL_NO_ERROR) {
        kLogger.warning() << "GLError: " << glError;
        lock.unlock();
        finish();
        return;
    }
    VERIFY_OR_DEBUG_ASSERT(!fboImage.isNull()) {
        kLogger.warning() << "Screen frame is null!";
    }
    VERIFY_OR_DEBUG_ASSERT(m_fbo->release()) {
        kLogger.debug() << "Couldn't release the FBO.";
    }

    fboImage.mirror(false, true);

    emit frameRendered(m_screenInfo, fboImage, timestamp);

    m_context->doneCurrent();
}

bool ControllerRenderingEngine::stop() {
    emit stopRequested();
    return m_pScheduler->wait();
}
