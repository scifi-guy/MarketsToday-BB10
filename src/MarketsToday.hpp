// Navigation pane project template
#ifndef MarketsToday_HPP_
#define MarketsToday_HPP_

#include <QObject>
#include <bps/navigator.h>


namespace bb { namespace cascades { class Application; }}

/*!
 * @brief Application pane object
 *
 *Use this object to create and init app UI, to create context objects, to register the new meta types etc.
 */
class MarketsToday : public QObject
{
	Q_OBJECT
public:
	MarketsToday(bb::cascades::Application *app);
	Q_INVOKABLE void launchBrowser(QString url);
	virtual ~MarketsToday() {}
};

#endif /* MarketsToday_HPP_ */
