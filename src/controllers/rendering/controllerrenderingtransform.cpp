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
        const QImage& frame,
        QByteArray& output,
        uint8_t screenId) {
    QByteArray input((const char*)frame.constBits(), frame.sizeInBytes());
    QJSValue dataToSend = m_function.call(
            QJSValueList{parent->jsEngine()->toScriptValue(input), screenId});

    if (dataToSend.isError()) {
        qWarning() << "Could not transform rendering buffer. Error:" << dataToSend.toString();
        return false;
    }

    QVariant returnValue(dataToSend.toVariant(QJSValue::ConvertJSObjects));

    if (returnValue.canView<QByteArray>()) {
        output = returnValue.view<QByteArray>();
    }
    else if (returnValue.canConvert<QByteArray>()) {
        output = returnValue.toByteArray();
    }
    else {
        qWarning() << "Unable to interpret the return data " << returnValue;
    }
    return true;
}
