#include "qml/qmlwaveformdisplay.h"

#include <qnamespace.h>

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
#include <memory>

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


using namespace allshader;

namespace mixxx {
namespace qml {

QmlWaveformDisplay::QmlWaveformDisplay(QQuickItem* parent)
        : QQuickItem(parent),
          WaveformWidgetRenderer("[Channel1]"),
          m_pPlayer(nullptr),
          m_pZoom(std::make_unique<ControlProxy>(getGroup(),
                  "waveform_zoom",
                  this,
                  ControlFlag::NoAssertIfMissing)) {
    setFlag(QQuickItem::ItemHasContents, true);

    connect(this, &QmlWaveformDisplay::windowChanged, this, &QmlWaveformDisplay::slotWindowChanged, Qt::DirectConnection);
    m_pZoom->connectValueChanged(this, [this](double zoom) {
        setZoom(zoom);
    });
}

QmlWaveformDisplay::~QmlWaveformDisplay() {
    // The stack contains references to Renderer that are owned and cleared by a TreeNode
    m_rendererStack.clear();
}

void QmlWaveformDisplay::componentComplete() {
    qDebug() << "QmlWaveformDisplay ready for group" << getGroup() << "with"
             << m_waveformRenderers.count() << "renderer(s)";
    QQuickItem::componentComplete();
}

void QmlWaveformDisplay::slotWindowChanged(QQuickWindow* window) {
    qDebug() << "WINDOWS CHANGED!!";

    m_rendererStack.clear();

    m_dirtyFlag |= DirtyFlag::Window;
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
    // continuous redraw
    update();
}

void QmlWaveformDisplay::geometryChange(const QRectF& newGeometry, const QRectF& oldGeometry) {
    m_dirtyFlag |= DirtyFlag::Geometry;
    update();
    QQuickItem::geometryChange(newGeometry, oldGeometry);
}

// QSGNode* QmlWaveformDisplay::updatePaintNode(QSGNode* node, UpdatePaintNodeData*) {
//     // TODO the flag is not set when the position changes,
//     // but only when the size changes. Until we found a way
//     // to detect position changed, call setRect always
//     // (we check internally if the rect changed anyway)
//     //
//     // if (m_dirtyFlag.testFlag(DirtyFlag::Geometry)) {
//     //    m_dirtyFlag.setFlag(DirtyFlag::Geometry, false);
//     //    setRect(mapRectToScene(boundingRect()));
//     //}
//     setRect(mapRectToScene(boundingRect()));
//     setViewport(window()->size());
//     setDevicePixelRatio(window()->devicePixelRatio());

//     // Will recalculate the matrix if any of the above changed.
//     // Nodes can use getMatrixChanged() to check if the matrix
//     // has changed and take appropriate action.
//     updateMatrix();

//     auto* bgNode = dynamic_cast<QSGSimpleRectNode*>(node);
//     if (!bgNode) {
//         static int k = 0;
//         k++;
//         bgNode = new QSGSimpleRectNode();
//         bgNode->setRect(boundingRect());
//         bgNode->setColor(QColor((k & 1) ? 64 : 0, (k & 4) ? 64 : 0, (k & 2) ? 64 : 0, 255));

//         auto pEndOfTrackNode =
//                 std::make_unique<allshader_sg::WaveformRendererEndOfTrack>(
//                         this, QColor("yellow"));
//         pEndOfTrackNode->init();
//         bgNode->appendChildNode(pEndOfTrackNode->backendNode());

//         m_pEngine = std::make_unique<rendergraph::Engine>(std::move(pEndOfTrackNode));
//         m_pEngine->initialize();
//     }

//     return bgNode;
// }

QSGNode* QmlWaveformDisplay::updatePaintNode(QSGNode* node, UpdatePaintNodeData*) {
    setRect(mapRectToScene(boundingRect()));
    setViewport(window()->size());
    setDevicePixelRatio(window()->devicePixelRatio());
    auto* bgNode = dynamic_cast<QSGSimpleRectNode*>(node);
    static rendergraph::GeometryNode* pPreRoll;

    // updateMatrix();

    if (!bgNode || m_dirtyFlag.testFlag(DirtyFlag::Window)) {
        if (bgNode) {
            delete bgNode;
            m_dirtyFlag.setFlag(DirtyFlag::Window, false);
        }
        bgNode = new QSGSimpleRectNode();
        bgNode->setRect(boundingRect());

        if (getContext()){
            delete getContext();
        }
        setContext(new rendergraph::Context(window()));
        m_pTopNode = new rendergraph::Node;
        // auto pOpacityNode = std::make_unique<rendergraph::OpacityNode>();

        m_rendererStack.clear();
        for (auto* pQmlRenderer : m_waveformRenderers) {

            auto renderer = pQmlRenderer->create(this);
            addRenderer(renderer.renderer);
            // appendChildTo(pOpacityNode, renderer.node);
            m_pTopNode->appendChildNode(std::unique_ptr<rendergraph::TreeNode>(renderer.node));
        }

        // pTopNode->appendChildNode(std::move(pOpacityNode));
        bgNode->appendChildNode(m_pTopNode->backendNode());

        bgNode->setColor(QColor(0, 0, 0, 255));
        init();
    }

    if (m_dirtyFlag.testFlag(DirtyFlag::Geometry)) {
        m_dirtyFlag.setFlag(DirtyFlag::Geometry, false);
        bgNode->setRect(boundingRect());

        auto rect = QRectF(boundingRect().x() +
                        boundingRect().width() * m_playMarkerPosition - 1.0,
                boundingRect().y(),
                2.0,
                boundingRect().height());
    }
    onPreRender(this);
    bgNode->markDirty(QSGNode::DirtyForceUpdate);

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
    // TODO update group in parent class
    if (getGroup() == group) {
        return;
    }

    WaveformWidgetRenderer::setGroup(group);
    m_pZoom = std::make_unique<ControlProxy>(
            getGroup(), "waveform_zoom", this, ControlFlag::NoAssertIfMissing);
    m_pZoom->connectValueChanged(this, [this](double zoom) {
        setZoom(zoom);
    });
    emit groupChanged(group);

    // TODO m0dB unique_ptr ?
    // delete m_pWaveformDisplayRange;
    // m_pWaveformDisplayRange = new WaveformDisplayRange(m_group);
    // m_pWaveformDisplayRange->init();
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
    setTrack(pTrack);

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

QQmlListProperty<QmlWaveformRendererFactory> QmlWaveformDisplay::renderers() {
    return {this, &m_waveformRenderers};
}

} // namespace qml
} // namespace mixxx
