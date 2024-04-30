#pragma once

#include <GL/gl.h>

#include <QMutex>
#include <QObject>
#include <QWaitCondition>

#include "controllers/legacycontrollermapping.h"
#include "controllers/scripting/controllerscriptenginebase.h"
#include "preferences/configobject.h"
#include "util/time.h"

class Controller;
class QOffscreenSurface;
class QOpenGLContext;
class QOpenGLFramebufferObject;
class QQmlEngine;
class QQuickRenderControl;
class QQuickWindow;
class ControllerRenderingScheduler;

/// @brief This class is used to host the rendering of a screen controller,
/// using and existing QML Engine running under a ControllerScriptEngineBase.
class ControllerRenderingEngine : public QObject {
    Q_OBJECT
  public:
    ControllerRenderingEngine(const LegacyControllerMapping::ScreenInfo& info,
            ControllerScriptEngineBase* parent);
    ~ControllerRenderingEngine();

    const QSize& size() const {
        return m_screenInfo.size;
    }

    bool isValid() const {
        return m_isValid;
    }

    bool isRunning() const;

    QQuickWindow* quickWindow() const {
        return m_quickWindow.get();
    }

    const LegacyControllerMapping::ScreenInfo& info() const {
        return m_screenInfo;
    }

  public slots:
    virtual void requestSend(Controller* controller, const QByteArray& frame);
    void requestSetup(std::shared_ptr<QQmlEngine> qmlEngine);
    void start();
    virtual bool stop();

  private slots:
    void finish();
    void renderFrame();
    void setup(std::shared_ptr<QQmlEngine> qmlEngine);

  signals:
    void frameRendered(const LegacyControllerMapping::ScreenInfo& screeninfo,
            QImage frame,
            const QDateTime& timestamp);
    void setupRequested(std::shared_ptr<QQmlEngine> engine);
    void stopRequested();

  private:
    virtual void prepare();

    mixxx::Duration m_nextFrameStart;

    LegacyControllerMapping::ScreenInfo m_screenInfo;

    std::unique_ptr<ControllerRenderingScheduler> m_pScheduler;

    std::unique_ptr<QOpenGLContext> m_context;
    std::unique_ptr<QOffscreenSurface> m_offscreenSurface;
    std::unique_ptr<QQuickRenderControl> m_renderControl;
    std::unique_ptr<QQuickWindow> m_quickWindow;

    std::unique_ptr<QOpenGLFramebufferObject> m_fbo;

    GLenum m_GLDataFormat;
    GLenum m_GLDataType;

    bool m_isValid;

    // These mutexes components are used to ensure internal object synchronicity
    QWaitCondition m_waitCondition;
    QMutex m_mutex;

    ControllerScriptEngineBase* m_pControllerEngine;

    // This static mutex is used to ensure exclusive access to OpenGL operation
    // from each of the ControllerRenderingEngine instances
    static QMutex s_glMutex;
};
