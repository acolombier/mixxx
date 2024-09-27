#include "qml/qmlwaveformdisplay.h"

#include <QQuickWindow>
#include <QSGFlatColorMaterial>
#include <QSGSimpleRectNode>
#include <QSGVertexColorMaterial>
#include <QtQuick/QSGGeometryNode>
#include <QtQuick/QSGMaterial>
#include <QtQuick/QSGRectangleNode>
#include <QtQuick/QSGTexture>
#include <QtQuick/QSGTextureProvider>
#include <cmath>

#include "mixer/basetrackplayer.h"
#include "moc_qmlwaveformdisplay.cpp"
#include "qml/qmlplayerproxy.h"
#include "rendergraph/context.h"
#include "rendergraph/node.h"
#include "rendergraph/opacitynode.h"
#include "waveform/renderers/allshader/waveformrenderbeat.h"
#include "waveform/renderers/allshader/waveformrendererendoftrack.h"
// #include "waveform/renderers/allshader/waveformrendererfiltered.h"
// #include "waveform/renderers/allshader/waveformrendererhsv.h"
#include "waveform/renderers/allshader/waveformrendererpreroll.h"
#include "waveform/renderers/allshader/waveformrendererrgb.h"
// #include "waveform/renderers/allshader/waveformrenderersimple.h"
// #include "waveform/renderers/allshader/waveformrendererslipmode.h"
// #include "waveform/renderers/allshader/waveformrendererstem.h"
// #include "waveform/renderers/allshader/waveformrenderertextured.h"
#include "waveform/renderers/allshader/waveformrendermark.h"
#include "waveform/renderers/allshader/waveformrendermarkrange.h"
#include "waveform/renderers/waveformdisplayrange.h"

namespace {

// float to fixed point with 8 fractional bits, clipped at 4.0
uint32_t toFrac8(float x) {
    return std::min<uint32_t>(static_cast<uint32_t>(std::max(x, 0.f) * 256.f), 4 * 256);
}

constexpr size_t frac16sqrtTableSize{(3 * 4 * 255 * 256) / 16 + 1};

// scaled sqrt lookable table to convert maxAll and maxAllNext as calculated
// in updatePaintNode back to y coordinates
class Frac16SqrtTableSingleton {
  public:
    static Frac16SqrtTableSingleton& getInstance() {
        static Frac16SqrtTableSingleton instance;
        return instance;
    }

    inline float get(uint32_t x) const {
        // The maximum value of fact16x can be (as uint32_t) 3 * 4 * 255 * 256,
        // which would be exessive for the table size. We divide by 16 in order
        // to get a more reasonable size.
        return m_table[x >> 4];
    }

  private:
    float* m_table;
    Frac16SqrtTableSingleton()
            : m_table(new float[frac16sqrtTableSize]) {
        // In the original implementation, the result of sqrt(maxAll) is divided
        // by sqrt(3 * 255 * 255);
        // We get rid of that division and bake it into this table.
        // Additionally, we divide the index for the lookup by 16 (see get(...)),
        // so we need to invert that here.
        const float f = (3.f * 255.f * 255.f / 16.f);
        for (uint32_t i = 0; i < frac16sqrtTableSize; i++) {
            m_table[i] = std::sqrt(static_cast<float>(i) / f);
        }
    }
    ~Frac16SqrtTableSingleton() {
        delete[] m_table;
    }
    Frac16SqrtTableSingleton(const Frac16SqrtTableSingleton&) = delete;
    Frac16SqrtTableSingleton& operator=(const Frac16SqrtTableSingleton&) = delete;
};

inline float frac16_sqrt(uint32_t x) {
    return Frac16SqrtTableSingleton::getInstance().get(x);
}

void appendChildTo(std::unique_ptr<rendergraph::Node>& pNode, rendergraph::TreeNode* pChild) {
    pNode->appendChildNode(std::unique_ptr<rendergraph::TreeNode>(pChild));
}
void appendChildTo(std::unique_ptr<rendergraph::OpacityNode>& pNode,
        rendergraph::TreeNode* pChild) {
    pNode->appendChildNode(std::unique_ptr<rendergraph::TreeNode>(pChild));
}

} // namespace

