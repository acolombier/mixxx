#pragma once

#include <QByteArray>
#include <QJSValue>
#include <QString>

class ControllerRenderingEngine;

enum ControllerRenderingTransformFunctionType {
    NONE,
    JAVASCRIPT,

    UNSUPPORTED = 0xffff
};

ControllerRenderingTransformFunctionType transformTypeFromString(const QString& type);

class ControllerRenderingTransformFunctionBase {
  public:
    virtual ~ControllerRenderingTransformFunctionBase(){};

    virtual bool prepare(const ControllerRenderingEngine* parent) = 0;

    virtual bool transform(const ControllerRenderingEngine* parent,
            const QImage& frame,
            QByteArray& output,
            uint8_t screenId) = 0;
};

class ControllerRenderingJSTransformFunction : public ControllerRenderingTransformFunctionBase {
  public:
    ControllerRenderingJSTransformFunction(const QString& payload)
            : m_functionSource(payload) {
    }

    bool prepare(const ControllerRenderingEngine* parent) override;

    bool transform(const ControllerRenderingEngine* parent,
            const QImage& frame,
            QByteArray& output,
            uint8_t screenId) override;

  private:
    QString m_functionSource;
    QJSValue m_function;
};
