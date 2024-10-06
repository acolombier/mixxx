#pragma once

#include "rendergraph/geometrynode.h"
#include "util/class.h"
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
        m_axesColor_r = axesColor.redF();
        m_axesColor_g = axesColor.greenF();
        m_axesColor_b = axesColor.blueF();
        m_axesColor_a = axesColor.alphaF();

        m_rgbLowColor_r = lowColor.redF();
        m_rgbLowColor_g = lowColor.redF();
        m_rgbLowColor_b = lowColor.redF();

        m_rgbMidColor_r = midColor.greenF();
        m_rgbMidColor_g = midColor.greenF();
        m_rgbMidColor_b = midColor.greenF();

        m_rgbHighColor_r = highColor.blueF();
        m_rgbHighColor_g = highColor.blueF();
        m_rgbHighColor_b = highColor.blueF();
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
