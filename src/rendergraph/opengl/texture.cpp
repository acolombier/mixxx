#include "rendergraph/texture.h"
#include <qnamespace.h>
#include <qrgb.h>
#include "rendergraph/assert.h"

#include "rendergraph/context.h"

using namespace rendergraph;

namespace {
QImage premultiplyAlpha(const QImage& image) {
    QImage texture(image.width(), image.height(), QImage::Format_RGBA8888);
    if (image.format() == QImage::Format_RGBA8888_Premultiplied) {
        VERIFY_OR_DEBUG_ASSERT(texture.sizeInBytes() == image.sizeInBytes()){
            texture.fill(QColor(Qt::transparent).rgba());
            return texture;
        }
        std::memcpy(texture.bits(), image.bits(), texture.sizeInBytes());
    } else {
        auto convertedImage = image.convertToFormat(QImage::Format_RGBA8888_Premultiplied);
        VERIFY_OR_DEBUG_ASSERT(texture.sizeInBytes() == convertedImage.sizeInBytes()){
            texture.fill(QColor(Qt::transparent).rgba());
            return texture;
        }
        std::memcpy(texture.bits(), convertedImage.bits(), texture.sizeInBytes());

    }
    return texture;
}
} // namespace

Texture::Texture(Context*, const QImage& image)
        : m_pTexture(std::make_unique<QOpenGLTexture>(premultiplyAlpha(image))) {
    m_pTexture->setMinMagFilters(QOpenGLTexture::Linear, QOpenGLTexture::Linear);
    m_pTexture->setWrapMode(QOpenGLTexture::ClampToEdge);
}

qint64 Texture::comparisonKey() const {
    return static_cast<qint64>(m_pTexture->textureId());
}
