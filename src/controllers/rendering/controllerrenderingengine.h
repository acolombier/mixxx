#pragma once

#include <QFileSystemWatcher>
#include <QJSValue>
#include <QLabel>
#include <QOffscreenSurface>
#include <QOpenGLContext>
#include <QOpenGLFramebufferObject>
#include <QQmlEngine>
#include <QQuickItem>
#include <QQuickRenderControl>
#include <QQuickWindow>
#include <QThread>
#include <QTimer>
#include <bit>

#include "controllers/legacycontrollermapping.h"
#include "controllers/scripting/controllerscriptenginebase.h"
#include "preferences/configobject.h"
#include "util/parented_ptr.h"
#include "util/runtimeloggingcategory.h"
#include "util/time.h"

class ControllerRenderingTransformFunctionBase;

class ControllerRenderingEngine : public QObject {
    Q_OBJECT
  public:
    ControllerRenderingEngine(const LegacyControllerMapping::ScreenInfo& info);
    ~ControllerRenderingEngine();

    bool event(QEvent* event) override;

    bool stop();

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
    void start();

  private slots:
    void cleanup();
    void renderFrame();
    void setup(std::shared_ptr<QQmlEngine> qmlEngine);

  signals:
    void frameRendered(const LegacyControllerMapping::ScreenInfo& screeninfo, QImage frame);
    void setupRequested(std::shared_ptr<QQmlEngine> engine);

  private:
    void createFbo();

    mixxx::Duration m_nextFrameStart;

    LegacyControllerMapping::ScreenInfo m_screenInfo;

    std::unique_ptr<QOpenGLContext> m_context;
    std::unique_ptr<QOffscreenSurface> m_offscreenSurface;
    std::unique_ptr<QQuickRenderControl> m_renderControl;
    std::unique_ptr<QQuickWindow> m_quickWindow;

    std::unique_ptr<QOpenGLFramebufferObject> m_fbo;

    std::unique_ptr<QTimer> m_pFrameClock;

    QImage::Format m_imageFormat;
    GLenum m_GLDataType;
    bool m_reversedPixelFormat;
};
