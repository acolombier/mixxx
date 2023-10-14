#pragma once

#include <QFileSystemWatcher>
#include <QJSEngine>
#include <QJSValue>
#include <QMessageBox>
#include <QQuickItem>

#include "controllers/legacycontrollermapping.h"
#include "controllers/scripting/controllerscriptenginebase.h"
#include "util/parented_ptr.h"

class ControllerRenderingEngine;

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

    /// Wrap a string of JS code in an anonymous function. This allows any JS
    /// string that evaluates to a function to be used in MIDI mapping XML files
    /// and ensures the function is executed with the correct 'this' object.
    QJSValue wrapFunctionCode(const QString& codeSnippet, int numberOfArgs);

  public slots:
    void setScriptFiles(const QList<LegacyControllerMapping::ScriptFileInfo>& scripts);
    void setLibraryDirectories(const QList<LegacyControllerMapping::QMLModuleInfo>& scripts);
    void setInfoScrens(const QList<LegacyControllerMapping::ScreenInfo>& scripts);

  private slots:
    void handleScreenFrame(
            const LegacyControllerMapping::ScreenInfo& screeninfo,
            QImage frame,
            const QDateTime& timestamp);

  signals:
    /// Emitted when a screen has been rendered
    void previewRenderedScreen(const LegacyControllerMapping::ScreenInfo& screen, QImage frame);

  private:
    bool evaluateScriptFile(const QFileInfo& scriptFile);
    bool bindSceneToScreen(
            const LegacyControllerMapping::ScriptFileInfo& qmlFile,
            const QString& screenIdentifier,
            ControllerRenderingEngine* pScreen);
    void shutdown() override;
    bool bindSceneToScreen();

    std::shared_ptr<QQuickItem> loadQMLFile(
            const LegacyControllerMapping::ScriptFileInfo& qmlScript,
            const ControllerRenderingEngine* pScreen);
    QJSValue wrapArrayBufferCallback(const QJSValue& callback);
    bool callFunctionOnObjects(const QList<QString>& scriptFunctionPrefixes,
            const QString&,
            const QJSValueList& args = {},
            bool bFatalError = false);

    QJSValue m_makeArrayBufferWrapperFunction;
    QList<QString> m_scriptFunctionPrefixes;
    QHash<QString, ControllerRenderingEngine*> m_renderingScreens;
    QHash<QString, bool> m_isScreenSending;
    QHash<QString, std::shared_ptr<QQuickItem>> m_rootItems;
    QHash<QString, QMetaMethod> m_transformScreenFrameFunctions;
    QList<QJSValue> m_incomingDataFunctions;
    QHash<QString, QJSValue> m_scriptWrappedFunctionCache;
    QList<LegacyControllerMapping::QMLModuleInfo> m_libraryDirectories;
    QList<LegacyControllerMapping::ScriptFileInfo> m_scriptFiles;
    QList<LegacyControllerMapping::ScreenInfo> m_infoScreens;

    QFileSystemWatcher m_fileWatcher;

    // There is lots of tight coupling between ControllerScriptEngineLegacy
    // and ControllerScriptInterface. This is probably not worth improving in legacy code.
    friend class ControllerScriptInterfaceLegacy;
    std::shared_ptr<QJSEngine> jsEngine() const {
        return m_pJSEngine;
    }

    friend class ControllerScriptEngineLegacyTest;
};
