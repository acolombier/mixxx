#include "rendergraph/texture.h"

#include <memory>

#include "rendergraph/assert.h"
#include "rendergraph/context.h"

using namespace rendergraph;

Texture::Texture(Context& context, const QImage& image) {
    VERIFY_OR_DEBUG_ASSERT(context.window() != nullptr) {
        return;
    }
    m_pTexture = std::unique_ptr<BaseTexture>(context.window()->createTextureFromImage(image));
    DEBUG_ASSERT(!m_pTexture->textureSize().isNull());
}

qint64 Texture::comparisonKey() const {
    return m_pTexture->comparisonKey();
}
