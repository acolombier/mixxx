#include "controllers/rendering/controllerrenderingtransform.h"

#include <QImage>

#include "controllers/rendering/controllerrenderingengine.h"
#include "util/assert.h"

ControllerRenderingTransformFunctionType transformTypeFromString(const QString& type) {
    if (type.isEmpty()) {
        return ControllerRenderingTransformFunctionType::NONE;
    }
    if (!QString::compare(type, "JAVASCRIPT", Qt::CaseInsensitive)) {
        return ControllerRenderingTransformFunctionType::JAVASCRIPT;
    }

    return ControllerRenderingTransformFunctionType::UNSUPPORTED;
}

bool ControllerRenderingJSTransformFunction::prepare(const ControllerRenderingEngine* parent) {
    m_function = parent->jsEngine()->evaluate(m_functionSource);

    if (m_function.isError()) {
        QString errorMessage = m_function.toString();
        QString line = m_function.property("lineNumber").toString();
        QString backtrace = m_function.property("stack").toString();

        qWarning() << "The provided controller rendering transformation "
                      "function has an error:"
                   << QString("<passed code>:%2: %3").arg(line, errorMessage);
        return false;
    }

    if (!m_function.isCallable()) {
        qWarning() << "The provided controller rendering transformation function isn't callable!";
        return false;
    }
    return true;
}

bool ControllerRenderingJSTransformFunction::transform(
        const ControllerRenderingEngine* parent,
        QByteArray& output,
        uint8_t screenId) {
    const QImage frame = parent->fbo()->toImage();
    VERIFY_OR_DEBUG_ASSERT(!frame.isNull()) {
        qWarning() << "Unable to extract image while rendering controller screen" << screenId;
        return false;
    }

    QByteArray input((const char*)frame.constBits(), frame.sizeInBytes());
    QJSValue dataToSend = m_function.call(
            QJSValueList{parent->jsEngine()->toScriptValue(input), screenId});

    if (dataToSend.isError()) {
        qWarning() << "Could not transform rendering buffer. Error:" << dataToSend.toString();
        return false;
    }

    // FIXME: we shouldn't have to transform every single case of the JS array
    // to a byte manually. Sure there is a way to transform it implicitly
    if (dataToSend.isArray()) {
        int length = dataToSend.property("length").toInt();
        if (length != output.size()) {
            output.resize(length);
            output.squeeze();
        }

        for (int i = 0; i < length; i++) {
            int value = dataToSend.property(i).toInt();
            output[i] = static_cast<char>(value);
        }
    }
    return true;
}
