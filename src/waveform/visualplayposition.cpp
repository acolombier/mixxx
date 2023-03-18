#include "waveform/visualplayposition.h"

#include <QtDebug>

#include "control/controlobject.h"
#include "control/controlproxy.h"
#include "moc_visualplayposition.cpp"
#include "util/math.h"
#include "waveform/isynctimeprovider.h"

//static
QMap<QString, QWeakPointer<VisualPlayPosition>> VisualPlayPosition::m_listVisualPlayPosition;
PerformanceTimer VisualPlayPosition::m_timeInfoTime;
double VisualPlayPosition::m_dCallbackEntryToDacSecs = 0;

VisualPlayPosition::VisualPlayPosition(const QString& key)
        : m_valid(false),
          m_key(key),
          m_smoother(0.1, 60.0) // TODO @m0dB framerate should not be hardcoded
{
}

VisualPlayPosition::~VisualPlayPosition() {
    m_listVisualPlayPosition.remove(m_key);
}

void VisualPlayPosition::set(
        double playPos,
        double rate,
        double positionStep,
        double slipPosition,
        double tempoTrackSeconds,
        double audioBufferMicroS) {
    VisualPlayPositionData data;
    data.m_referenceTime = m_timeInfoTime;
    data.m_callbackEntrytoDac = static_cast<int>(m_dCallbackEntryToDacSecs * 1000000); // s to µs
    data.m_enginePlayPos = playPos;
    data.m_rate = rate;
    data.m_positionStep = positionStep;
    data.m_slipPosition = slipPosition;
    data.m_tempoTrackSeconds = tempoTrackSeconds;
    data.m_audioBufferMicroS = audioBufferMicroS;

    // when the play pos jump more than twice the amount of normal playback, we change immediately,
    // without smoothing
    // TODO m0dB don't use hardcoded framerate of 60
    m_smoother.setThreshold(2. * (1. / 60.) / tempoTrackSeconds);

    // Atomic write
    m_data.setValue(data);
    m_valid = true;
}

double VisualPlayPosition::calcPosAtNextVSync(
        ISyncTimeProvider* pVSyncThread, const VisualPlayPositionData& data) {
    double playPos = data.m_enginePlayPos; // load playPos for the first sample in Buffer
    if (data.m_audioBufferMicroS != 0.0) {
        int refToVSync = pVSyncThread->fromTimerToNextSyncMicros(data.m_referenceTime);
        int syncIntervalTimeMicros = pVSyncThread->getSyncIntervalTimeMicros();
        int offset = refToVSync - data.m_callbackEntrytoDac;
        // The offset is limited to the audio buffer + waveform sync interval
        // This should be sufficient to compensate jitter, but does not continue
        // in case of underflows.
        int maxOffset = static_cast<int>(data.m_audioBufferMicroS + syncIntervalTimeMicros);
        offset = math_clamp(offset, -maxOffset, maxOffset);
        // add the offset for the position of the sample that will be transferred to the DAC
        // When the next display frame is displayed
        playPos += data.m_positionStep * offset * data.m_rate / data.m_audioBufferMicroS;
    }

    // qDebug() << "playPos" << playPos << offset;
    return m_smoother.process(playPos);
}

double VisualPlayPosition::getAtNextVSync(ISyncTimeProvider* pSyncTimeProvider) {
    if (m_valid) {
        VisualPlayPositionData data = m_data.getValue();
        return calcPosAtNextVSync(pSyncTimeProvider, data);
    }
    return -1;
}

void VisualPlayPosition::getPlaySlipAtNextVSync(ISyncTimeProvider* pSyncTimeProvider,
        double* pPlayPosition,
        double* pSlipPosition) {
    if (m_valid) {
        VisualPlayPositionData data = m_data.getValue();
        *pPlayPosition = calcPosAtNextVSync(pSyncTimeProvider, data);
        *pSlipPosition = data.m_slipPosition;
    }
}

double VisualPlayPosition::getEnginePlayPos() {
    if (m_valid) {
        VisualPlayPositionData data = m_data.getValue();
        return data.m_enginePlayPos;
    } else {
        return -1;
    }
}

void VisualPlayPosition::getTrackTime(double* pPlayPosition, double* pTempoTrackSeconds) {
    if (m_valid) {
        VisualPlayPositionData data = m_data.getValue();
        *pPlayPosition = data.m_enginePlayPos;
        *pTempoTrackSeconds = data.m_tempoTrackSeconds;
    } else {
        *pPlayPosition = 0;
        *pTempoTrackSeconds = 0;
    }
}

//static
QSharedPointer<VisualPlayPosition> VisualPlayPosition::getVisualPlayPosition(const QString& group) {
    QSharedPointer<VisualPlayPosition> vpp = m_listVisualPlayPosition.value(group);
    if (vpp.isNull()) {
        vpp = QSharedPointer<VisualPlayPosition>(new VisualPlayPosition(group));
        m_listVisualPlayPosition.insert(group, vpp);
    }
    return vpp;
}

//static
void VisualPlayPosition::setCallbackEntryToDacSecs(double secs, const PerformanceTimer& time) {
    // the time is valid only just NOW, so measure the time from NOW for
    // later correction
    m_timeInfoTime = time;
    m_dCallbackEntryToDacSecs = secs;
}

VisualPlayPosition::Smoother::Smoother(double responseTime, double rate)
        : m_a{std::exp(-(M_PI * 2.0) / (responseTime * rate))},
          m_b{1.0 - m_a},
          m_y{0.0},
          m_threshold{0.0} {
}

void VisualPlayPosition::Smoother::setThreshold(double threshold) {
    m_threshold = threshold;
}

double VisualPlayPosition::Smoother::process(double x) {
    if (std::abs(x - m_y) > m_threshold) {
        m_y = x;
    } else {
        m_y = (x * m_b) + (m_y * m_a);
    }
    return m_y;
}
