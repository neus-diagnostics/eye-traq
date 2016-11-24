#include "eyetracker.h"

#include <QTextStream>
#include <QUdpSocket>
#include <QtDebug>

#ifdef USE_TOBII
#include <tobii/sdk/cpp/EyeTrackerBrowserFactory.hpp>
#include <tobii/sdk/cpp/GazeDataItem.hpp>
#include "tobii.h"
namespace tetio = tobii::sdk::cpp;
#else
#include <QDateTime>
#endif

#include "gaze.h"

Eyetracker::Eyetracker()
	: QObject{}, tracking{false}
{
#ifdef USE_TOBII
	factory = nullptr;
	tracker = nullptr;
	sync_manager = nullptr;

	connection_timer.setInterval(500);
	connection_timer.setSingleShot(false);

	connect(this, &Eyetracker::browsed, this, &Eyetracker::on_browsed, Qt::QueuedConnection);
	connect(&connection_timer, &QTimer::timeout, this, &Eyetracker::try_connect);

	// if avahi is not running, bail out before creating the browser -
	// browser does throw on start in this case, but segfaults for some
	// (apparently boost-related) reason
	if (QUdpSocket{}.bind(QHostAddress::LocalHost, 5353))
		throw std::runtime_error{"avahi is not running"};

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

bool Eyetracker::calibrate(const QString &what)
{
#ifdef USE_TOBII
	if (!tracker)
		return false;
	try {
		if (what == "start")
			tracker->startCalibration();
		else if (what == "stop")
			tracker->stopCalibration();
		else if (what == "compute")
			tracker->computeCalibration();
		return true;
	} catch (tobii::sdk::cpp::EyeTrackerException &e) {
		qWarning() << "error in EyeTracker::calibrate(" << what << ")"
			   << "; error code" << e.getErrorCode();
	} catch (...) {
		qWarning() << "error in EyeTracker::calibrate(" << what << ")";
	}
#endif
	return false;
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

QVariantList Eyetracker::get_calibration()
{
	QVariantList lines;
#ifdef USE_TOBII
	const auto calibration = tracker->getCalibration()->getPlotData();
	for (const auto &point : *calibration) {
		const QPointF start{point2_to_qpoint(point.truePosition)};
		if (point.leftStatus == 1)
			lines.push_back(QVariantMap{
				{"eye", "left"},
				{"from", start},
				{"to", point2_to_qpoint(point.leftMapPosition)}
			});
		if (point.rightStatus == 1)
			lines.push_back(QVariantMap{
				{"eye", "right"},
				{"from", start},
				{"to", point2_to_qpoint(point.rightMapPosition)}
			});
	}
#endif
	return lines;
}

qint64 Eyetracker::time()
{
#ifdef USE_TOBII
	return clock.getTime();
#else
	return QDateTime::currentMSecsSinceEpoch();
#endif
}

bool Eyetracker::connected() const
{
#ifdef USE_TOBII
	return sync_manager &&
	       sync_manager->getSyncState()->getSyncStateFlag() == tetio::SyncState::SYNCHRONIZED;
#else
	return true;
#endif
}

QString Eyetracker::status() const
{
	if (connected())
		return "Connected to eyetracker.";
#ifdef USE_TOBII
	if (factory || tracker)
		return "Connecting…";
#endif
	return "Eyetracker not found.";
}

void Eyetracker::track(bool enable)
try {
#ifdef USE_TOBII
	if (tracker && enable != tracking) {
		if (enable)
			tracker->startTracking();
		else
			tracker->stopTracking();
		tracking = enable;
	}
} catch (tobii::sdk::cpp::EyeTrackerException &e) {
	qWarning() << "error in Eyetracker::track(" << enable << ")"
		   << "; error code" << e.getErrorCode();
#endif
} catch (...) {
	qWarning() << "error in Eyetracker::track(" << enable << ")";
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

		sync_manager = factory->createSyncManager(clock, main_loop.thread);
		sync_manager->addSyncStateChangedListener(
			boost::bind(&Eyetracker::handle_sync, this, _1));

		connection_timer.stop();
		factory = nullptr;
		tracking = false;
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
	factory = nullptr;
	tracker = nullptr;
	sync_manager = nullptr;
	emit statusChanged();
}

void Eyetracker::handle_sync(tetio::SyncState::pointer_t)
{
	emit statusChanged();
}

void Eyetracker::handle_gaze(tetio::GazeDataItem::pointer_t gaze_data)
{
	const Gaze g{gaze_data, sync_manager->remoteToLocal(gaze_data->timestamp)};
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
		factory = nullptr;
		tracker = nullptr;
		sync_manager = nullptr;
		break;
	}
	delete event;
	emit statusChanged();
}
#endif
