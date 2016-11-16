#include "eyetracker.h"

#include <QTextStream>
#include <QVector4D>
#include <QtDebug>

#ifdef USE_TOBII
#include <tobii/sdk/cpp/EyeTrackerBrowserFactory.hpp>
#include <tobii/sdk/cpp/GazeDataItem.hpp>
namespace tetio = tobii::sdk::cpp;
#endif

#include "gaze.h"

Eyetracker::Eyetracker()
	: QObject{}
{
#ifdef USE_TOBII
	tracker = nullptr;
	connection_timer.setInterval(500);
	connection_timer.setSingleShot(false);

	connect(this, &Eyetracker::browsed, this, &Eyetracker::on_browsed, Qt::QueuedConnection);
	connect(&connection_timer, &QTimer::timeout, this, &Eyetracker::try_connect);

	main_loop.start();
	browser = tetio::EyeTrackerBrowserFactory::createBrowser(main_loop.thread);
	browser->addEventListener(boost::bind(&Eyetracker::handle_browse, this, _1, _2));
	browser->start();
#endif
}

Eyetracker::~Eyetracker()
{
#ifdef USE_TOBII
	browser->stop();
	main_loop.quit();
#endif
}

bool Eyetracker::command(const QString &what)
{
#ifdef USE_TOBII
	if (!tracker)
		return false;
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
	} catch (tobii::sdk::cpp::EyeTrackerException &e) {
		qWarning() << "eyetracker error while running" << what
			   << "; error code" << e.getErrorCode();
		return false;
	} catch (...) {
		qWarning() << "eyetracker error while running" << what;
		return false;
	}
#endif
	return true;
}

bool Eyetracker::calibrate(const QPointF &point)
{
#ifdef USE_TOBII
	if (!tracker)
		return false;
	tracker->addCalibrationPoint({point.x(), point.y()});
#endif
	return true;
}

QList<QVariant> Eyetracker::get_calibration()
{
	QList<QVariant> lines;
#ifdef USE_TOBII
	const auto calibration = tracker->getCalibration()->getPlotData();
	for (size_t i = 0; i < calibration->size(); i++) {
		const auto& p = calibration->at(i);
		const QPointF real{p.truePosition.x, p.truePosition.y};
		if (p.leftStatus == 1)
			lines.push_back(QVector4D{
				p.truePosition.x, p.truePosition.y,
				p.leftMapPosition.x, p.leftMapPosition.y});
		if (p.rightStatus == 1)
			lines.push_back(QVector4D{
				p.truePosition.x, p.truePosition.y,
				p.rightMapPosition.x, p.rightMapPosition.y});
	}
#endif
	return lines;
}

#ifdef USE_TOBII
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

void Eyetracker::handle_gaze(tetio::GazeDataItem::pointer_t tobii_gaze)
{
	const Gaze g{tobii_gaze};
	emit gaze(g);
	emit gazePoint(g.screen_l);
	emit gazePoint(g.screen_r);
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
#endif
