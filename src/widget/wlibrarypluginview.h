#pragma once

#include <QQuickWidget>

#include "library/libraryview.h"

QT_FORWARD_DECLARE_CLASS(QQuickItem)

class WLibraryPluginView : public QQuickWidget, public LibraryView {
    Q_OBJECT
  public:
    explicit WLibraryPluginView(QWidget* parent = nullptr);
    void onShow() override {
    }
    bool hasFocus() const override;
    void setFocus() override;

    void setView(const QByteArray& content, const QString& uri = "");

  private:
    std::unique_ptr<QQuickItem> m_childItem;
};
