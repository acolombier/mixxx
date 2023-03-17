#pragma once

#include <QVariant>

#include "util/assert.h"

/// ColorMapper allows to find the nearest color representation of a given color
/// in a set of fixed colors. Additional user data (e.g. MIDI byte values) can
/// be linked to colors in the color set as QVariant.
class ControllerRuntimeData : public QObject {
    Q_OBJECT
  public:
    ControllerRuntimeData(QObject* parent)
            : QObject(parent), m_value() {
    }

    const QVariant& get() const {
        return m_value;
    }

  public slots:
    void set(const QVariant& value) {
        m_value = value;
        emit updated(m_value);
    }

  signals:
    void updated(const QVariant& value);

  private:
    QVariant m_value;
};
