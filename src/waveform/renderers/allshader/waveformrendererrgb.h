#pragma once

#include "rendergraph/geometrynode.h"
#include "util/class.h"
#include "util/colorcomponents.h"
#include "waveform/renderers/allshader/waveformrenderersignalbase.h"

namespace allshader {
class WaveformRendererRGB;
}

class allshader::WaveformRendererRGB final
        : public allshader::WaveformRendererSignalBase,
          public rendergraph::GeometryNode {
  public:
    explicit WaveformRendererRGB(WaveformWidgetRenderer* waveformWidget,
            ::WaveformRendererAbstract::PositionSource type =
                    ::WaveformRendererAbstract::Play,
            WaveformRendererSignalBase::Options options = WaveformRendererSignalBase::Option::None);

    explicit WaveformRendererRGB(
            WaveformWidgetRenderer* waveformWidget,
            QColor axesColor,
            QColor lowColor,
            QColor midColor,
            QColor highColor,
            ::WaveformRendererAbstract::PositionSource type =
                    ::WaveformRendererAbstract::Play,
            WaveformRendererSignalBase::Options options = WaveformRendererSignalBase::Option::None)
            : WaveformRendererRGB(waveformWidget, type, options) {
        getRgbF(axesColor, &m_axesColor_r, &m_axesColor_g, &m_axesColor_b, &m_axesColor_a);

        getRgbF(lowColor, &m_rgbLowColor_r, &m_rgbLowColor_g, &m_rgbLowColor_b);
        getRgbF(midColor, &m_rgbMidColor_r, &m_rgbMidColor_g, &m_rgbMidColor_b);
        getRgbF(highColor, &m_rgbHighColor_r, &m_rgbHighColor_g, &m_rgbHighColor_b);
    }

    // Pure virtual from WaveformRendererSignalBase, not used
    void onSetup(const QDomNode& node) override;

    bool supportsSlip() const override {
        return true;
    }

    // Virtuals for rendergraph::Node
    void preprocess() override;

  private:
    bool m_isSlipRenderer;
    WaveformRendererSignalBase::Options m_options;

    bool preprocessInner();

    DISALLOW_COPY_AND_ASSIGN(WaveformRendererRGB);
};
