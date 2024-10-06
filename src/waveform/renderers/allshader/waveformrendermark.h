#pragma once

#include <QColor>

#include "rendergraph/context.h"
#include "rendergraph/geometrynode.h"
#include "rendergraph/node.h"
#include "waveform/renderers/waveformrendermarkbase.h"

class QDomNode;
class SkinContext;

namespace rendergraph {
class GeometryNode;
} // namespace rendergraph

namespace allshader {
class DigitsRenderNode;
class WaveformRenderMark;
class WaveformMarkNode;
class WaveformMarkNodeGraphics;
} // namespace allshader

class allshader::WaveformRenderMark : public ::WaveformRenderMarkBase,
                                      public rendergraph::Node {
  public:
    explicit WaveformRenderMark(WaveformWidgetRenderer* waveformWidget,
#ifndef __RENDERGRAPH_OPENGL__
            rendergraph::Context context,
            QColor fgPlayColor,
            QColor bgPlayColor,
#endif
            ::WaveformRendererAbstract::PositionSource type =
                    ::WaveformRendererAbstract::Play);
    // Pure virtual from WaveformRendererAbstract, not used
    void draw(QPainter* painter, QPaintEvent* event) override final;

    bool init() override;

    void update();

    // Virtual for rendergraph::Node
    void initialize() override;
    void resize(const QRectF&) override;
    bool isSubtreeBlocked() const override;

  private:
    void updateMarkImage(WaveformMarkPointer pMark) override;

    void updatePlayPosMarkTexture();

    void drawTriangle(QPainter* painter,
            const QBrush& fillColor,
            QPointF p1,
            QPointF p2,
            QPointF p3);

    void drawMark(const QMatrix4x4& matrix, const QRectF& rect, QColor color);
    void updateUntilMark(double playPosition, double markerPosition);
    void drawUntilMark(const QMatrix4x4& matrix, float x);
    float getMaxHeightForText() const;
    void updateRangeNode(rendergraph::GeometryNode* pNode,
            const QMatrix4x4& matrix,
            const QRectF& rect,
            QColor color);

    int m_beatsUntilMark;
    double m_timeUntilMark;
    double m_currentBeatPosition;
    double m_nextBeatPosition;
    std::unique_ptr<ControlProxy> m_pTimeRemainingControl;

    bool m_isSlipRenderer;

    rendergraph::TreeNode* m_pRangeNodesParent{};
    rendergraph::TreeNode* m_pMarkNodesParent{};
    rendergraph::GeometryNode* m_pPlayPosNode;
    DigitsRenderNode* m_pDigitsRenderNode{};

#ifndef __RENDERGRAPH_OPENGL__
    QColor m_fgPlayColor;
    QColor m_bgPlayColor;
#endif
    rendergraph::Context m_context;

    DISALLOW_COPY_AND_ASSIGN(WaveformRenderMark);
};

// On the use of QPainter:
//
// The renderers in this folder are optimized to use GLSL shaders and refrain
// from using QPainter on the QOpenGLWindow, which causes degredated performance.
//
// This renderer does use QPainter (indirectly, in WaveformMark::generateImage), but
// only to draw on a QImage. This is only done once when needed and the images are
// then used as textures to be drawn with a GLSL shader.

class allshader::WaveformMarkNode : public rendergraph::GeometryNode {
  public:
    WaveformMark* m_pOwner{};

    WaveformMarkNode(WaveformMark* pOwner,
            const QImage& image,
            const rendergraph::Context& context);
    void updateTexture(const QImage& image);
    void updateMatrix(const QMatrix4x4& matrix);
    void update(float x, float y, float devicePixelRatio);
    float textureWidth() const {
        return m_textureWidth;
    }
    float textureHeight() const {
        return m_textureHeight;
    }

  public:
    float m_textureWidth{};
    float m_textureHeight{};

  private:
    rendergraph::Context m_context;
};

class allshader::WaveformMarkNodeGraphics : public WaveformMark::Graphics {
  public:
    WaveformMarkNodeGraphics(WaveformMark* pOwner,
            const QImage& image,
            const rendergraph::Context& context)
            : m_pNode(std::make_unique<WaveformMarkNode>(
                      pOwner, image, context)) {
    }
    void updateTexture(const QImage& image) {
        waveformMarkNode()->updateTexture(image);
    }
    void updateMatrix(const QMatrix4x4& matrix) {
        waveformMarkNode()->updateMatrix(matrix);
    }
    void update(float x, float y, float devicePixelRatio) {
        waveformMarkNode()->update(x, y, devicePixelRatio);
    }
    float textureWidth() const {
        return waveformMarkNode()->textureWidth();
    }
    float textureHeight() const {
        return waveformMarkNode()->textureHeight();
    }
    void setNode(std::unique_ptr<rendergraph::TreeNode>&& pNode) {
        m_pNode = std::move(pNode);
    }
    void moveNodeToChildrenOf(rendergraph::TreeNode* pParent) {
        pParent->appendChildNode(std::move(m_pNode));
    }

  private:
    WaveformMarkNode* waveformMarkNode() const {
        return static_cast<WaveformMarkNode*>(m_pNode.get());
    }

    std::unique_ptr<rendergraph::TreeNode> m_pNode;
};
