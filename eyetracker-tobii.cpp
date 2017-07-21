#include "eyetracker-tobii.h"

#include <QPointF>
#include <QUdpSocket>
#include <QVector3D>
#include <QtDebug>

#include <tobii/sdk/cpp/EyeTrackerBrowserFactory.hpp>
#include <tobii/sdk/cpp/GazeDataItem.hpp>
#include <tobii/sdk/cpp/Types.hpp>
namespace tetio = tobii::sdk::cpp;

EyetrackerTobii::EyetrackerTobii()
	: Eyetracker{}, calibrating{false},
	  factory{nullptr}, tracker{nullptr}, sync_manager{nullptr}
{
	connection_timer.setInterval(500);
	connection_timer.setSingleShot(false);

	connect(this, &EyetrackerTobii::browsed, this, &EyetrackerTobii::on_browsed, Qt::QueuedConnection);
	connect(&connection_timer, &QTimer::timeout, this, &EyetrackerTobii::try_connect);

	// if avahi is not running, bail out before creating the browser -
	// browser does throw on start in this case, but segfaults for some
	// (apparently boost-related) reason
	if (QUdpSocket{}.bind(QHostAddress::LocalHost, 5353))
		throw std::runtime_error{"avahi is not running"};

	main_loop.start();
	browser = tetio::EyeTrackerBrowserFactory::createBrowser(main_loop.thread);
	browser->addEventListener(boost::bind(&EyetrackerTobii::handle_browse, this, _1, _2));
	browser->start();
}

EyetrackerTobii::~EyetrackerTobii()
{
	browser->stop();
	main_loop.quit();
}

bool EyetrackerTobii::calibrate(const QString &what)
{
	if (!tracker)
		return false;
	try {
		if (what == "start" && !calibrating) {
			calibrating = true;
			tracker->startCalibration();
		} else if (what == "stop" && calibrating) {
			tracker->stopCalibration();
			calibrating = false;
		} else if (what == "compute" && calibrating) {
			tracker->computeCalibration();
		}
		return true;
	} catch (tobii::sdk::cpp::EyeTrackerException &e) {
		qWarning() << "error in EyeTracker::calibrate(" << what << ")"
			   << "; error code" << e.getErrorCode();
	} catch (...) {
		qWarning() << "error in EyeTracker::calibrate(" << what << ")";
	}
	return false;
}

bool EyetrackerTobii::calibrate(const QPointF &point)
{
	if (!tracker)
		return false;
	tracker->addCalibrationPoint({point.x(), point.y()});
	return true;
}

static inline QPointF point2_to_qpoint(const tetio::Point2d &p)
{
	return QPointF{static_cast<float>(p.x), static_cast<float>(p.y)};
}

static inline QVector3D point3_to_qvec(const tetio::Point3d &p)
{
	return QVector3D{
		static_cast<float>(p.x),
		static_cast<float>(p.y),
		static_cast<float>(p.z)
	};
}

QVariantList EyetrackerTobii::get_calibration()
{
	QVariantList lines;
	const auto calibration = tracker->getCalibration()->getPlotData();
	for (const auto &point : *calibration) {
		const QPointF start{point2_to_qpoint(point.truePosition)};
		if (point.leftStatus == 1)
			lines.push_back(QVariantMap{
				{"eye", "left"},
				{"from", start},
				{"to", point2_to_qpoint(point.leftMapPosition)},
				{"status", point.leftStatus}
			});
		if (point.rightStatus == 1)
			lines.push_back(QVariantMap{
				{"eye", "right"},
				{"from", start},
				{"to", point2_to_qpoint(point.rightMapPosition)},
				{"status", point.rightStatus}
			});
	}
	return lines;
}

qint64 EyetrackerTobii::time()
{
	return clock.getTime();
}

bool EyetrackerTobii::connected() const
{
	return sync_manager &&
	       sync_manager->getSyncState()->getSyncStateFlag() == tetio::SyncState::SYNCHRONIZED;
}

QString EyetrackerTobii::status() const
{
	if (connected())
		return "Connected to eyetracker.";
	if (factory || tracker)
		return "Connecting…";
	return "Eyetracker not found.";
}

void EyetrackerTobii::track(bool enable)
try {
	if (tracker && enable != tracking) {
		if (enable)
			tracker->startTracking();
		else
			tracker->stopTracking();
		tracking = enable;
		emit trackingChanged();
	}
} catch (tobii::sdk::cpp::EyeTrackerException &e) {
	qWarning() << "error in Eyetracker::track(" << enable << ")"
		   << "; error code" << e.getErrorCode();
} catch (...) {
	qWarning() << "error in Eyetracker::track(" << enable << ")";
}

void EyetrackerTobii::try_connect()
try {
	tracker = factory->createEyeTracker(main_loop.thread);

	tracker->addConnectionErrorListener(
		boost::bind(&EyetrackerTobii::handle_error, this, _1));
	tracker->addGazeDataReceivedListener(
		boost::bind(&EyetrackerTobii::handle_gaze, this, _1));

	sync_manager = factory->createSyncManager(clock, main_loop.thread);
	sync_manager->addSyncStateChangedListener(
		boost::bind(&EyetrackerTobii::handle_sync, this, _1));

	connection_timer.stop();
	factory = nullptr;
	calibrating = false;
	if (tracking) {
		tracking = false;
		emit trackingChanged();
	}
} catch (...) {
}

void EyetrackerTobii::handle_browse(tetio::EyeTrackerBrowser::event_type_t type,
                     tetio::EyeTrackerInfo::pointer_t info)
{
	emit browsed(new BrowseEvent{type, info});
}

void EyetrackerTobii::handle_error(uint32_t)
{
	factory = nullptr;
	tracker = nullptr;
	sync_manager = nullptr;
	emit statusChanged();
}

void EyetrackerTobii::handle_sync(tetio::SyncState::pointer_t)
{
	emit statusChanged();
}

void EyetrackerTobii::handle_gaze(tetio::GazeDataItem::pointer_t gaze_data)
{
	Gaze g{};
	g.time = sync_manager->remoteToLocal(gaze_data->timestamp);
	g.eyetracker_time = gaze_data->timestamp;

	g.valid_l = gaze_data->leftValidity;
	g.pupil_l = gaze_data->leftPupilDiameter;
	g.screen_l = point2_to_qpoint(gaze_data->leftGazePoint2d);
	g.ucs_l = point3_to_qvec(gaze_data->leftEyePosition3dRelative);
	g.eye_ucs_l = point3_to_qvec(gaze_data->leftEyePosition3d);
	g.eye_track_l = point3_to_qvec(gaze_data->leftEyePosition3dRelative);

	g.valid_r = gaze_data->rightValidity;
	g.pupil_r = gaze_data->rightPupilDiameter;
	g.screen_r = point2_to_qpoint(gaze_data->rightGazePoint2d);
	g.ucs_r = point3_to_qvec(gaze_data->rightEyePosition3dRelative);
	g.eye_ucs_r = point3_to_qvec(gaze_data->rightEyePosition3d);
	g.eye_track_r = point3_to_qvec(gaze_data->rightEyePosition3dRelative);

	emit gaze(g);
	emit gazePoint(g.screen_l);
	emit gazePoint(g.screen_r);
}

void EyetrackerTobii::on_browsed(BrowseEvent *event)
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
