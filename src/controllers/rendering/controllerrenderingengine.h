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

#include "controllers/legacycontrollermapping.h"
#include "controllers/scripting/controllerscriptenginebase.h"
#include "preferences/configobject.h"
#include "util/runtimeloggingcategory.h"
#include "util/time.h"

class ControllerRenderingTransformFunctionBase;

class ControllerRenderingEngine : public QObject {
    Q_OBJECT
  public:
    ControllerRenderingEngine(Controller* controller,
            LegacyControllerMapping::QMLFileInfo qml,
            const RuntimeLoggingCategory& logger,
            uint8_t screenId);

    bool event(QEvent* event) override;

    bool stop() {
        m_pThread->requestInterruption();
        if (QThread::currentThread() != m_pThread.get()) {
            m_pThread->wait();
        }
        return true;
    }

    std::shared_ptr<QOpenGLFramebufferObject> fbo() const {
        return m_fbo;
    }

    std::shared_ptr<QJSEngine> jsEngine() const {
        return m_qmlEngine;
    }

    const QSize& size() const {
        return m_renderingInfo.size;
    }

  private slots:
    void start();
    void cleanup();
    void reload();
    void renderNext();

  signals:
    void debugScreenRendered(QImage frame);
    void frameRendered(QByteArray frame);

  private:
    void createFbo();
    bool load(const QString& qmlFile);

    uint8_t m_screenId;
    mixxx::Duration m_nextFrameStart;

    LegacyControllerMapping::QMLFileInfo m_renderingInfo;

    std::unique_ptr<ControllerRenderingTransformFunctionBase> m_pTransformFunction;

    std::unique_ptr<QThread> m_pThread;

    std::unique_ptr<QOpenGLContext> m_context;
    std::unique_ptr<QOffscreenSurface> m_offscreenSurface;
    std::unique_ptr<QQuickRenderControl> m_renderControl;
    std::unique_ptr<QQuickWindow> m_quickWindow;
    std::unique_ptr<QQmlComponent> m_qmlComponent;

    std::shared_ptr<QQmlEngine> m_qmlEngine;
    std::shared_ptr<QOpenGLFramebufferObject> m_fbo;

    QByteArray m_screenBuffer;

    QFileSystemWatcher m_fileWatcher;

    std::unique_ptr<QQuickItem> m_rootItem;

    QImage::Format mImageFormat;
    GLenum mGLDataType;
};
