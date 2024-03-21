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
  private:
    QWaitCondition m_isPausedCondition;
    QMutex m_pauseMutex;
    bool m_isPaused{false};
    bool m_canPause{false};

  public slots:
    bool pause();
    void resume();
    /// Pause the controller engine's thread. Pause is required by rendering
    /// thread (https://doc.qt.io/qt-6/qquickrendercontrol.html#sync). This
    /// allows childrend classes to control whether or not they can be requested
    /// to pause the Controller thread used a "GUI thread" for onboard screens
    void setCanPause(bool canPause);
  private slots:
    void doPause();

  signals:
    void pauseRequested();
    void paused(bool);
#endif

  private:
    bool touchIsRightButton();
    void registerMetaTypes();

    int m_rightPressedButtons;
    ControlProxy* m_pTouchShift;

};
