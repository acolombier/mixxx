#include "customitem.h"

#include <QtQuick/QSGGeometryNode>
#include <QtQuick/QSGMaterial>
#include <QtQuick/QSGTexture>
#include <QtQuick/QSGTextureProvider>

class CustomShader : public QSGMaterialShader {
  public:
    CustomShader() {
        setShaderFileName(VertexStage,
                QLatin1String(":/scenegraph/custommaterial/shaders/"
                              "endoftrack.vert.qsb"));
        setShaderFileName(FragmentStage,
                QLatin1String(":/scenegraph/custommaterial/shaders/"
                              "endoftrack.frag.qsb"));
    }
    bool updateUniformData(RenderState& state,
            QSGMaterial* newMaterial,
            QSGMaterial* oldMaterial) override;
};

class CustomMaterial : public QSGMaterial {
  public:
    CustomMaterial();
    QSGMaterialType* type() const override;
    int compare(const QSGMaterial* other) const override;

    QSGMaterialShader* createShader(QSGRendererInterface::RenderMode) const override {
        return new CustomShader;
    }

    struct {
        QVector4D color;
        bool dirty;
    } uniforms;
};

CustomMaterial::CustomMaterial() {
    setFlag(QSGMaterial::Blending);
}

QSGMaterialType* CustomMaterial::type() const {
    static QSGMaterialType type;
    return &type;
}

int CustomMaterial::compare(const QSGMaterial* o) const {
    Q_ASSERT(o && type() == o->type());
    const auto* other = static_cast<const CustomMaterial*>(o);
    return other == this ? 0 : 1;
}

bool CustomShader::updateUniformData(RenderState& state,
        QSGMaterial* newMaterial,
        QSGMaterial* oldMaterial) {
    bool changed = false;
    QByteArray* buf = state.uniformData();

    auto* customMaterial = static_cast<CustomMaterial*>(newMaterial);
    if (oldMaterial != newMaterial || customMaterial->uniforms.dirty) {
        memcpy(buf->data(), &customMaterial->uniforms.color, 16);
        customMaterial->uniforms.dirty = false;
        changed = true;
    }
    return changed;
}

class CustomNode : public QSGGeometryNode {
  public:
    static constexpr float positionArray[] = {-1.f, -1.f, 1.f, -1.f, -1.f, 1.f, 1.f, 1.f};
    static constexpr float verticalGradientArray[] = {1.f, 1.f, -1.f, -1.f};
    static constexpr float horizontalGradientArray[] = {-1.f, 1.f, -1.f, 1.f};

    static const QSGGeometry::AttributeSet& attributes() {
        static QSGGeometry::Attribute attr[] = {
                QSGGeometry::Attribute::create(0, 2, QSGGeometry::FloatType, true),
                QSGGeometry::Attribute::create(1, 1, QSGGeometry::FloatType)};
        static QSGGeometry::AttributeSet set = {2, 3 * sizeof(float), attr};
        return set;
    }

    // copy data from a flat float array into the interleaved vertex data,
    // using the attribute set description to determine offset, tupleSize and stride
    void copyAttribute(const QSGGeometry::AttributeSet& attributeSet,
            size_t attributeIndex,
            float const* from,
            float* to,
            size_t n) {
        size_t offset = 0;
        for (size_t i = 0; i < attributeIndex; i++) {
            offset += attributeSet.attributes[i].tupleSize;
        }
        const size_t tupleSize = attributeSet.attributes[attributeIndex].tupleSize;
        const size_t stride = attributeSet.stride / sizeof(float);
        const size_t skip = stride - tupleSize;

        to += offset;
        while (n--) {
            size_t k = tupleSize;
            while (k--) {
                *to++ = *from++;
            }
            to += skip;
        }
    }

    CustomNode() {
        auto* m = new CustomMaterial;
        setMaterial(m);
        setFlag(OwnsMaterial, true);

        QSGGeometry* g = new QSGGeometry(attributes(), 4);
        g->setDrawingMode(QSGGeometry::DrawTriangleStrip);
        setGeometry(g);
        setFlag(OwnsGeometry, true);

        copyAttribute(attributes(), 0, positionArray, (float*)g->vertexData(), 4);
        copyAttribute(attributes(), 1, horizontalGradientArray, (float*)g->vertexData(), 4);
    }

    void setRect(const QRectF& bounds) {
        (void)bounds;
        // since we draw using the normalized -1,-1 1,1 rectangle, no need to do anything
        markDirty(QSGNode::DirtyGeometry);
    }

    void setColor(QColor color) {
        auto* m = static_cast<CustomMaterial*>(material());
        m->uniforms.color = QVector4D{color.redF(), color.greenF(), color.blueF(), color.alphaF()};
        m->uniforms.dirty = true;
        markDirty(DirtyMaterial);
    }
};

CustomItem::CustomItem(QQuickItem* parent)
        : QQuickItem(parent) {
    setFlag(ItemHasContents, true);
}

void CustomItem::geometryChange(const QRectF& newGeometry, const QRectF& oldGeometry) {
    m_geometryChanged = true;
    update();
    QQuickItem::geometryChange(newGeometry, oldGeometry);
}

QSGNode* CustomItem::updatePaintNode(QSGNode* old, UpdatePaintNodeData*) {
    auto* node = static_cast<CustomNode*>(old);

    if (!node)
        node = new CustomNode;

    if (m_geometryChanged)
        node->setRect(boundingRect());
    m_geometryChanged = false;

    if (m_colorChanged)
        node->setColor(m_color);
    m_colorChanged = false;

    return node;
}

void CustomItem::setColor(QColor color) {
    m_color = color;
    m_colorChanged = true;
    emit colorChanged(m_color);
    update();
}
