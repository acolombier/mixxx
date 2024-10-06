#include "waveform/renderers/allshader/waveformrendererendoftrack.h"

#include <QDomNode>
#include <QSGNode>
#include <QVector4D>
#include <memory>

#include "control/controlproxy.h"
#include "rendergraph/geometry.h"
#include "rendergraph/material/rgbamaterial.h"
#include "rendergraph/vertexupdaters/rgbavertexupdater.h"
#include "util/colorcomponents.h"
#include "waveform/renderers/waveformwidgetrenderer.h"
#include "waveform/waveformwidgetfactory.h"
#include "widget/wskincolor.h"

namespace {

constexpr int kBlinkingPeriodMillis = 1000;

} // anonymous namespace

using namespace rendergraph;

namespace allshader {

WaveformRendererEndOfTrack::WaveformRendererEndOfTrack(
        WaveformWidgetRenderer* waveformWidget, QColor color)
        : ::WaveformRendererAbstract(waveformWidget),
          m_pEndOfTrackControl(nullptr),
          m_pTimeRemainingControl(nullptr),
          m_color(color) {
    initForRectangles<RGBAMaterial>(0);
    setUsePreprocess(true);
}

void WaveformRendererEndOfTrack::draw(QPainter* painter, QPaintEvent* event) {
    Q_UNUSED(painter);
    Q_UNUSED(event);
    DEBUG_ASSERT(false);
}

bool WaveformRendererEndOfTrack::init() {
    m_timer.restart();

    return true;
}

void WaveformRendererEndOfTrack::setup(const QDomNode& node, const SkinContext& context) {
    m_color = QColor(200, 25, 20);
    const QString endOfTrackColorName = context.selectString(node, "EndOfTrackColor");
    if (!endOfTrackColorName.isNull()) {
        m_color = QColor(endOfTrackColorName);
        m_color = WSkinColor::getCorrectColor(m_color);
    }
}

void WaveformRendererEndOfTrack::preprocess() {
    if (!m_pEndOfTrackControl) {
        m_pEndOfTrackControl = std::make_unique<ControlProxy>(
                m_waveformRenderer->getGroup(), "end_of_track");
    }
    if (!m_pTimeRemainingControl) {
        m_pTimeRemainingControl = std::make_unique<ControlProxy>(
                m_waveformRenderer->getGroup(), "time_remaining");
    }

    static int offset = 0;
    const int elapsedTotal = m_timer.elapsed().toIntegerMillis();
    const int elapsed = (elapsedTotal + offset) % kBlinkingPeriodMillis;

    // for testing
    offset = (offset == 0) ? kBlinkingPeriodMillis / 4 : 0;

    if (elapsedTotal >= m_lastFrameCountLogged + 1000) {
        if (elapsedTotal >= m_lastFrameCountLogged + 2000) {
            m_lastFrameCountLogged = elapsedTotal;
        }
        m_lastFrameCountLogged += 1000;
        qDebug() << "FPS:" << m_frameCount;
        m_frameCount = 0;
    }
    m_frameCount++;

    const double blinkIntensity = (double)(2 * abs(elapsed - kBlinkingPeriodMillis / 2)) /
            kBlinkingPeriodMillis;

    const double remainingTime = m_pTimeRemainingControl->get();
    const double remainingTimeTriggerSeconds =
            WaveformWidgetFactory::instance()->getEndOfTrackWarningTime();
    const double criticalIntensity = static_cast<double>(elapsed) /
            static_cast<double>(
                    kBlinkingPeriodMillis); // TODO put back:
                                            //(remainingTimeTriggerSeconds -
                                            //  remainingTime) /
                                            //  remainingTimeTriggerSeconds;

    const double alpha = std::max(0.0, std::min(1.0, criticalIntensity * blinkIntensity));

    bool forceSetUniformMatrix = false;

    if (alpha != 0.0) {
        const QSizeF& size = m_waveformRenderer->getSize();
        float r, g, b, a;
        getRgbF(m_color, &r, &g, &b, &a);

        const float posx0 = 0.f;
        const float posx1 = size.width() / 2.f;
        const float posx2 = size.width();
        const float posy1 = 0.f;
        const float posy2 = size.height();

        float minAlpha = 0.5f * static_cast<float>(alpha);
        float maxAlpha = 0.83f * static_cast<float>(alpha);

        // force setting the uniform matrix if we start drawing
        // after not drawing.
        forceSetUniformMatrix = geometry().vertexCount() == 0;

        geometry().allocate(6 * 2);
        RGBAVertexUpdater vertexUpdater{geometry().vertexDataAs<Geometry::RGBAColoredPoint2D>()};
        vertexUpdater.addRectangleHGradient(
                {posx0, posy1}, {posx1, posy2}, {r, g, b, minAlpha}, {r, g, b, minAlpha});
        vertexUpdater.addRectangleHGradient(
                {posx1, posy1}, {posx2, posy2}, {r, g, b, minAlpha}, {r, g, b, maxAlpha});

        markDirtyGeometry();
    } else if (geometry().vertexCount() != 0) {
        geometry().allocate(0);
        markDirtyGeometry();
    }
    if (m_waveformRenderer->getMatrixChanged() || forceSetUniformMatrix) {
        const QMatrix4x4 matrix = m_waveformRenderer->getMatrix(false);
        material().setUniform(0, matrix);
        markDirtyMaterial();
    }
}

bool WaveformRendererEndOfTrack::isSubtreeBlocked() const {
    // TODO put back
    return false;
    // return !(!m_pEndOfTrackControl || m_pEndOfTrackControl->toBool());
}

} // namespace allshader
