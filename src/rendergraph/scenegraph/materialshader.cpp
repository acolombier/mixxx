#include "rendergraph/materialshader.h"

using namespace rendergraph;

namespace {
static QString resource(const QString& filename) {
    return QStringLiteral(
            "/home/antoine/dev/mixxx/build/res/shaders/rendergraph/.qsb/%1.qsb")
            .arg(filename);
}
} // namespace

MaterialShader::MaterialShader(const char* vertexShaderFile,
        const char* fragmentShaderFile,
        const UniformSet& uniformSet,
        const AttributeSet& attributeSet) {
    (void)uniformSet;
    (void)attributeSet;
    setShaderFileName(VertexStage, resource(vertexShaderFile));
    setShaderFileName(FragmentStage, resource(fragmentShaderFile));
}
