#pragma once

#include <QFileSystemWatcher>
#include <QJSEngine>
#include <QJSValue>
#include <QMessageBox>

#include "controllers/legacycontrollermapping.h"
#include "controllers/scripting/controllerscriptenginebase.h"

class ControllerScreenRendering;

/// ControllerScriptEngineLegacy loads and executes controller scripts for the legacy
/// JS/XML hybrid controller mapping system.
class ControllerScriptEngineLegacy : public ControllerScriptEngineBase {
    Q_OBJECT
  public:
    explicit ControllerScriptEngineLegacy(
            Controller* controller, const RuntimeLoggingCategory& logger);
    ~ControllerScriptEngineLegacy() override;

    bool initialize() override;

    bool handleIncomingData(const QByteArray& data);

    bool handleRenderingData(const QString& identifier, uint8_t screenId, const QByteArray& data);

    /// Wrap a string of JS code in an anonymous function. This allows any JS
    /// string that evaluates to a function to be used in MIDI mapping XML files
    /// and ensures the function is executed with the correct 'this' object.
    QJSValue wrapFunctionCode(const QString& codeSnippet, int numberOfArgs);

  public slots:
    void setScriptFiles(const QList<LegacyControllerMapping::ScriptFileInfo>& scripts);
    void setQMLFiles(const QList<LegacyControllerMapping::QMLFileInfo>& qmls);

  private:
    bool evaluateScriptFile(const QFileInfo& scriptFile);
    void shutdown() override;

    QJSValue wrapArrayBufferCallback(const QJSValue& callback);
    QJSValue wrapRenderBufferCallback(const QJSValue& callback);
    bool callFunctionOnObjects(const QList<QString>& scriptFunctionPrefixes,
            const QString&,
            const QJSValueList& args = {},
            bool bFatalError = false);

    QJSValue m_makeArrayBufferWrapperFunction;
    QJSValue m_makeRenderBufferWrapperFunction;
    QList<QString> m_scriptFunctionPrefixes;
    QList<QJSValue> m_incomingDataFunctions;
    QList<QJSValue> m_renderingDataFunctions;
    QHash<QString, QJSValue> m_scriptWrappedFunctionCache;
    QList<LegacyControllerMapping::ScriptFileInfo> m_scriptFiles;
    QList<LegacyControllerMapping::QMLFileInfo> m_qmlFiles;

    QList<std::shared_ptr<ControllerScreenRendering>> m_pScreenRendering;

    QFileSystemWatcher m_fileWatcher;

    // There is lots of tight coupling between ControllerScriptEngineLegacy
    // and ControllerScriptInterface. This is probably not worth improving in legacy code.
    friend class ControllerScriptInterfaceLegacy;
    QJSEngine* jsEngine() const override {
        return m_pJSEngine.get();
    }

    friend class ControllerScriptEngineLegacyTest;
};
