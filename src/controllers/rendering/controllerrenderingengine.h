#pragma once

#include <QFileSystemWatcher>
#include <QJSValue>
#include <QLabel>
#include <QMutex>
#include <QOffscreenSurface>
#include <QOpenGLContext>
#include <QOpenGLFramebufferObject>
#include <QQmlEngine>
#include <QQuickItem>
#include <QQuickRenderControl>
#include <QQuickWindow>
#include <QThread>
#include <QTimer>
#include <QWaitCondition>
#include <bit>

#include "controllers/legacycontrollermapping.h"
#include "controllers/scripting/controllerscriptenginebase.h"
#include "preferences/configobject.h"
#include "util/parented_ptr.h"
#include "util/runtimeloggingcategory.h"
#include "util/time.h"

class Controller;

class ControllerRenderingEngine : public QObject {
    Q_OBJECT
  public:
    ControllerRenderingEngine(const LegacyControllerMapping::ScreenInfo& info);
    ~ControllerRenderingEngine();

    bool event(QEvent* event) override;

    const QSize& size() const {
        return m_screenInfo.size;
    }

    QQuickWindow* quickWindow() const {
        return m_quickWindow.get();
    }

    const LegacyControllerMapping::ScreenInfo& info() const {
        return m_screenInfo;
    }

  public slots:
    void requestSetup(std::shared_ptr<QQmlEngine> qmlEngine);
    void requestSend(Controller* controller, const QByteArray& frame);
    void start();
    bool stop();

  private slots:
    void finish();
    void renderFrame();
    void setup(std::shared_ptr<QQmlEngine> qmlEngine);
    void send(Controller* controller, const QByteArray& frame);

  signals:
    void frameRendered(const LegacyControllerMapping::ScreenInfo& screeninfo, QImage frame);
    void setupRequested(std::shared_ptr<QQmlEngine> engine);
    void stopRequested();
    void sendRequested(Controller* controller, const QByteArray& frame);

  private:
    mixxx::Duration m_nextFrameStart;

    LegacyControllerMapping::ScreenInfo m_screenInfo;

    std::unique_ptr<QThread> m_pThread;

    std::unique_ptr<QOpenGLContext> m_context;
    std::unique_ptr<QOffscreenSurface> m_offscreenSurface;
    std::unique_ptr<QQuickRenderControl> m_renderControl;
    std::unique_ptr<QQuickWindow> m_quickWindow;

    std::unique_ptr<QOpenGLFramebufferObject> m_fbo;

    QImage::Format m_imageFormat;
    GLenum m_GLDataType;

    QWaitCondition m_waitCondition;
    QMutex m_mutex;
};
