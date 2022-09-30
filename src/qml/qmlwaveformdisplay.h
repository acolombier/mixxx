#pragma once

#include <QPointer>
#include <QQuickItem>
#include <QQuickWindow>
#include <QSGNode>
#include <QtQml>

#include "track/track.h"
#include "util/performancetimer.h"

namespace mixxx {
namespace qml {

class QmlPlayerProxy;

class QmlWaveformDisplay : public QQuickItem {
    Q_OBJECT
    Q_PROPERTY(mixxx::qml::QmlPlayerProxy* player READ getPlayer WRITE setPlayer
                    NOTIFY playerChanged REQUIRED)
    QML_NAMED_ELEMENT(WaveformDisplay)

  public:
    QmlWaveformDisplay(QQuickItem* parent = nullptr);
    ~QmlWaveformDisplay() override = default;

    void setPlayer(QmlPlayerProxy* player);
    QmlPlayerProxy* getPlayer() const;

    QSGNode* updatePaintNode(QSGNode* old, QQuickItem::UpdatePaintNodeData*) override;

  private slots:
    void slotTrackLoaded(TrackPointer pLoadedTrack);
    void slotTrackLoading(TrackPointer pNewTrack, TrackPointer pOldTrack);
    void slotTrackUnloaded();
    void slotWaveformUpdated();

    void slotFrameSwapped();
    void slotWindowChanged(QQuickWindow* window);
  signals:
    void playerChanged();

  private:
    void setCurrentTrack(TrackPointer pTrack);

    QPointer<QmlPlayerProxy> m_pPlayer;
    TrackPointer m_pCurrentTrack;

    int m_phase{};
    PerformanceTimer m_timer;
};

} // namespace qml
} // namespace mixxx
