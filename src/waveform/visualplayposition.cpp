#include "waveform/visualplayposition.h"

#include <QtDebug>

#include "control/controlobject.h"
#include "control/controlproxy.h"
#include "moc_visualplayposition.cpp"
#include "util/math.h"
#include "waveform/isynctimeprovider.h"

namespace {
// The offset is limited to two callback intervals.
// This should be sufficient to compensate jitter,
// but does not continue in case of underflows.
constexpr int kMaxOffsetBufferCnt = 2;
constexpr int kMicrosPerMillis = 1000; // 1 ms contains 1000 µs
} // anonymous namespace


//static
QMap<QString, QWeakPointer<VisualPlayPosition>> VisualPlayPosition::m_listVisualPlayPosition;
PerformanceTimer VisualPlayPosition::m_timeInfoTime;
double VisualPlayPosition::m_dCallbackEntryToDacSecs = 0;

VisualPlayPosition::VisualPlayPosition(const QString& key)
        : m_valid(false),
          m_key(key),
          m_smoother(0.1, 60.0) // TODO @m0dB framerate should not be hardcoded
{
    m_audioBufferSize = new ControlProxy(
            "[Master]", "audio_buffer_size", this);
    m_audioBufferSize->connectValueChanged(this, &VisualPlayPosition::slotAudioBufferSizeChanged);
    m_audioBufferMicros = static_cast<int>(m_audioBufferSize->get() * kMicrosPerMillis);
}

VisualPlayPosition::~VisualPlayPosition() {
    m_listVisualPlayPosition.remove(m_key);
}

void VisualPlayPosition::set(double playPos, double rate, double positionStep,
        double slipPosition, double tempoTrackSeconds) {
    VisualPlayPositionData data;
    data.m_referenceTime = m_timeInfoTime;
    data.m_callbackEntrytoDac = static_cast<int>(m_dCallbackEntryToDacSecs * 1000000); // s to µs
    data.m_enginePlayPos = playPos;
    data.m_rate = rate;
    data.m_positionStep = positionStep;
    data.m_slipPosition = slipPosition;
    data.m_tempoTrackSeconds = tempoTrackSeconds;

    // when the play pos jump more than twice the amount of normal playback, we change immediately,
    // without smoothing
    // TODO m0dB don't use hardcoded framerate of 60
    m_smoother.setThreshold(2. * (1. / 60.) / tempoTrackSeconds);

    // Atomic write
    m_data.setValue(data);
    m_valid = true;
}

double VisualPlayPosition::getAtNextVSync(ISyncTimeProvider* syncTimeProvider) {
    //static double testPos = 0;
    //testPos += 0.000017759; //0.000016608; //  1.46257e-05;
    //return testPos;

    if (m_valid) {
        VisualPlayPositionData data = m_data.getValue();
        int refToVSync = syncTimeProvider->fromTimerToNextSyncMicros(data.m_referenceTime);
        int offset = refToVSync - data.m_callbackEntrytoDac;
        offset = math_min(offset, m_audioBufferMicros * kMaxOffsetBufferCnt);
        double playPos = data.m_enginePlayPos;  // load playPos for the first sample in Buffer
        // add the offset for the position of the sample that will be transferred to the DAC
        // When the next display frame is displayed
        playPos += data.m_positionStep * offset * data.m_rate / m_audioBufferMicros;

        //qDebug() << "playPos" << playPos << offset;
        return m_smoother.process(playPos);
    }
    return -1;
}

void VisualPlayPosition::getPlaySlipAtNextVSync(
        ISyncTimeProvider* syncTimeProvider,
        double* pPlayPosition,
        double* pSlipPosition) {
    //static double testPos = 0;
    //testPos += 0.000017759; //0.000016608; //  1.46257e-05;
    //return testPos;

    if (m_valid) {
        VisualPlayPositionData data = m_data.getValue();
        int refToVSync = syncTimeProvider->fromTimerToNextSyncMicros(data.m_referenceTime);
        int offset = refToVSync - data.m_callbackEntrytoDac;
        offset = math_min(offset, m_audioBufferMicros * kMaxOffsetBufferCnt);
        double playPos = data.m_enginePlayPos;  // load playPos for the first sample in Buffer
        playPos += data.m_positionStep * offset * data.m_rate / m_audioBufferMicros;
        *pPlayPosition = playPos;
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

void VisualPlayPosition::slotAudioBufferSizeChanged(double sizeMillis) {
    m_audioBufferMicros = static_cast<int>(sizeMillis * kMicrosPerMillis);
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
