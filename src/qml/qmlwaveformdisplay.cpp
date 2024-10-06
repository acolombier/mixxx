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
#include "rendergraph/engine.h"
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
          m_pPlayer(nullptr) {
    setFlag(QQuickItem::ItemHasContents, true);

    connect(this, &QmlWaveformDisplay::windowChanged, this, &QmlWaveformDisplay::slotWindowChanged);
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

QSGNode* QmlWaveformDisplay::updatePaintNode(QSGNode* node, UpdatePaintNodeData*) {
    // TODO the flag is not set when the position changes,
    // but only when the size changes. Until we found a way
    // to detect position changed, call setRect always
    // (we check internally if the rect changed anyway)
    //
    // if (m_dirtyFlag.testFlag(DirtyFlag::Geometry)) {
    //    m_dirtyFlag.setFlag(DirtyFlag::Geometry, false);
    //    setRect(mapRectToScene(boundingRect()));
    //}
    setRect(mapRectToScene(boundingRect()));
    setViewport(window()->size());
    setDevicePixelRatio(window()->devicePixelRatio());

    // Will recalculate the matrix if any of the above changed.
    // Nodes can use getMatrixChanged() to check if the matrix
    // has changed and take appropriate action.
    updateMatrix();

    auto* bgNode = dynamic_cast<QSGSimpleRectNode*>(node);
    if (!bgNode) {
        static int k = 0;
        k++;
        bgNode = new QSGSimpleRectNode();
        bgNode->setRect(boundingRect());
        bgNode->setColor(QColor((k & 1) ? 64 : 0, (k & 4) ? 64 : 0, (k & 2) ? 64 : 0, 255));

        auto pEndOfTrackNode =
                std::make_unique<allshader_sg::WaveformRendererEndOfTrack>(
                        this, QColor("yellow"));
        pEndOfTrackNode->init();
        bgNode->appendChildNode(pEndOfTrackNode->backendNode());

        m_pEngine = std::make_unique<rendergraph::Engine>(std::move(pEndOfTrackNode));
        m_pEngine->initialize();
    }

    return bgNode;
}

/*
QSGNode* QmlWaveformDisplay::updatePaintNode(QSGNode* node, UpdatePaintNodeData*) {
    auto* clipNode = dynamic_cast<QSGClipNode*>(node);
    static rendergraph::GeometryNode* pPreRoll;

    QSGSimpleRectNode* bgNode;
    if (!clipNode || m_dirtyFlag.testFlag(DirtyFlag::Window)) {
        if (clipNode) {
            delete clipNode;
            m_dirtyFlag.setFlag(DirtyFlag::Window, false);
        }
        clipNode = new QSGClipNode();
        clipNode->setIsRectangular(true);
        bgNode = new QSGSimpleRectNode();
        bgNode->setRect(boundingRect());

        rendergraph::Context context(window());
        auto pTopNode = std::make_unique<rendergraph::Node>();
        // auto pOpacityNode = std::make_unique<rendergraph::OpacityNode>();

        m_rendererStack.clear();
        for (auto pQmlRenderer : m_waveformRenderers) {
            auto renderer = pQmlRenderer->create(this, context);
            addRenderer(renderer.renderer);
            // appendChildTo(pOpacityNode, renderer.node);
            pTopNode->appendChildNode(std::unique_ptr<rendergraph::TreeNode>(renderer.node));
        }

        // pTopNode->appendChildNode(std::move(pOpacityNode));
        bgNode->appendChildNode(pTopNode->backendNode());

        bgNode->setColor(QColor(0, 0, 0, 255));

        clipNode->appendChildNode(bgNode);

        m_pEngine = std::make_unique<rendergraph::Engine>(std::move(pTopNode));
        m_pEngine->initialize();
        init();
    } else {
        bgNode = dynamic_cast<QSGSimpleRectNode*>(clipNode->childAtIndex(0));
    }

    if (m_dirtyFlag.testFlag(DirtyFlag::Geometry)) {
        m_dirtyFlag.setFlag(DirtyFlag::Geometry, false);
        qDebug() << "RECT" << boundingRect();
        qDebug() << "RECT" << childrenRect();
        qDebug() << "RECT" << clipRect();
        // qDebug() << "RECT" << mapToGlobal(QPointF(0, 0));
        // qDebug() << "RECT" << window()->mapToGlobal(QPointF(0, 0)));
        qDebug() << "RECT" << window()->size();
        m_pEngine->resize(boundingRect());
        clipNode->setClipRect(boundingRect());
        bgNode->setRect(boundingRect());
    }

    onPreRender(this);
    clipNode->markDirty(QSGNode::DirtyForceUpdate);

    return clipNode;
}
*/

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
