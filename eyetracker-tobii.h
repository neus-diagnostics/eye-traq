#ifndef EYETRACKER_TOBII_H
#define EYETRACKER_TOBII_H

#include "eyetracker.h"

#include <QThread>
#include <QTimer>

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

class EyetrackerTobii : public Eyetracker {
	Q_OBJECT

public:
	EyetrackerTobii();
	virtual ~EyetrackerTobii();

public slots:
	bool calibrate(const QString &what);
	bool calibrate(const QPointF &point);
	QVariantList get_calibration();
	qint64 time();

signals:
	void browsed(BrowseEvent *event);

private slots:
	void on_browsed(BrowseEvent *event);
	void try_connect();

private:
	void handle_browse(tetio::EyeTrackerBrowser::event_type_t type,
	                   tetio::EyeTrackerInfo::pointer_t info);
	void handle_error(uint32_t error);
	void handle_sync(tetio::SyncState::pointer_t sync_state);
	void handle_gaze(tetio::GazeDataItem::pointer_t gaze_data);

	bool calibrating;
	MainLoop main_loop;
	QTimer connection_timer;

	tetio::EyeTrackerBrowser::pointer_t browser;
	tetio::EyeTrackerFactory::pointer_t factory;
	tetio::EyeTracker::pointer_t tracker;

	tetio::Clock clock;
	tetio::SyncManager::pointer_t sync_manager;

	bool connected() const;
	QString status() const;
	void track(bool enable);
};

#endif
