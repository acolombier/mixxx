#include "qml/qmlwaveformrenderer.h"

#include "moc_qmlwaveformrenderer.cpp"
#include "util/assert.h"
#include "waveform/renderers/allshader/waveformrenderbeat.h"
#include "waveform/renderers/allshader/waveformrendererendoftrack.h"
#include "waveform/renderers/allshader/waveformrendererpreroll.h"
#include "waveform/renderers/allshader/waveformrendererrgb.h"
#ifdef __STEM__
#include "waveform/renderers/allshader/waveformrendererstem.h"
#endif
#include "waveform/renderers/allshader/waveformrendermark.h"
#include "waveform/renderers/allshader/waveformrendermarkrange.h"

namespace mixxx {
namespace qml {

QmlWaveformRendererMark::QmlWaveformRendererMark()
        : m_defaultMark(nullptr),
          m_untilMark(std::make_unique<QmlWaveformUntilMark>()) {
}

QmlWaveformRendererFactory::Renderer QmlWaveformRendererEndOfTrack::create(
        WaveformWidgetRenderer* waveformWidget) const {
    auto* pRenderer = new allshader::WaveformRendererEndOfTrack(waveformWidget);

    pRenderer->setColor(m_color);
    pRenderer->setEndOfTrackWarningTime(m_endOfTrackWarningTime);
    connect(this,
            &QmlWaveformRendererEndOfTrack::colorChanged,
            pRenderer,
            &allshader::WaveformRendererEndOfTrack::setColor);
    connect(this,
            &QmlWaveformRendererEndOfTrack::endOfTrackWarningTimeChanged,
            pRenderer,
            &allshader::WaveformRendererEndOfTrack::setEndOfTrackWarningTime);
    return QmlWaveformRendererFactory::Renderer{pRenderer, pRenderer};
}

QmlWaveformRendererFactory::Renderer QmlWaveformRendererPreroll::create(
        WaveformWidgetRenderer* waveformWidget) const {
    auto* pRenderer = new allshader::WaveformRendererPreroll(
            waveformWidget, m_position);
    pRenderer->setColor(m_color);
    connect(this,
            &QmlWaveformRendererPreroll::colorChanged,
            pRenderer,
            &allshader::WaveformRendererPreroll::setColor);
    return QmlWaveformRendererFactory::Renderer{pRenderer, pRenderer};
}

QmlWaveformRendererFactory::Renderer QmlWaveformRendererRGB::create(
        WaveformWidgetRenderer* waveformWidget) const {
    auto* pRenderer = new allshader::WaveformRendererRGB(waveformWidget, m_position, m_options);

    pRenderer->setAxesColor(m_axesColor);
    pRenderer->setLowColor(m_lowColor);
    pRenderer->setMidColor(m_midColor);
    pRenderer->setHighColor(m_highColor);
    connect(this,
            &QmlWaveformRendererRGB::axesColorChanged,
            pRenderer,
            &allshader::WaveformRendererRGB::setAxesColor);
    connect(this,
            &QmlWaveformRendererRGB::lowColorChanged,
            pRenderer,
            &allshader::WaveformRendererRGB::setLowColor);
    connect(this,
            &QmlWaveformRendererRGB::midColorChanged,
            pRenderer,
            &allshader::WaveformRendererRGB::setMidColor);
    connect(this,
            &QmlWaveformRendererRGB::highColorChanged,
            pRenderer,
            &allshader::WaveformRendererRGB::setHighColor);

    pRenderer->setAllChannelVisualGain(m_gainAll);
    pRenderer->setLowVisualGain(m_gainLow);
    pRenderer->setMidVisualGain(m_gainMid);
    pRenderer->setHighVisualGain(m_gainHigh);
    connect(this,
            &QmlWaveformRendererRGB::gainAllChanged,
            pRenderer,
            &allshader::WaveformRendererRGB::setAllChannelVisualGain);
    connect(this,
            &QmlWaveformRendererRGB::gainLowChanged,
            pRenderer,
            &allshader::WaveformRendererRGB::setLowVisualGain);
    connect(this,
            &QmlWaveformRendererRGB::gainMidChanged,
            pRenderer,
            &allshader::WaveformRendererRGB::setMidVisualGain);
    connect(this,
            &QmlWaveformRendererRGB::gainHighChanged,
            pRenderer,
            &allshader::WaveformRendererRGB::setHighVisualGain);
    return QmlWaveformRendererFactory::Renderer{pRenderer, pRenderer};
}

QmlWaveformRendererFactory::Renderer QmlWaveformRendererBeat::create(
        WaveformWidgetRenderer* waveformWidget) const {
    auto* pRenderer = new allshader::WaveformRenderBeat(
            waveformWidget, m_position);
    pRenderer->setColor(m_color);
    connect(this,
            &QmlWaveformRendererBeat::colorChanged,
            pRenderer,
            &allshader::WaveformRenderBeat::setColor);
    return QmlWaveformRendererFactory::Renderer{pRenderer, pRenderer};
}

QmlWaveformRendererFactory::Renderer QmlWaveformRendererMarkRange::create(
        WaveformWidgetRenderer* waveformWidget) const {
    auto* pRenderer = new allshader::WaveformRenderMarkRange(
            waveformWidget);

    for (auto* pMark : std::as_const(m_ranges)) {
        pRenderer->addRange(WaveformMarkRange(
                waveformWidget->getGroup(),
                pMark->color(),
                pMark->disabledColor(),
                pMark->opacity(),
                pMark->disabledOpacity(),
                pMark->durationTextColor(),
                pMark->startControl(),
                pMark->endControl(),
                pMark->enabledControl(),
                pMark->visibilityControl(),
                pMark->durationTextLocation()));
    }
    return QmlWaveformRendererFactory::Renderer{pRenderer, pRenderer};
}

#ifdef __STEM__
QmlWaveformRendererFactory::Renderer QmlWaveformRendererStem::create(
        WaveformWidgetRenderer* waveformWidget) const {
    auto* pRenderer = new allshader::WaveformRendererStem(
            waveformWidget, m_position);

    pRenderer->setAllChannelVisualGain(m_gainAll);
    pRenderer->setSplitStemTracks(m_splitStemTracks);
    connect(this,
            &QmlWaveformRendererStem::gainAllChanged,
            pRenderer,
            &allshader::WaveformRendererStem::setAllChannelVisualGain);
    connect(this,
            &QmlWaveformRendererStem::splitStemTracksChanged,
            pRenderer,
            &allshader::WaveformRendererStem::setSplitStemTracks);
    return QmlWaveformRendererFactory::Renderer{pRenderer, pRenderer};
}
#endif

QmlWaveformRendererFactory::Renderer QmlWaveformRendererMark::create(
        WaveformWidgetRenderer* waveformWidget) const {
    VERIFY_OR_DEBUG_ASSERT(!!m_untilMark) {
        return QmlWaveformRendererFactory::Renderer{};
    }
    auto* pRenderer = new allshader::WaveformRenderMark(waveformWidget,
            ::WaveformRendererAbstract::Play);

    pRenderer->setPlayMarkerForegroundColor(m_playMarkerColor);
    pRenderer->setPlayMarkerBackgroundColor(m_playMarkerBackground);

    pRenderer->setUntilMarkShowBeats(m_untilMark->showTime());
    pRenderer->setUntilMarkShowTime(m_untilMark->showBeats());
    pRenderer->setUntilMarkAlign(m_untilMark->align());
    pRenderer->setUntilMarkTextSize(m_untilMark->textSize());
    pRenderer->setUntilMarkTextHeightLimit(m_untilMark->textHeightLimit());

    connect(m_untilMark.get(),
            &QmlWaveformUntilMark::showTimeChanged,
            pRenderer,
            &allshader::WaveformRenderMark::setUntilMarkShowTime);
    connect(m_untilMark.get(),
            &QmlWaveformUntilMark::showBeatsChanged,
            pRenderer,
            &allshader::WaveformRenderMark::setUntilMarkShowBeats);
    connect(m_untilMark.get(),
            &QmlWaveformUntilMark::alignChanged,
            pRenderer,
            &allshader::WaveformRenderMark::setUntilMarkAlign);
    connect(m_untilMark.get(),
            &QmlWaveformUntilMark::textSizeChanged,
            pRenderer,
            &allshader::WaveformRenderMark::setUntilMarkTextSize);

    connect(this,
            &QmlWaveformRendererMark::playMarkerColorChanged,
            pRenderer,
            &allshader::WaveformRenderMark::setPlayMarkerForegroundColor);
    connect(this,
            &QmlWaveformRendererMark::playMarkerBackgroundChanged,
            pRenderer,
            &allshader::WaveformRenderMark::setPlayMarkerBackgroundColor);

    // The initialisation is closely inspired from WaveformMarkSet::setup
    int priority = 0;
    for (const auto* pMark : std::as_const(m_marks)) {
        pRenderer->addMark(WaveformMarkPointer(new WaveformMark(
                waveformWidget->getGroup(),
                pMark->control(),
                pMark->visibilityControl(),
                pMark->textColor(),
                pMark->align(),
                pMark->text(),
                pMark->pixmap(),
                pMark->icon(),
                pMark->color(),
                priority)));
        priority--;
    }
    const auto* pMark = defaultMark();
    if (pMark != nullptr) {
        pRenderer->setDefaultMark(
                waveformWidget->getGroup(),
                WaveformMarkSet::DefaultMarkerStyle{
                        pMark->control(),
                        pMark->visibilityControl(),
                        pMark->textColor(),
                        pMark->align(),
                        pMark->text(),
                        pMark->pixmap(),
                        pMark->icon(),
                        pMark->color(),
                });
    }
    return QmlWaveformRendererFactory::Renderer{pRenderer, pRenderer};
}
} // namespace qml
} // namespace mixxx
