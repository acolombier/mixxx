#pragma once

#include <GL/gl.h>

#include <QMutex>
#include <QThread>
#include <QWaitCondition>

#include "controllers/legacycontrollermapping.h"
#include "util/time.h"

class Controller;
class QByteArray;

/// @brief This class is used to host the rendering of a screen controller,
/// using and existing QML Engine running under a ControllerScriptEngineBase.
class ControllerRenderingScheduler : public QThread {
    Q_OBJECT
  public:
    ControllerRenderingScheduler(const LegacyControllerMapping::ScreenInfo& screenInfo);

    bool event(QEvent* event) override;

  public slots:
    void requestSend(Controller* controller, const QByteArray& frame);
    void send(Controller* controller, const QByteArray& frame);

  signals:
    void frameRequested();
    void sendRequested(Controller* controller, const QByteArray& frame);

  private:
    mixxx::Duration m_nextFrameStart;

    LegacyControllerMapping::ScreenInfo m_screenInfo;
};
