#include "qml/qmlwaveformdisplay.h"

#include <QQuickWindow>
#include <QSGSimpleRectNode>
#include <QSGVertexColorMaterial>
#include <cmath>

#include "mixer/basetrackplayer.h"
#include "qml/qmlplayerproxy.h"
#include "waveform/renderers/waveformdisplayrange.h"

namespace mixxx {
namespace qml {

QmlWaveformDisplay::QmlWaveformDisplay(QQuickItem* parent)
        : QQuickItem(parent),
          m_pPlayer(nullptr) {
    setFlag(QQuickItem::ItemHasContents, true);

    connect(this, &QmlWaveformDisplay::windowChanged, this, &QmlWaveformDisplay::slotWindowChanged);
}

QmlWaveformDisplay::~QmlWaveformDisplay() {
    delete m_pWaveformDisplayRange;
}

void QmlWaveformDisplay::slotWindowChanged(QQuickWindow* window) {
    connect(window, &QQuickWindow::frameSwapped, this, &QmlWaveformDisplay::slotFrameSwapped);
    m_timer.restart();
}

int QmlWaveformDisplay::fromTimerToNextSyncMicros(const PerformanceTimer& timer) {
    // TODO @m0dB Might probably better to use a singleton instead of deriving QmlWaveformDisplay from
    // ISyncTimeProvider and have each keep track of this.
    int difference = static_cast<int>(m_timer.difference(timer).toIntegerMicros());
    // int math is fine here, because we do not expect times > 4.2 s

    return difference + 1000000 / 60;
}

void QmlWaveformDisplay::slotFrameSwapped() {
    m_timer.restart();
}

inline uint32_t fixedpoint_pow2(uint32_t x) {
    return (x * x) >> 16;
}

inline uint32_t math_max_u32(uint32_t a, uint32_t b, uint32_t c) {
    return std::max(a, std::max(b, c));
}

QSGNode* QmlWaveformDisplay::updatePaintNode(QSGNode* old, QQuickItem::UpdatePaintNodeData*) {
    // TODO
    uint32_t m_rgbLowColor_r = 255;
    uint32_t m_rgbMidColor_r = 0;
    uint32_t m_rgbHighColor_r = 0;
    uint32_t m_rgbLowColor_g = 0;
    uint32_t m_rgbMidColor_g = 255;
    uint32_t m_rgbHighColor_g = 0;
    uint32_t m_rgbLowColor_b = 0;
    uint32_t m_rgbMidColor_b = 0;
    uint32_t m_rgbHighColor_b = 255;

    auto* bgNode = dynamic_cast<QSGSimpleRectNode*>(old);

    if (m_pWaveformDisplayRange == nullptr) {
        return bgNode;
    }

    if (!m_pCurrentTrack) {
        return bgNode;
    }

    ConstWaveformPointer waveform = m_pCurrentTrack->getWaveform();
    if (waveform.isNull()) {
        return bgNode;
    }

    const int dataSize = waveform->getDataSize();
    if (dataSize <= 1) {
        return bgNode;
    }

    const WaveformData* data = waveform->data();
    if (data == nullptr) {
        return bgNode;
    }

    m_pWaveformDisplayRange->resize(static_cast<int>(width() * window()->devicePixelRatio()),
            static_cast<int>(height() * window()->devicePixelRatio()),
            window()->devicePixelRatio());
    // this as ISyncTimeProvider
    m_pWaveformDisplayRange->onPreRender(this);

    QSGGeometry* geometry;
    QSGGeometryNode* geometryNode;
    QSGVertexColorMaterial* material;
    if (!bgNode) {
        bgNode = new QSGSimpleRectNode();
        geometryNode = new QSGGeometryNode();

        geometry = new QSGGeometry(QSGGeometry::defaultAttributes_ColoredPoint2D(), 0);
        geometry->setDrawingMode(QSGGeometry::DrawLines);
        geometryNode->setGeometry(geometry);
        geometryNode->setFlag(QSGNode::OwnsGeometry);

        material = new QSGVertexColorMaterial();
        geometryNode->setMaterial(material);
        geometryNode->setFlag(QSGNode::OwnsMaterial);
        bgNode->appendChildNode(geometryNode);
    } else {
        geometryNode = dynamic_cast<QSGGeometryNode*>(bgNode->childAtIndex(0));
        material = dynamic_cast<QSGVertexColorMaterial*>(geometryNode->material());
        geometry = geometryNode->geometry();
    }
    bgNode->setRect(QRect(0, 0, static_cast<int>(width()), static_cast<int>(height())));
    bgNode->setColor(QColor(0, 0, 0));

    const float devicePixelRatio = m_pWaveformDisplayRange->getDevicePixelRatio();
    const float invDevicePixelRatio = 1.f / devicePixelRatio;

    int n = static_cast<int>(static_cast<float>(m_pWaveformDisplayRange->getLength()));

    geometry->allocate(n * 2);

    QSGGeometry::ColoredPoint2D* vertices = geometry->vertexDataAsColoredPoint2D();

    const double firstVisualIndex = m_pWaveformDisplayRange->getFirstDisplayedPosition() * dataSize;
    const double lastVisualIndex = m_pWaveformDisplayRange->getLastDisplayedPosition() * dataSize;

    // Represents the # of waveform data points per horizontal pixel.
    const double gain = (lastVisualIndex - firstVisualIndex) / static_cast<double>(n);

    // Per-band gain from the EQ knobs.
    float allGain(1.0), lowGain(1.0), midGain(1.0), highGain(1.0);
    //getGains(&allGain, &lowGain, &midGain, &highGain);

    uint32_t iLowGain(static_cast<uint32_t>(lowGain * 255));
    uint32_t iMidGain(static_cast<uint32_t>(midGain * 255));
    uint32_t iHighGain(static_cast<uint32_t>(highGain * 255));

    const float breadth =
            static_cast<float>(m_pWaveformDisplayRange->getBreadth()) /
            devicePixelRatio;
    const float halfBreadth = breadth / 2.0f;

    const float heightFactor = allGain * halfBreadth / std::sqrt(255.f * 255.f * 3.f);

    // Draw reference line
    //painter->setPen(m_pColors->getAxesColor());
    //painter->drawLine(QLineF(0, halfBreadth, n, halfBreadth));

    // Effective visual index of x
    double xVisualSampleIndex = firstVisualIndex;

    int j = 0;
    for (int x = 0; x < n; ++x) {
        // Our current pixel (x) corresponds to a number of visual samples
        // (visualSamplerPerPixel) in our waveform object. We take the max of
        // all the data points on either side of xVisualSampleIndex within a
        // window of 'maxSamplingRange' visual samples to measure the maximum
        // data point contained by this pixel.
        double maxSamplingRange = gain / 2.0;

        // Since xVisualSampleIndex is in visual-samples (e.g. R,L,R,L) we want
        // to check +/- maxSamplingRange frames, not samples. To do this, divide
        // xVisualSampleIndex by 2. Since frames indices are integers, we round
        // to the nearest integer by adding 0.5 before casting to int.
        int visualFrameStart = int(xVisualSampleIndex / 2.0 - maxSamplingRange + 0.5);
        int visualFrameStop = int(xVisualSampleIndex / 2.0 + maxSamplingRange + 0.5);
        const int lastVisualFrame = dataSize / 2 - 1;

        // We now know that some subset of [visualFrameStart, visualFrameStop]
        // lies within the valid range of visual frames. Clamp
        // visualFrameStart/Stop to within [0, lastVisualFrame].
        visualFrameStart = math_clamp(visualFrameStart, 0, lastVisualFrame);
        visualFrameStop = math_clamp(visualFrameStop, 0, lastVisualFrame);

        int visualIndexStart = visualFrameStart * 2;
        int visualIndexStop = visualFrameStop * 2;

        visualIndexStart = std::max(visualIndexStart, 0);
        visualIndexStop = std::min(visualIndexStop, dataSize);

        uint32_t maxLow = 0;
        uint32_t maxMid = 0;
        uint32_t maxHigh = 0;

        uint32_t maxAll = 0.;
        uint32_t maxAllNext = 0.;

        for (int i = visualIndexStart; i < visualIndexStop; i += 2) {
            const WaveformData& waveformData = data[i];
            const WaveformData& waveformDataNext = data[i + 1];

            maxLow = math_max_u32(maxLow, waveformData.filtered.low, waveformDataNext.filtered.low);
            maxMid = math_max_u32(maxMid, waveformData.filtered.mid, waveformDataNext.filtered.mid);
            maxHigh = math_max_u32(maxHigh,
                    waveformData.filtered.high,
                    waveformDataNext.filtered.high);

            uint32_t all = fixedpoint_pow2(waveformData.filtered.low * iLowGain) +
                    fixedpoint_pow2(waveformData.filtered.mid * iMidGain) +
                    fixedpoint_pow2(waveformData.filtered.high * iHighGain);
            maxAll = math_max(maxAll, all);

            uint32_t allNext = fixedpoint_pow2(waveformDataNext.filtered.low * iLowGain) +
                    fixedpoint_pow2(waveformDataNext.filtered.mid * iMidGain) +
                    fixedpoint_pow2(waveformDataNext.filtered.high * iHighGain);
            maxAllNext = math_max(maxAllNext, allNext);
        }

        maxLow *= iLowGain;
        maxMid *= iMidGain;
        maxHigh *= iHighGain;
        // these values are * 256

        uint32_t red = maxLow * m_rgbLowColor_r + maxMid * m_rgbMidColor_r +
                maxHigh * m_rgbHighColor_r;
        uint32_t green = maxLow * m_rgbLowColor_g + maxMid * m_rgbMidColor_g +
                maxHigh * m_rgbHighColor_g;
        uint32_t blue = maxLow * m_rgbLowColor_b + maxMid * m_rgbMidColor_b +
                maxHigh * m_rgbHighColor_b;
        // at this pint red, green, blue are * 65536

        // Compute maximum (needed for value normalization)
        uint32_t max = math_max3(red, green, blue);

        // A fixed point trick:
        //   max / (max>>8) == 256
        //   max / ((maxx>>8) + 1) = 255
        max >>= 8;

        if (max == 0) {
            red = 0;
            green = 0;
            blue = 0;
        } else {
            max++;
            red /= max;
            green /= max;
            blue /= max;
        }

        float fx = x * invDevicePixelRatio;
        vertices[j++].set(fx,
                halfBreadth - heightFactor * std::sqrt(maxAll),
                red,
                green,
                blue,
                255);
        vertices[j++].set(fx,
                halfBreadth + heightFactor * std::sqrt(maxAllNext),
                red,
                green,
                blue,
                255);

        xVisualSampleIndex += gain;
    }

    bgNode->markDirty(QSGNode::DirtyGeometry);
    geometryNode->markDirty(QSGNode::DirtyGeometry);
    update();

    return bgNode;
}

QmlPlayerProxy* QmlWaveformDisplay::getPlayer() const {
    return m_pPlayer;
}

void QmlWaveformDisplay::setPlayer(QmlPlayerProxy* pPlayer) {
    if (m_pPlayer == pPlayer) {
        return;
    }

    if (m_pPlayer != nullptr) {
        m_pPlayer->internalTrackPlayer()->disconnect(this);
    }

    m_pPlayer = pPlayer;

    if (pPlayer != nullptr) {
        connect(m_pPlayer->internalTrackPlayer(),
                &BaseTrackPlayer::newTrackLoaded,
                this,
                &QmlWaveformDisplay::slotTrackLoaded);
        connect(m_pPlayer->internalTrackPlayer(),
                &BaseTrackPlayer::loadingTrack,
                this,
                &QmlWaveformDisplay::slotTrackLoading);
        connect(m_pPlayer->internalTrackPlayer(),
                &BaseTrackPlayer::playerEmpty,
                this,
                &QmlWaveformDisplay::slotTrackUnloaded);
    }

    emit playerChanged(m_pPlayer);

    update();
}

void QmlWaveformDisplay::setGroup(const QString& group) {
    if (m_group == group) {
        return;
    }

    m_group = group;
    emit groupChanged(group);

    // TODO m0dB unique_ptr ?
    delete m_pWaveformDisplayRange;
    m_pWaveformDisplayRange = new WaveformDisplayRange(m_group);
    m_pWaveformDisplayRange->init();
}

const QString& QmlWaveformDisplay::getGroup() const {
    return m_group;
}

void QmlWaveformDisplay::slotTrackLoaded(TrackPointer pTrack) {
    // TODO: Investigate if it's a bug that this debug assertion fails when
    // passing tracks on the command line
    // DEBUG_ASSERT(m_pCurrentTrack == pTrack);
    setCurrentTrack(pTrack);
}

void QmlWaveformDisplay::slotTrackLoading(TrackPointer pNewTrack, TrackPointer pOldTrack) {
    Q_UNUSED(pOldTrack); // only used in DEBUG_ASSERT
    DEBUG_ASSERT(m_pCurrentTrack == pOldTrack);
    setCurrentTrack(pNewTrack);
}

void QmlWaveformDisplay::slotTrackUnloaded() {
    setCurrentTrack(nullptr);
}

void QmlWaveformDisplay::setCurrentTrack(TrackPointer pTrack) {
    // TODO: Check if this is actually possible
    if (m_pCurrentTrack == pTrack) {
        return;
    }

    if (m_pCurrentTrack != nullptr) {
        disconnect(m_pCurrentTrack.get(), nullptr, this, nullptr);
    }

    m_pCurrentTrack = pTrack;
    if (pTrack != nullptr) {
        connect(pTrack.get(),
                &Track::waveformSummaryUpdated,
                this,
                &QmlWaveformDisplay::slotWaveformUpdated);
    }
    slotWaveformUpdated();

    if (m_pWaveformDisplayRange) {
        m_pWaveformDisplayRange->setTrack(m_pCurrentTrack);
    }
}

void QmlWaveformDisplay::slotWaveformUpdated() {
    update();
}

} // namespace qml
} // namespace mixxx
