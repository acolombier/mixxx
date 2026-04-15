#pragma once

#include <qwaitcondition.h>
#include <QObject>
#include <QOpenGLContext>
#include <QOpenGLFramebufferObject>
#include <chrono>
#include <gsl/pointers>

#include "controllers/legacycontrollermapping.h"
#include "preferences/configobject.h"
#include "util/time.h"

class Controller;
class ControllerEngineThreadControl;
class QOffscreenSurface;
class QOpenGLContext;
class QOpenGLFramebufferObject;
class QQmlEngine;
class QQuickRenderControl;
class QQuickWindow;
class QThread;

class QuickRenderer : public QObject
{
    Q_OBJECT

public:
    QuickRenderer(LegacyControllerMapping::ScreenInfo screenInfo);

    // void requestInit();
    void init();
    void requestRender();
    void requestResize();
    void requestCleanup();
    void requestStop();
    bool isValid() const { return m_isValid; }
    const LegacyControllerMapping::ScreenInfo& screen() const { return m_screenInfo; }

    QWaitCondition *cond() { return &m_cond; }
    QMutex *mutex() { return &m_mutex; }

    void setContext(QOpenGLContext *ctx) { m_context = ctx; }
    void setSurface(QOffscreenSurface *s) { m_surface = s; }
    void setWindow(QWindow *w) { m_window = w; }
    void setQuickWindow(QQuickWindow *w) { m_quickWindow = w; }
    void setRenderControl(QQuickRenderControl *r) { m_renderControl = r; }

    void aboutToQuit();

  signals:
    void frameRendered(const LegacyControllerMapping::ScreenInfo& screeninfo,
            QImage frame,
            const QDateTime& timestamp);

private:
    bool event(QEvent *e) override;
    void cleanup();
    void cleanupRhi();
    void ensureTexture();
    void render(QMutexLocker<QMutex> *lock);

    QWaitCondition m_cond;
    QMutex m_mutex;
    QOpenGLContext *m_context;
    QOffscreenSurface *m_surface;
    QWindow *m_window;
    QQuickWindow *m_quickWindow;
    QQuickRenderControl *m_renderControl;
    QImage m_frame;
    uint m_textureId;
    uint m_fboId;

    LegacyControllerMapping::ScreenInfo m_screenInfo;
    GLenum m_GLDataFormat;
    GLenum m_GLDataType;

    bool m_isValid;
};

class ControllerRenderingEngine;
class ControllerRenderingEngineDeleter {
public:
    explicit ControllerRenderingEngineDeleter(){}
    void operator()(ControllerRenderingEngine* pEngine) const;
};


/// @brief This class is used to host the rendering of a screen controller,
/// using and existing QML Engine running under a ControllerScriptEngineBase.
class ControllerRenderingEngine : public QObject {
    Q_OBJECT
  public:
    ControllerRenderingEngine(const LegacyControllerMapping::ScreenInfo& info,
            gsl::not_null<ControllerEngineThreadControl*> engineThreadControl);
    // Destructor will wait for the ControllerRenderingEngine's thread to
    // complete. It should be called from the Controller thread.
    ~ControllerRenderingEngine();

    bool event(QEvent* event) override;

    QSize screenSize() const {
        return m_quickRenderer->screen().size;
    }

    bool isValid() const {
        return m_quickRenderer->isValid();
    }

    bool isRunning() const;

    // pointer lives as long as the `ControllerRenderingEngine` instance it is retrieved from.
    QQuickWindow* quickWindow() const {
        return m_quickWindow.get();
    }

    const LegacyControllerMapping::ScreenInfo& info() const {
        return m_quickRenderer->screen();
    }
    QuickRenderer* renderer() const {
        return m_quickRenderer.get();
    }

  public slots:
    // Request sending frame data to the device. The task will be run in the
    // rendering event loop. This method should only be called once received the
    // `frameRendered` signal.
    /// @brief Request the screen thread to send a frame to the device.
    /// @param controller the controller to send the frame to.
    /// @param frame the frame data, ready to be sent.
    void sendFrameData(Controller* controller, const QByteArray& frame);
    // Request setting up the rendering context for QML engine and wait till it
    // is completed. The task will be run in the rendering event loop to ensure
    // thread affinity of engine components. `isValid` can be used to ensure
    // that the setup was successful.
    void setup(QQmlEngine* qmlEngine);
    void start();
    virtual bool stop();

  private slots:
    void finish();
    void renderFrame();

  signals:
    void stopping();
    /// Emit signal when the incubator has been set (if required)
    void finalizeSetup();

  private:
    std::chrono::time_point<std::chrono::steady_clock> m_nextFrameStart;

    std::unique_ptr<QThread> m_pQuickRendererThread;

    std::unique_ptr<QOpenGLContext> m_context;
    std::unique_ptr<QOffscreenSurface> m_offscreenSurface;
    std::unique_ptr<QQuickRenderControl> m_renderControl;
    std::unique_ptr<QuickRenderer> m_quickRenderer;
    std::unique_ptr<QQuickWindow> m_quickWindow;
    QQmlEngine *m_engine;
    
    QMutex m_mutex;
    QWaitCondition m_startedCond;

    // Engine control is owned by ControllerScriptEngineBase. The assumption is
    // made that ControllerScriptEngineBase always outlive
    // ControllerRenderingEngine as it is in charge of stopping and joining the
    // thread.
    gsl::not_null<ControllerEngineThreadControl*> m_pEngineThreadControl;
};
