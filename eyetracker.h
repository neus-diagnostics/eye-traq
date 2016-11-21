#ifndef EYETRACKER_H
#define EYETRACKER_H

#include <QLineF>
#include <QList>
#include <QObject>
#include <QString>
#include <QPointF>
#include <QTimer>
#include <QVariant>

#ifdef USE_TOBII
#include <QThread>

#include <tobii/sdk/cpp/GazeDataItem.hpp>
#include <tobii/sdk/cpp/EyeTracker.hpp>
#include <tobii/sdk/cpp/EyeTrackerBrowser.hpp>
#include <tobii/sdk/cpp/EyeTrackerFactory.hpp>
#include <tobii/sdk/cpp/EyeTrackerInfo.hpp>
#include <tobii/sdk/cpp/MainLoop.hpp>
namespace tetio = tobii::sdk::cpp;

#include "gaze.h"

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
#endif

class Eyetracker : public QObject {
	Q_OBJECT
	Q_PROPERTY(bool connected READ connected NOTIFY statusChanged STORED false)
	Q_PROPERTY(QString status READ status NOTIFY statusChanged STORED false)

public:
	Eyetracker();
	virtual ~Eyetracker();

public slots:
	bool command(const QString &what);
	bool calibrate(const QPointF &point);
	QList<QVariant> get_calibration();
	qint64 time();

signals:
	void statusChanged();
	void gaze(const Gaze &g);
	void gazePoint(const QPointF &point);

#ifdef USE_TOBII
	void browsed(BrowseEvent *event);

private slots:
	void on_browsed(BrowseEvent *event);
	void try_connect();

private:
	bool connected() const;
	QString status() const;

	void handle_browse(tetio::EyeTrackerBrowser::event_type_t type,
	                   tetio::EyeTrackerInfo::pointer_t info);
	void handle_error(uint32_t error);
	void handle_sync(tetio::SyncState::pointer_t sync_state);
	void handle_gaze(tetio::GazeDataItem::pointer_t gaze_data);

	MainLoop main_loop;

	tetio::EyeTrackerBrowser::pointer_t browser;
	tetio::EyeTrackerFactory::pointer_t factory;
	tetio::EyeTracker::pointer_t tracker;

	tetio::Clock clock;
	tetio::SyncManager::pointer_t sync_manager;

	QTimer connection_timer;
#endif
};

#endif
