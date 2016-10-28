#include "eyetracker.h"

#include <QTextStream>
#include <QtDebug>

#include <tobii/sdk/cpp/EyeTrackerBrowserFactory.hpp>

Eyetracker::Eyetracker()
	: QObject{},
	  tracker{nullptr}
{
	connection_timer.setInterval(500);
	connection_timer.setSingleShot(false);

	connect(this, &Eyetracker::browsed, this, &Eyetracker::on_browsed, Qt::QueuedConnection);
	connect(&connection_timer, &QTimer::timeout, this, &Eyetracker::try_connect);

	main_loop.start();
	eyetracker = tetio::EyeTrackerBrowserFactory::createBrowser(main_loop.thread);
	eyetracker->addEventListener(boost::bind(&Eyetracker::handle_browse, this, _1, _2));
	eyetracker->start();
}

Eyetracker::~Eyetracker()
{
	eyetracker->stop();
	main_loop.quit();
}

bool Eyetracker::command(const QString &what)
{
	if (tracker) {
		try {
			if (what == "start_calibration")
				tracker->startCalibration();
			else if (what == "stop_calibration")
				tracker->stopCalibration();
			else if (what == "compute_calibration")
				tracker->computeCalibration();
			else if (what == "start_tracking")
				tracker->startTracking();
			else if (what == "stop_tracking")
				tracker->stopTracking();
			return true;
		} catch (...) {
			qDebug() << "got exception when running" << what;
		}
	}
	return false;
}

bool Eyetracker::calibrate(const QPointF &point)
{
	if (!tracker)
		return false;
	tracker->addCalibrationPoint({point.x(), point.y()});
	return true;
}

QVector<QList<QLineF>> Eyetracker::get_calibration()
{
	QVector<QList<QLineF>> lines{{}, {}};
	const auto calibration = tracker->getCalibration()->getPlotData();
	for (size_t i = 0; i < calibration->size(); i++) {
		const auto& p = calibration->at(i);
		const QPointF real{p.truePosition.x, p.truePosition.y};
		if (p.leftStatus == 1)
			lines[0].append({real,
				{p.leftMapPosition.x, p.leftMapPosition.y}});
		if (p.rightStatus == 1)
			lines[1].append({real,
				{p.rightMapPosition.x, p.rightMapPosition.y}});
	}
	return lines;
}

void Eyetracker::try_connect()
{
	try {
		tracker = factory->createEyeTracker(main_loop.thread);

		tracker->addConnectionErrorListener(
			boost::bind(&Eyetracker::handle_error, this, _1));
		tracker->addGazeDataReceivedListener(
			boost::bind(&Eyetracker::handle_gaze, this, _1));

		connection_timer.stop();
		factory = nullptr;
		emit connected();
	} catch (...) {
	}
}

void Eyetracker::handle_browse(tetio::EyeTrackerBrowser::event_type_t type,
                     tetio::EyeTrackerInfo::pointer_t info)
{
	emit browsed(new BrowseEvent{type, info});
}

void Eyetracker::handle_error(uint32_t error)
{
	qWarning() << "connection error:" << error;
	emit disconnected();
	tracker = nullptr;
}

void Eyetracker::handle_gaze(tetio::GazeDataItem::pointer_t gaze)
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

void Eyetracker::on_browsed(BrowseEvent *event)
{
	switch (event->type) {
	case tetio::EyeTrackerBrowser::event_type_t::TRACKER_FOUND:
	case tetio::EyeTrackerBrowser::event_type_t::TRACKER_UPDATED:
		factory = event->info->getEyeTrackerFactory();
		connection_timer.start();
		break;
	case tetio::EyeTrackerBrowser::event_type_t::TRACKER_REMOVED:
		emit disconnected();
		tracker = nullptr;
		break;
	}
	delete event;
}
