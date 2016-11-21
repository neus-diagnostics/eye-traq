#include "eyetracker.h"

#include <QTextStream>
#include <QUdpSocket>
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
		return true;
	} catch (tobii::sdk::cpp::EyeTrackerException &e) {
		qWarning() << "eyetracker error while running" << what
			   << "; error code" << e.getErrorCode();
	} catch (...) {
		qWarning() << "eyetracker error while running" << what;
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

qint64 Eyetracker::time()
{
	return clock.getTime();
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
	} catch (...) {
	}
}

bool Eyetracker::connected() const
{
	return tracker && sync_manager &&
	       sync_manager->getSyncState()->getSyncStateFlag() == tetio::SyncState::SYNCHRONIZED;
}

QString Eyetracker::status() const
{
	if (connected()) {
		const auto &info = tracker->getUnitInfo();
		return QString::fromStdString("Connected to " + info->model + ".");
	}
	if (factory || tracker)
		return "Connecting…";
	return "Not connected.";
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

void Eyetracker::handle_sync(tetio::SyncState::pointer_t sync_state)
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
