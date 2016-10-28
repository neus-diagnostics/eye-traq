#ifndef EYETRACKER_H
#define EYETRACKER_H

#include <QLineF>
#include <QList>
#include <QObject>
#include <QString>
#include <QThread>
#include <QTimer>
#include <QVector>

#include <tobii/sdk/cpp/GazeDataItem.hpp>
#include <tobii/sdk/cpp/EyeTracker.hpp>
#include <tobii/sdk/cpp/EyeTrackerBrowser.hpp>
#include <tobii/sdk/cpp/EyeTrackerFactory.hpp>
#include <tobii/sdk/cpp/EyeTrackerInfo.hpp>
#include <tobii/sdk/cpp/MainLoop.hpp>
namespace tetio = tobii::sdk::cpp;

struct BrowseEvent : QObject {
	BrowseEvent(tetio::EyeTrackerBrowser::event_type_t type,
	            tetio::EyeTrackerInfo::pointer_t info)
		: QObject{}, type{type}, info{info}
	{
	}
	tetio::EyeTrackerBrowser::event_type_t type;
	tetio::EyeTrackerInfo::pointer_t info;
};

class MainLoop : public QThread {
	Q_OBJECT
public:
	~MainLoop() { quit(); wait(); }
	void run() { thread.run(); }
	void quit() { thread.quit(); }

        tetio::MainLoop thread;
};

class Eyetracker : public QObject {
	Q_OBJECT
public:
	Eyetracker();
	virtual ~Eyetracker();

	bool command(const QString &what);
	bool calibrate(const QPointF &point);
	QVector<QList<QLineF>> get_calibration();

signals:
	void browsed(BrowseEvent *event);
	void connected();
	void disconnected();
	void gazed(const QString &left, const QString &right);

private slots:
	void on_browsed(BrowseEvent *event);
	void try_connect();

private:
	void handle_browse(tetio::EyeTrackerBrowser::event_type_t type,
	                   tetio::EyeTrackerInfo::pointer_t info);
	void handle_error(uint32_t error);
	void handle_gaze(tetio::GazeDataItem::pointer_t gaze);

	MainLoop main_loop;

	tetio::EyeTrackerBrowser::pointer_t eyetracker;
	tetio::EyeTrackerFactory::pointer_t factory;
	tetio::EyeTracker::pointer_t tracker;

	QTimer connection_timer;
};

#endif
