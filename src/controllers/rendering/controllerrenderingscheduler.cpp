#include "controllers/rendering/controllerrenderingscheduler.h"

#include <QByteArray>
#include <QTimer>

#include "controllers/controller.h"
#include "controllers/scripting/legacy/controllerscriptenginelegacy.h"
#include "controllers/scripting/legacy/controllerscriptinterfacelegacy.h"
#include "moc_controllerrenderingscheduler.cpp"
#include "util/cmdlineargs.h"
#include "util/logger.h"
#include "util/time.h"

namespace {
const mixxx::Logger kLogger("ControllerRenderingScheduler");
} // anonymous namespace

ControllerRenderingScheduler::ControllerRenderingScheduler(
        const LegacyControllerMapping::ScreenInfo& screenInfo)
        : QThread(), m_screenInfo(screenInfo) {
    // Rename the ControllerRenderingScheduler with the actual screen
    // identifier to help debugging
    setObjectName(
            QString("CtrlScreen_%1").arg(screenInfo.identifier));

    connect(this,
            &ControllerRenderingScheduler::sendRequested,
            this,
            &ControllerRenderingScheduler::send);
    connect(this,
            &QThread::started,
            this,
            &ControllerRenderingScheduler::frameRequested);
    moveToThread(this);
}

void ControllerRenderingScheduler::requestSend(Controller* controller, const QByteArray& frame) {
    emit sendRequested(controller, frame);
}

void ControllerRenderingScheduler::send(Controller* controller, const QByteArray& frame) {
    QThread::msleep(100);
    if (!frame.isEmpty()) {
        controller->sendBytes(frame);
    }

    if (CmdlineArgs::Instance()
                    .getControllerDebug()) {
        auto endOfRender = mixxx::Time::elapsed();
        kLogger.debug() << "Frame took "
                        << (endOfRender - m_nextFrameStart).formatMillisWithUnit()
                        << " and frame has" << frame.size() << "bytes";
    }

    m_nextFrameStart += mixxx::Duration::fromSeconds(1.0 / (double)m_screenInfo.target_fps);

    auto durationToWaitBeforeFrame = (m_nextFrameStart - mixxx::Time::elapsed());
    auto msecToWaitBeforeFrame = durationToWaitBeforeFrame.toIntegerMillis();

    if (msecToWaitBeforeFrame > 0) {
        if (CmdlineArgs::Instance()
                        .getControllerDebug()) {
            kLogger.debug() << "Waiting for "
                            << durationToWaitBeforeFrame.formatMillisWithUnit()
                            << " before rendering next frame";
        }
        QTimer::singleShot(msecToWaitBeforeFrame,
                Qt::PreciseTimer,
                this,
                &ControllerRenderingScheduler::frameRequested);
    } else {
        QCoreApplication::postEvent(this, new QEvent(QEvent::UpdateRequest));
    }
}

bool ControllerRenderingScheduler::event(QEvent* event) {
    if (event->type() == QEvent::UpdateRequest) {
        emit frameRequested();
        return true;
    }

    return QObject::event(event);
}
