#include "widget/wlibrarypluginview.h"

#include <QQmlComponent>
#include <QQuickItem>

#include "moc_wlibrarypluginview.cpp"

WLibraryPluginView::WLibraryPluginView(QWidget* parent)
        : QQuickWidget(parent) {
}

void WLibraryPluginView::setView(const QByteArray& content, const QString& uri) {
    // QQmlComponent* component = new QQmlComponent(engine(), uri, QQmlComponent::PreferSynchronous);
    QQmlComponent* component = new QQmlComponent(engine());
    component->setData(content, uri);
    if (component->isLoading()) {
        connect(component, &QQmlComponent::statusChanged, this, 
            [=](QQmlComponent::Status status){
                qDebug() << "Component" << component->errors() << component->status();
                if (status != QQmlComponent::Ready) return;

                m_childItem = std::unique_ptr<QQuickItem>(qobject_cast<QQuickItem*>(component->create()));
                if (m_childItem) {
                    qDebug() << "Component: set" << m_childItem.get() << rootObject() << quickWindow()->contentItem();
                    setContent(uri, component, m_childItem.get());
                }
                component->deleteLater();
        });
    } else {
        qDebug() << "Component" << component->errors() << component->status();

        m_childItem = std::unique_ptr<QQuickItem>(qobject_cast<QQuickItem*>(component->create()));
        if (m_childItem) {
            qDebug() << "Component: set" << m_childItem.get() << rootObject() << quickWindow()->contentItem();
            setContent(uri, component, m_childItem.get());
        }
        component->deleteLater();
    }
}

bool WLibraryPluginView::hasFocus() const {
    return QQuickWidget::hasFocus();
}

void WLibraryPluginView::setFocus() {
    QQuickWidget::setFocus();
}
