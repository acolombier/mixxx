#include "qml/qmlwaveformrenderer.h"

#include "moc_qmlwaveformrenderer.cpp"
#include "waveform/renderers/allshader/waveformrenderbeat.h"
#include "waveform/renderers/allshader/waveformrendererendoftrack.h"
#include "waveform/renderers/allshader/waveformrendererpreroll.h"
#include "waveform/renderers/allshader/waveformrendererrgb.h"

using namespace allshader;

namespace mixxx {
namespace qml {

QmlWaveformRendererEndOfTrack::QmlWaveformRendererEndOfTrack() {
}

QmlWaveformRendererPreroll::QmlWaveformRendererPreroll() {
}

QmlWaveformRendererRGB::QmlWaveformRendererRGB() {
}

QmlWaveformRendererBeat::QmlWaveformRendererBeat() {
}

QmlWaveformRendererFactory::Renderer QmlWaveformRendererEndOfTrack::create(
        WaveformWidgetRenderer* waveformWidget,
        rendergraph::Context context) const {
    Q_UNUSED(context);
    auto* renderer = new WaveformRendererEndOfTrack(waveformWidget, m_color);
    return QmlWaveformRendererFactory::Renderer{renderer, renderer};
}

QmlWaveformRendererFactory::Renderer QmlWaveformRendererPreroll::create(
        WaveformWidgetRenderer* waveformWidget,
        rendergraph::Context context) const {
    auto* renderer = new WaveformRendererPreroll(waveformWidget, context, m_color);
    return QmlWaveformRendererFactory::Renderer{renderer, renderer};
}

QmlWaveformRendererFactory::Renderer QmlWaveformRendererRGB::create(
        WaveformWidgetRenderer* waveformWidget,
        rendergraph::Context context) const {
    Q_UNUSED(context);
    auto* renderer = new WaveformRendererRGB(waveformWidget,
            m_axesColor,
            m_lowColor,
            m_midColor,
            m_highColor,
            ::WaveformRendererAbstract::Play);
    return QmlWaveformRendererFactory::Renderer{renderer, renderer};
}

QmlWaveformRendererFactory::Renderer QmlWaveformRendererBeat::create(
        WaveformWidgetRenderer* waveformWidget,
        rendergraph::Context context) const {
    Q_UNUSED(context);
    auto* renderer = new WaveformRenderBeat(
            waveformWidget, ::WaveformRendererAbstract::Play, m_color);
    return QmlWaveformRendererFactory::Renderer{renderer, renderer};
}
} // namespace qml
} // namespace mixxx
