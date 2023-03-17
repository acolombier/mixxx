#pragma once

#include <QJSValue>
#include <QUuid>

#include "preferences/configobject.h"

class ControllerScriptEngineBase;
class ControllerScriptInterfaceLegacy;

/// ScriptConnection is a connection between a ControlObject and a
/// script callback function that gets executed when the value
/// of the ControlObject changes.
class ScriptConnection {
  public:
    ConfigKey key;
    QUuid id;
    QJSValue callback;
    ControllerScriptInterfaceLegacy* engineJSProxy;
    ControllerScriptEngineBase* controllerEngine;
    bool skipSuperseded;

    void executeCallback(double value) const;

    // Required for various QList methods and iteration to work.
    inline bool operator==(const ScriptConnection& other) const {
        return id == other.id;
    }
    inline bool operator!=(const ScriptConnection& other) const {
        return !(*this == other);
    }
};
