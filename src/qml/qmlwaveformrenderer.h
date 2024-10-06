#pragma once

#include <QObject>

#include "rendergraph/context.h"
#include "rendergraph/treenode.h"
#include "waveform/renderers/waveformrendererabstract.h"
#include "waveform/renderers/waveformwidgetrenderer.h"

class WaveformWidgetRenderer;

namespace allshaders {
class WaveformRendererEndOfTrack;
class WaveformRendererPreroll;
class WaveformRendererRGB;
class WaveformRenderBeat;
} // namespace allshaders

namespace mixxx {
namespace qml {

class QmlWaveformRendererFactory : public QObject {
    Q_OBJECT
    QML_ANONYMOUS
  public:
    struct Renderer {
        ::WaveformRendererAbstract* renderer;
        rendergraph::TreeNode* node;
    };

    virtual Renderer create(WaveformWidgetRenderer* waveformWidget,
            rendergraph::Context context) const = 0;
};

class QmlWaveformRendererEndOfTrack
        : public QmlWaveformRendererFactory {
    Q_OBJECT
    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged REQUIRED)
    QML_NAMED_ELEMENT(WaveformRendererEndOfTrack)

  public:
    QmlWaveformRendererEndOfTrack();

    const QColor& color() const {
        return m_color;
    }
    void setColor(QColor color) {
        m_color = color;
        emit colorChanged(m_color);
    }

    Renderer create(WaveformWidgetRenderer* waveformWidget, rendergraph::Context context) const;

  signals:
    void colorChanged(const QColor&);

  private:
    QColor m_color;
};

class QmlWaveformRendererPreroll
        : public QmlWaveformRendererFactory {
    Q_OBJECT
    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged REQUIRED)
    QML_NAMED_ELEMENT(WaveformRendererPreroll)

  public:
    QmlWaveformRendererPreroll();

    const QColor& color() const {
        return m_color;
    }
    void setColor(QColor color) {
        m_color = color;
        emit colorChanged(m_color);
    }

    Renderer create(WaveformWidgetRenderer* waveformWidget, rendergraph::Context context) const;
  signals:
    void colorChanged(const QColor&);

  private:
    QColor m_color;
};

class QmlWaveformRendererRGB
        : public QmlWaveformRendererFactory {
    Q_OBJECT
    QML_NAMED_ELEMENT(WaveformRendererRGB)

  public:
    QmlWaveformRendererRGB();

    Renderer create(WaveformWidgetRenderer* waveformWidget, rendergraph::Context context) const;
};

class QmlWaveformRendererBeat
        : public QmlWaveformRendererFactory {
    Q_OBJECT
    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged REQUIRED)
    QML_NAMED_ELEMENT(WaveformRendererBeat)

  public:
    QmlWaveformRendererBeat();

    const QColor& color() const {
        return m_color;
    }
    void setColor(QColor color) {
        m_color = color;
        emit colorChanged(m_color);
    }

    Renderer create(WaveformWidgetRenderer* waveformWidget, rendergraph::Context context) const;
  signals:
    void colorChanged(const QColor&);

  private:
    QColor m_color;
};

} // namespace qml
} // namespace mixxx