using namespace allshader;

namespace mixxx {
namespace qml {

QmlWaveformDisplay::QmlWaveformDisplay(QQuickItem* parent)
        : QQuickItem(parent),
          WaveformWidgetRenderer("[Channel1]"),
          m_pPlayer(nullptr) {
    Frac16SqrtTableSingleton::getInstance(); // initializes table

    setFlag(QQuickItem::ItemHasContents, true);

    connect(this, &QmlWaveformDisplay::windowChanged, this, &QmlWaveformDisplay::slotWindowChanged);
}

QmlWaveformDisplay::~QmlWaveformDisplay() {
    // delete m_pWaveformDisplayRange;
}

void QmlWaveformDisplay::slotWindowChanged(QQuickWindow* window) {
    connect(window, &QQuickWindow::frameSwapped, this, &QmlWaveformDisplay::slotFrameSwapped);
    m_timer.restart();
}

int QmlWaveformDisplay::fromTimerToNextSyncMicros(const PerformanceTimer& timer) {
    // TODO @m0dB probably better to use a singleton instead of deriving QmlWaveformDisplay from
    // ISyncTimeProvider and have each keep track of this.
    int difference = static_cast<int>(m_timer.difference(timer).toIntegerMicros());
    // int math is fine here, because we do not expect times > 4.2 s

    return difference + m_syncIntervalTimeMicros;
}

void QmlWaveformDisplay::slotFrameSwapped() {
    m_timer.restart();
}

inline uint32_t frac8Pow2ToFrac16(uint32_t x) {
    // x is the result of multiplying two fixedpoint values with 8 fraction bits,
    // thus x has 16 fraction bits, which is also what we want to return for this
    // function. We would naively return (x * x) >> 16, but x * x would overflow
    // the 32 bits for values > 1, so we shift before multiplying.
    x >>= 8;
    return (x * x);
}

inline uint32_t math_max_u32(uint32_t a, uint32_t b) {
    return std::max(a, b);
}

inline uint32_t math_max_u32(uint32_t a, uint32_t b, uint32_t c) {
    return std::max(a, std::max(b, c));
}

void QmlWaveformDisplay::geometryChange(const QRectF& newGeometry, const QRectF& oldGeometry) {
    m_geometryChanged = true;
    update();
    QQuickItem::geometryChange(newGeometry, oldGeometry);
}

QSGNode* QmlWaveformDisplay::updatePaintNode(QSGNode* node, UpdatePaintNodeData*) {
    QSGRectangleNode* bgNode;
    if (!node) {
        bgNode = window()->createRectangleNode();
        bgNode->setColor(QColor(0, 0, 0, 64));
        bgNode->setRect(boundingRect());

#ifndef ADD_ALL_WAVEFORM_NODES
        m_waveformNode = std::make_unique<rendergraph::Node>();
        appendChildTo(m_waveformNode, addRenderer<WaveformRendererEndOfTrack>());
        bgNode->appendChildNode(m_waveformNode->backendNode());
#else
        // rendergraph::Context context(window());
        m_waveformNode = new rendergraph::Node();
        auto pOpacityNode = std::make_unique<rendergraph::OpacityNode>();

        // m_waveformNode = new WaveformRendererEndOfTrack(this);

        // appendChildTo(m_waveformNode, addRenderer<WaveformRenderBackground>());
        appendChildTo(pOpacityNode, addRenderer<WaveformRendererEndOfTrack>());
        appendChildTo(pOpacityNode, addRenderer<WaveformRendererPreroll>());
        // m_pWaveformRenderMarkRange = addRenderer<WaveformRenderMarkRange>();
        // appendChildTo(pOpacityNode, m_pWaveformRenderMarkRange);

        // #ifdef __STEM__
        //         // The following two renderers work in tandem: if the rendered waveform is
        //         // for a stem track, WaveformRendererSignalBase will skip rendering and let
        //         // WaveformRendererStem do the rendering, and vice-versa.
        //         appendChildTo(pOpacityNode, addRenderer<WaveformRendererStem>());
        // #endif
        // allshader::WaveformRendererSignalBase* waveformSignalRenderer =
        //         // addWaveformSignalRenderer(
        //         //         type, options, ::WaveformRendererAbstract::Play);
        //         addRenderer<WaveformRendererRGB>(::WaveformRendererAbstract::Play);

        // appendChildTo(pOpacityNode,
        // dynamic_cast<rendergraph::TreeNode*>(waveformSignalRenderer));

        // appendChildTo(pOpacityNode, addRenderer<WaveformRenderBeat>());
        // m_pWaveformRenderMark = addRenderer<WaveformRenderMark>();
        // appendChildTo(pOpacityNode, m_pWaveformRenderMark);

        // if the signal renderer supports slip, we add it again, now for slip, together with the
        // other slip renderers
        // if (waveformSignalRenderer && waveformSignalRenderer->supportsSlip()) {
        //     // The following renderer will add an overlay waveform if a slip is in progress
        //     appendChildTo(pOpacityNode, addRenderer<WaveformRendererSlipMode>());
        //     appendChildTo(pOpacityNode,
        //             addRenderer<WaveformRendererPreroll>(
        //                     ::WaveformRendererAbstract::Slip));
        // #ifdef __STEM__
        //     appendChildTo(pOpacityNode,
        //             addRenderer<WaveformRendererStem>(
        //                     ::WaveformRendererAbstract::Slip));
        // #endif
        //     appendChildTo(pOpacityNode,
        //             dynamic_cast<rendergraph::TreeNode*>(addWaveformSignalRenderer(
        //                     type, options, ::WaveformRendererAbstract::Slip)));
        //     appendChildTo(pOpacityNode,
        //             addRenderer<WaveformRenderBeat>(
        //                     ::WaveformRendererAbstract::Slip));
        //     appendChildTo(pOpacityNode,
        //             addRenderer<WaveformRenderMark>(
        //                     ::WaveformRendererAbstract::Slip));
        // }

        m_waveformNode->appendChildNode(std::move(pOpacityNode));
        bgNode->appendChildNode(m_waveformNode->backendNode());
#endif

        node = bgNode;
    } else {
        bgNode = static_cast<QSGRectangleNode*>(node);
    }
    // m_pOpacityNode->setOpacity(1.f);

    // m_pWaveformRenderMark->update();
    // m_pWaveformRenderMarkRange->update();

    // for (auto pRenderer : m_rendererStack) {
    //     auto pNode = reinterpret_cast<rendergraph::Node*>(pRenderer);
    //     if (!pNode->isSubtreeBlocked()) {
    //         pNode->preprocess();
    //     }
    // }

    if (m_geometryChanged) {
        bgNode->setRect(boundingRect());
        m_geometryChanged = false;
    }

    return node;
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

    if (m_pPlayer != nullptr) {
        setCurrentTrack(m_pPlayer->internalTrackPlayer()->getLoadedTrack());
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

    emit playerChanged();
    update();
}

void QmlWaveformDisplay::setGroup(const QString& group) {
    if (m_group == group) {
        return;
    }

    m_group = group;
    emit groupChanged(group);

    // TODO m0dB unique_ptr ?
    // delete m_pWaveformDisplayRange;
    // m_pWaveformDisplayRange = new WaveformDisplayRange(m_group);
    // m_pWaveformDisplayRange->init();
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

    // if (m_pWaveformDisplayRange) {
    //     m_pWaveformDisplayRange->setTrack(m_pCurrentTrack);
    // }
}

void QmlWaveformDisplay::slotWaveformUpdated() {
    update();
}

} // namespace qml
} // namespace mixxx
