#include "rendergraph/geometry.h"

#include "rendergraph/assert.h"

using namespace rendergraph;

namespace {
QSGGeometry::DrawingMode toSgDrawingMode(Geometry::DrawingMode mode) {
    switch (mode) {
    case Geometry::DrawingMode::Triangles:
        return QSGGeometry::DrawTriangles;
    case Geometry::DrawingMode::TriangleStrip:
        return QSGGeometry::DrawTriangleStrip;
    }
}

Geometry::DrawingMode fromSgDrawingMode(unsigned int mode) {
    switch (mode) {
    case QSGGeometry::DrawTriangles:
        return Geometry::DrawingMode::Triangles;
    case QSGGeometry::DrawTriangleStrip:
        return Geometry::DrawingMode::TriangleStrip;
    default:
        throw "not implemented";
    }
}
} // namespace

Geometry::Geometry(const rendergraph::AttributeSet& attributeSet, int vertexCount)
        : BaseGeometry(attributeSet, vertexCount) {
}

void Geometry::setAttributeValues(int attributePosition, const float* from, int numTuples) {
    // TODO this code assumes all vertices are floats
    const auto attributeArray = QSGGeometry::attributes();
    int vertexOffset = 0;
    for (int i = 0; i < attributePosition; i++) {
        vertexOffset += attributeArray[i].tupleSize;
    }
    const int tupleSize = attributeArray[attributePosition].tupleSize;
    const int vertexStride = sizeOfVertex() / sizeof(float);
    const int vertexSkip = vertexStride - tupleSize;

    VERIFY_OR_DEBUG_ASSERT(vertexOffset + numTuples * vertexStride - vertexSkip <=
            vertexCount() * vertexStride) {
        return;
    }

    float* to = static_cast<float*>(QSGGeometry::vertexData());
    to += vertexOffset;
    while (numTuples--) {
        int k = tupleSize;
        while (k--) {
            *to++ = *from++;
        }
        to += vertexSkip;
    }
}

void Geometry::setDrawingMode(Geometry::DrawingMode mode) {
    QSGGeometry::setDrawingMode(toSgDrawingMode(mode));
}

Geometry::DrawingMode Geometry::drawingMode() const {
    return fromSgDrawingMode(QSGGeometry::drawingMode());
}
