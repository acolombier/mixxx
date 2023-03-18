#pragma once

#include <QTime>
#include <QMap>
#include <QAtomicPointer>

#include "util/performancetimer.h"
#include "control/controlvalue.h"

class ControlProxy;
class ISyncTimeProvider;

// This class is for synchronizing the sound device DAC time with the waveforms, displayed on the
// graphic device, using the CPU time
//
// DAC: ------|--------------|-------|-------------------|-----------------------|-----
//            ^Audio Callback Entry  |                   |                       ^Last Sample to DAC
//            |              ^Buffer prepared            ^Waveform sample X
//            |                      ^First sample transferred to DAC
// CPU: ------|-------------------------------------------------------------------------
//            ^Start m_timeInfoTime                      |
//                                                       |
// GPU: ---------|----------------------------------- |--|-------------------------------
//               ^Render Waveform sample X            |  ^VSync (New waveform is displayed
//                by use usFromTimerToNextSync        ^swap Buffer

class VisualPlayPositionData {
  public:
    PerformanceTimer m_referenceTime;
    int m_callbackEntrytoDac; // Time from Audio Callback Entry to first sample of Buffer is transferred to DAC
    double m_enginePlayPos; // Play position of fist Sample in Buffer
    double m_rate;
    double m_positionStep;
    double m_slipPosition;
    double m_tempoTrackSeconds; // total track time, taking the current tempo into account
    double m_audioBufferMicroS;
};


class VisualPlayPosition : public QObject {
    Q_OBJECT
  public:
    VisualPlayPosition(const QString& m_key);
    virtual ~VisualPlayPosition();

    // WARNING: Not thread safe. This function must be called only from the
    // engine thread.
    void set(
            double playPos,
            double rate,
            double positionStep,
            double slipPosition,
            double tempoTrackSeconds,
            double audioBufferMicroS);
    double getAtNextVSync(ISyncTimeProvider* syncTimeProvider);
    void getPlaySlipAtNextVSync(ISyncTimeProvider* syncTimeProvider,
            double* playPosition,
            double* slipPosition);
    double getEnginePlayPos();
    void getTrackTime(double* pPlayPosition, double* pTempoTrackSeconds);

    // WARNING: Not thread safe. This function must only be called from the main
    // thread.
    static QSharedPointer<VisualPlayPosition> getVisualPlayPosition(const QString& group);

    // This is called by SoundDevicePortAudio just after the callback starts.
    static void setCallbackEntryToDacSecs(double secs, const PerformanceTimer& time);

    void setInvalid() { m_valid = false; };
    bool isValid() const {
        return m_valid;
    }

  private:
    double calcPosAtNextVSync(ISyncTimeProvider* pVSyncThread, const VisualPlayPositionData& data);
    ControlValueAtomic<VisualPlayPositionData> m_data;
    bool m_valid;
    QString m_key;

    class Smoother {
      public: // TODO @m0dB make private
        double m_a, m_b, m_y, m_threshold;

      public:
        Smoother(double responseTime, double rate);
        double process(double x);
        void setThreshold(double threshold);
    };

    Smoother m_smoother;

    static QMap<QString, QWeakPointer<VisualPlayPosition>> m_listVisualPlayPosition;
    // Time info from the Sound device, updated just after audio callback is called
    static double m_dCallbackEntryToDacSecs;
    // Time stamp for m_timeInfo in main CPU time
    static PerformanceTimer m_timeInfoTime;
};
