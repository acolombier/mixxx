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

    Renderer create(WaveformWidgetRenderer* waveformWidget,
            rendergraph::Context context) const override;

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

    Renderer create(WaveformWidgetRenderer* waveformWidget,
            rendergraph::Context context) const override;
  signals:
    void colorChanged(const QColor&);

  private:
    QColor m_color;
};

class QmlWaveformRendererRGB
        : public QmlWaveformRendererFactory {
    Q_OBJECT
    Q_PROPERTY(QColor axesColor READ axesColor WRITE setAxesColor NOTIFY axesColorChanged REQUIRED)
    Q_PROPERTY(QColor lowColor READ lowColor WRITE setLowColor NOTIFY lowColorChanged REQUIRED)
    Q_PROPERTY(QColor midColor READ midColor WRITE setMidColor NOTIFY midColorChanged REQUIRED)
    Q_PROPERTY(QColor highColor READ highColor WRITE setHighColor NOTIFY highColorChanged REQUIRED)
    QML_NAMED_ELEMENT(WaveformRendererRGB)

  public:
    QmlWaveformRendererRGB();

    const QColor& axesColor() const {
        return m_axesColor;
    }
    void setAxesColor(QColor color) {
        m_axesColor = color;
        emit axesColorChanged(m_axesColor);
    }

    const QColor& lowColor() const {
        return m_lowColor;
    }
    void setLowColor(QColor color) {
        m_lowColor = color;
        emit lowColorChanged(m_lowColor);
    }

    const QColor& midColor() const {
        return m_lowColor;
    }
    void setMidColor(QColor color) {
        m_midColor = color;
        emit midColorChanged(m_lowColor);
    }

    const QColor& highColor() const {
        return m_lowColor;
    }
    void setHighColor(QColor color) {
        m_highColor = color;
        emit highColorChanged(m_lowColor);
    }

    Renderer create(WaveformWidgetRenderer* waveformWidget,
            rendergraph::Context context) const override;
  signals:
    void axesColorChanged(const QColor&);
    void lowColorChanged(const QColor&);
    void midColorChanged(const QColor&);
    void highColorChanged(const QColor&);

  private:
    QColor m_axesColor;
    QColor m_lowColor;
    QColor m_midColor;
    QColor m_highColor;
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

    Renderer create(WaveformWidgetRenderer* waveformWidget,
            rendergraph::Context context) const override;
  signals:
    void colorChanged(const QColor&);

  private:
    QColor m_color;
};

} // namespace qml
} // namespace mixxx
