#include "qml/qmlwaveformdisplay.h"

#include <QQuickWindow>
#include <QSGSimpleRectNode>
#include <QSGVertexColorMaterial>
#include <cmath>

#include "mixer/basetrackplayer.h"
#include "qml/qmlplayerproxy.h"

namespace mixxx {
namespace qml {

QmlWaveformDisplay::QmlWaveformDisplay(QQuickItem* parent)
        : QQuickItem(parent),
          m_pPlayer(nullptr) {
    setFlag(QQuickItem::ItemHasContents, true);

    connect(this, &QmlWaveformDisplay::windowChanged, this, &QmlWaveformDisplay::slotWindowChanged);
}

void QmlWaveformDisplay::slotWindowChanged(QQuickWindow* window) {
    connect(window, &QQuickWindow::frameSwapped, this, &QmlWaveformDisplay::slotFrameSwapped);
}

void QmlWaveformDisplay::slotFrameSwapped() {
}

QSGNode* QmlWaveformDisplay::updatePaintNode(QSGNode* old, QQuickItem::UpdatePaintNodeData*) {
    auto* bgNode = dynamic_cast<QSGSimpleRectNode*>(old);
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

    float ratio = window()->devicePixelRatio();
    float invRatio = 1.f / ratio;

    int n = static_cast<int>(width() * ratio);

    geometry->allocate(n * 2);

    QSGGeometry::ColoredPoint2D* vertices = geometry->vertexDataAsColoredPoint2D();

    constexpr float twopi = M_PI * 2.f;
    int j = 0;

    const float h = height();

    for (int i = 0; i < n; i++) {
        float x = static_cast<float>(i) * invRatio;
        float f = twopi * 3.f * 4.f * 5.f * 7.f * ((m_phase + i) & 4095) / 4096.f;
        uchar r = static_cast<uchar>(std::cos(f / 3.0) * 127.f + 127.f);
        uchar g = static_cast<uchar>(std::cos(f / 4.0) * 127.f + 127.f);
        uchar b = static_cast<uchar>(std::cos(f / 5.0) * 127.f + 127.f);
        vertices[j++].set(x, std::cos(f / 7.f) * h * 0.25 + h * 0.75, r, g, b, 255);
        vertices[j++].set(x, std::cos(f / 5.f) * h * 0.25 + h * 0.25, r, g, b, 255);
    }

    m_phase += 4;

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

    emit playerChanged();
    update();
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
}

void QmlWaveformDisplay::slotWaveformUpdated() {
    update();
}

} // namespace qml
} // namespace mixxx
