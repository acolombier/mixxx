#pragma once

#include <QApplication>
#include <QQmlApplicationEngine>

#include "coreservices.h"
#include "qmlautoreload.h"

class GuiTick;
class VisualsManager;
#if defined(Q_OS_ANDROID)
class QQuickWindow;
class APerformanceHintSession;
class AWorkDuration;
#endif

namespace mixxx {
namespace qml {

class QmlApplication : public QObject {
    Q_OBJECT
  public:
    QmlApplication(
            QApplication* app,
            const CmdlineArgs& args);
    ~QmlApplication() override;

  public slots:
    void loadQml(const QString& path);

#if defined(Q_OS_ANDROID)
  private slots:
    void slotFrameSwapped();
    void slotWindowChanged(QQuickWindow* window);
#endif

  private:
    std::unique_ptr<CoreServices> m_pCoreServices;
    std::unique_ptr<::VisualsManager> m_visualsManager;

    QString m_mainFilePath;

    std::unique_ptr<QQmlApplicationEngine> m_pAppEngine;
    QmlAutoReload m_autoReload;

#if defined(Q_OS_ANDROID)
    PerformanceTimer m_frameTimer;
    APerformanceHintSession* m_perfSession;
    AWorkDuration* m_frameDuration;
#endif
};

} // namespace qml
} // namespace mixxx
