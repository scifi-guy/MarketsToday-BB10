// Navigation pane project template
#include "MarketsToday.hpp"

#include <bb/cascades/Application>
#include <bb/cascades/QmlDocument>
#include <bb/cascades/AbstractPane>
#include <bps/navigator.h>

using namespace bb::cascades;

MarketsToday::MarketsToday(bb::cascades::Application *app)
: QObject(app)
{
    // create scene document from main.qml asset
    // set parent to created document to ensure it exists for the whole application lifetime
    QmlDocument *qml = QmlDocument::create("asset:///main.qml").parent(this);

    qml->setContextProperty("app", this);

    // create root object for the UI
    AbstractPane *root = qml->createRootObject<AbstractPane>();
    // set created root object as a scene
    app->setScene(root);
}

void MarketsToday::launchBrowser(QString url)
{

	navigator_invoke(url.toStdString().c_str(), 0);

}
