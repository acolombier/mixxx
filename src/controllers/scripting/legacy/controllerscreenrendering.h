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

class ControllerScriptInterfaceLegacy;

class ControllerScreenRendering: public ControllerScriptEngineBase {
    Q_OBJECT
  public:

    ControllerScreenRendering(Controller* controller, LegacyControllerMapping::QMLFileInfo qml, const RuntimeLoggingCategory& logger, uint8_t screenId);
    ~ControllerScreenRendering();

    bool event(QEvent *event) override;

    QJSEngine* jsEngine() const override { return m_qmlEngine; }

    bool stop() { m_pThread->requestInterruption();
      VERIFY_OR_DEBUG_ASSERT(m_pThread->wait(1000)){
          qCritical() << "Unable to terminate thread gracefully. Killing it now.";
          m_pThread->terminate();
          VERIFY_OR_DEBUG_ASSERT(m_pThread->wait()){
              qCritical() << "Unable to kill thread. What the hell is going on?";
              return false;
          }
      }; 
      return true;
    }

private slots:
    void start();
    void cleanup();

    void createFbo();
    void destroyFbo();
    bool load(const QString &qmlFile, const QSize &size);

    void renderNext();

  signals:
    void frameRendered(const QImage& frame);

  private:
    uint8_t m_screenId;
    QThread* m_pThread;
    QTimer* m_pTimer;

    ControllerScriptInterfaceLegacy* m_pScrintInterface;

    LegacyControllerMapping::QMLFileInfo m_renderingInfo;

    QOpenGLContext *m_context;
    QOffscreenSurface *m_offscreenSurface;
    QQuickRenderControl *m_renderControl;
    QQuickWindow *m_quickWindow;
    QQmlEngine *m_qmlEngine;
    QQmlComponent *m_qmlComponent;
    QQuickItem *m_rootItem;
    QOpenGLFramebufferObject *m_fbo;
    QSize m_size;

    QLabel* m_pDebugWindow;
    
};
