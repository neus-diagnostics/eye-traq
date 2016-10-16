#include "browser.h"

#include <QTextStream>
#include <QtDebug>

#include <tobii/sdk/cpp/EyeTrackerBrowserFactory.hpp>

Browser::Browser(MainLoop &main_loop)
	: QObject{},
	  eyetracker{nullptr},
	  main_loop{main_loop},
	  browser{tetio::EyeTrackerBrowserFactory::createBrowser(main_loop.thread)}
{
	connection_timer.setInterval(500);
	connection_timer.setSingleShot(false);

	connect(this, &Browser::browsed, this, &Browser::on_browsed, Qt::QueuedConnection);
	connect(&connection_timer, &QTimer::timeout, this, &Browser::try_connect);

	browser->addEventListener(boost::bind(&Browser::handle_browse, this, _1, _2));
	browser->start();
}

Browser::~Browser()
{
	browser->stop();
}

void Browser::try_connect()
{
	try {
		eyetracker = factory->createEyeTracker(main_loop.thread);

		eyetracker->addConnectionErrorListener(
				boost::bind(&Browser::handle_error, this, _1));
		eyetracker->addGazeDataReceivedListener(
				boost::bind(&Browser::handle_gaze, this, _1));

		connection_timer.stop();
		factory = nullptr;
		emit connected();
	} catch (...) {
	}
}

void Browser::handle_browse(tetio::EyeTrackerBrowser::event_type_t type,
                     tetio::EyeTrackerInfo::pointer_t info)
{
	emit browsed(new BrowseEvent{type, info});
}

void Browser::handle_error(uint32_t error)
{
	qWarning() << "connection error:" << error;
	emit disconnected();
	eyetracker = nullptr;
}

void Browser::handle_gaze(tetio::GazeDataItem::pointer_t gaze)
{
	const auto &gaze_screen_l = gaze->leftGazePoint2d;
	const auto &eye_ucs_l = gaze->leftEyePosition3d;
	const auto &eye_track_l = gaze->leftEyePosition3dRelative;
	const auto &gaze_ucs_l = gaze->leftEyePosition3dRelative;

	const auto &gaze_screen_r = gaze->rightGazePoint2d;
	const auto &eye_ucs_r = gaze->rightEyePosition3d;
	const auto &eye_track_r = gaze->rightEyePosition3dRelative;
	const auto &gaze_ucs_r = gaze->rightEyePosition3dRelative;

	QString left;
	QTextStream{&left} << 
                gaze->timestamp << '\t' << "left" << '\t' << gaze->leftValidity << '\t' <<
                gaze_screen_l.x << '\t' << gaze_screen_l.y << '\t' <<
                gaze->leftPupilDiameter << '\t' <<
                eye_ucs_l.x << '\t' << eye_ucs_l.y << '\t' << eye_ucs_l.z << '\t' <<
                eye_track_l.x << '\t' << eye_track_l.y << '\t' << eye_track_l.z << '\t' <<
                gaze_ucs_l.x << '\t' << gaze_ucs_l.y << '\t' << gaze_ucs_l.z;

	QString right;
	QTextStream{&right} << 
                gaze->timestamp << '\t' << "right" << '\t' << gaze->rightValidity << '\t' <<
                gaze_screen_r.x << '\t' << gaze_screen_r.y << '\t' <<
                gaze->leftPupilDiameter << '\t' <<
                eye_ucs_r.x << '\t' << eye_ucs_r.y << '\t' << eye_ucs_r.z << '\t' <<
                eye_track_r.x << '\t' << eye_track_r.y << '\t' << eye_track_r.z << '\t' <<
                gaze_ucs_r.x << '\t' << gaze_ucs_r.y << '\t' << gaze_ucs_r.z;

	emit gazed(left, right);
}

void Browser::on_browsed(BrowseEvent *event)
{
	switch (event->type) {
	case tetio::EyeTrackerBrowser::event_type_t::TRACKER_FOUND:
	case tetio::EyeTrackerBrowser::event_type_t::TRACKER_UPDATED:
		factory = event->info->getEyeTrackerFactory();
		connection_timer.start();
		break;
	case tetio::EyeTrackerBrowser::event_type_t::TRACKER_REMOVED:
		emit disconnected();
		eyetracker = nullptr;
		break;
	}
	delete event;
}
