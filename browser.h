#ifndef BROWSER_H
#define BROWSER_H

#include <QLineF>
#include <QList>
#include <QObject>
#include <QTimer>
#include <QVector>

#include <tobii/sdk/cpp/GazeDataItem.hpp>
#include <tobii/sdk/cpp/EyeTracker.hpp>
#include <tobii/sdk/cpp/EyeTrackerBrowser.hpp>
#include <tobii/sdk/cpp/EyeTrackerFactory.hpp>
#include <tobii/sdk/cpp/EyeTrackerInfo.hpp>
namespace tetio = tobii::sdk::cpp;

#include "main_loop.h"

struct BrowseEvent : QObject {
	BrowseEvent(tetio::EyeTrackerBrowser::event_type_t type,
	            tetio::EyeTrackerInfo::pointer_t info)
		: QObject{}, type{type}, info{info}
	{
	}
	tetio::EyeTrackerBrowser::event_type_t type;
	tetio::EyeTrackerInfo::pointer_t info;
};

class Browser : public QObject {
	Q_OBJECT
public:
	Browser(MainLoop &main_loop);
	virtual ~Browser();

	QVector<QList<QLineF>> get_calibration();

	tetio::EyeTracker::pointer_t eyetracker;

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

	MainLoop &main_loop;

	tetio::EyeTrackerBrowser::pointer_t browser;
	tetio::EyeTrackerFactory::pointer_t factory;

	QTimer connection_timer;
};

#endif
