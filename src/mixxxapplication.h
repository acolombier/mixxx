#pragma once

#include <QApplication>
#ifdef MIXXX_USE_QML
#include <QWaitCondition>
#include <QMutex>
#endif

class ControlProxy;

class MixxxApplication : public QApplication {
    Q_OBJECT
  public:
    MixxxApplication(int& argc, char** argv);
    ~MixxxApplication() override = default;

#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    bool notify(QObject*, QEvent*) override;
#endif

#ifdef MIXXX_USE_QML
    /// Pause the GUI main thread. Pause is required by rendering
    /// thread (https://doc.qt.io/qt-6/qquickrendercontrol.html#sync). This
    /// offscreen render thread to pause the main "GUI thread" for onboard screens
  private:
    QWaitCondition m_isPausedCondition;
    QMutex m_pauseMutex;
    bool m_isPaused{false};
    bool m_canPause{false};

  public slots:
    bool pause();
    void resume();
    void setCanPause(bool canPause);
  private slots:
    void doPause();

  signals:
    void pauseRequested();
#endif

  private:
    bool touchIsRightButton();
    void registerMetaTypes();

    int m_rightPressedButtons;
    ControlProxy* m_pTouchShift;

};
