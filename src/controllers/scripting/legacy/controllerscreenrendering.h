#pragma once

#include <QJSValue>
#include <QThread>
#include <QOpenGLContext>
#include <QOffscreenSurface>
#include <QQuickRenderControl>
#include <QQuickItem>
#include <QLabel>
#include <QTimer>
#include <QOpenGLFramebufferObject>

#include "preferences/configobject.h"
#include "controllers/legacycontrollermapping.h"
#include "controllers/scripting/controllerscriptenginebase.h"
#include "util/runtimeloggingcategory.h"
#include "util/time.h"

class ControllerScriptInterfaceLegacy;

class ControllerScreenRendering: public ControllerScriptEngineBase {
    Q_OBJECT
  public:

    ControllerScreenRendering(Controller* controller, LegacyControllerMapping::QMLFileInfo qml, const RuntimeLoggingCategory& logger, uint8_t screenId);
    ~ControllerScreenRendering();

    bool event(QEvent *event) override;

    QJSEngine* jsEngine() const override { return m_qmlEngine.get(); }

    bool stop() { m_pThread->requestInterruption();
      if (QThread::currentThread() != m_pThread.get()){
        m_pThread->wait();
      }
      return true;
    }

private slots:
    void start();
    void cleanup();

    void createFbo();
    bool load(const QString &qmlFile, const QSize &size);

    void renderNext();

  signals:
    void frameRendered(const QImage& frame);

  private:
    uint8_t m_screenId;
    // QTimer* m_pTimer;
    mixxx::Duration m_nextFrameStart;

    LegacyControllerMapping::QMLFileInfo m_renderingInfo;
    QSize m_size;

    QJSValue m_tranformFunction;

    std::unique_ptr<QThread> m_pThread;

    std::unique_ptr<ControllerScriptInterfaceLegacy> m_pScrintInterface;

    std::unique_ptr<QOpenGLContext> m_context;
    std::unique_ptr<QOffscreenSurface> m_offscreenSurface;
    std::unique_ptr<QQuickRenderControl> m_renderControl;
    std::unique_ptr<QQuickWindow> m_quickWindow;
    std::unique_ptr<QQmlEngine> m_qmlEngine;
    std::unique_ptr<QQmlComponent> m_qmlComponent;
    std::unique_ptr<QOpenGLFramebufferObject> m_fbo;

    std::unique_ptr<QLabel> m_pDebugWindow;

    std::unique_ptr<QQuickItem> m_rootItem;
    
};
