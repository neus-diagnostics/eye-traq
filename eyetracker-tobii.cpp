#include "eyetracker-tobii.h"

#include <cmath>
#include <cstddef>
#include <stdexcept>
#include <utility>

#include <QFile>
#include <QPointF>
#include <QVector3D>
#include <QtDebug>

extern "C" {
#include <tobii_research_calibration.h>
}

EyetrackerTobii::EyetrackerTobii(const QString &path)
	: Eyetracker{}, tracker{nullptr}, calibrating{false}, helper{path}
{
	connect(&helper, &EyetrackerTobiiHelper::connected, this, &EyetrackerTobii::handle_connected);
	connect(&connection_timer, &QTimer::timeout, &helper, &EyetrackerTobiiHelper::try_connect);
	connection_timer.setInterval(3000);
	connection_timer.setSingleShot(false);
	connection_timer.start();
}

EyetrackerTobii::~EyetrackerTobii()
{
	track(false);
}

// Tobii SDK occasionally returns weird NaNs that crash QML
static inline float nanify(const float num)
{
	return std::isnan(num) ? NAN : num;
}

static inline QPointF point2_to_qpoint(const TobiiResearchNormalizedPoint2D &p)
{
	return QPointF{nanify(p.x), nanify(p.y)};
}

static inline QVector3D point3_to_qvec(const TobiiResearchPoint3D &p)
{
	return QVector3D{nanify(p.x), nanify(p.y), nanify(p.z)};
}

bool EyetrackerTobii::calibrate(const QString &what)
{
	if (!tracker)
		return false;

	if (what == "start" && !calibrating) {
		if (tobii_research_screen_based_calibration_enter_calibration_mode(tracker) != TOBII_RESEARCH_STATUS_OK)
			return false;
		calibrating = true;
		return true;

	} else if (what == "stop" && calibrating) {
		if (tobii_research_screen_based_calibration_leave_calibration_mode(tracker) != TOBII_RESEARCH_STATUS_OK)
			return false;
		calibrating = false;
		return true;

	} else if (what == "compute" && calibrating) {
		calibration.clear();
		TobiiResearchCalibrationResult* result{nullptr};
		const auto status = tobii_research_screen_based_calibration_compute_and_apply(tracker, &result);

		if (status == TOBII_RESEARCH_STATUS_OK &&
		    result->status == TOBII_RESEARCH_CALIBRATION_SUCCESS) {
			// store calibration result
			for (std::size_t i = 0; i < result->calibration_point_count; i++) {
				const auto point = result->calibration_points[i];
				const QPointF real{point2_to_qpoint(point.position_on_display_area)};
				for (std::size_t j = 0; j < point.calibration_sample_count; j++) {
					for (const auto &eye : {
							std::make_pair("left", point.calibration_samples[j].left_eye),
							std::make_pair("right", point.calibration_samples[j].right_eye)}) {
						calibration.push_back(QVariantMap{
							{"eye", eye.first},
							{"from", real},
							{"to", point2_to_qpoint(eye.second.position_on_display_area)},
							{"valid", eye.second.validity == TOBII_RESEARCH_CALIBRATION_EYE_VALIDITY_VALID_AND_USED}
						});
					}
				}
			}
		}
		tobii_research_free_screen_based_calibration_result(result);
		return !calibration.isEmpty();
	}

	return false;
}

bool EyetrackerTobii::calibrate(const QPointF &point)
{
	if (!tracker)
		return false;
	// Tobii SDK blocks here, so call it in the helper thread
	QMetaObject::invokeMethod(&helper, "calibrate", Qt::AutoConnection,
		Q_ARG(void*, tracker), Q_ARG(QPointF, point));
	return true;
}

QVariantList EyetrackerTobii::get_calibration()
{
	return calibration;
}

qint64 EyetrackerTobii::time()
{
	int64_t t{0};
	tobii_research_get_system_time_stamp(&t);
	return qint64{t};
}

bool EyetrackerTobii::connected() const
{
	return tracker;
}

void EyetrackerTobii::gaze_data_cb(TobiiResearchGazeData *gaze_data, void *self)
{
	QVariantMap info{
		{"time", QVariant::fromValue(gaze_data->system_time_stamp)},
		{"eyetracker_time", QVariant::fromValue(gaze_data->device_time_stamp)}
	};
	for (const auto &eye_data : {
			std::make_pair("left", gaze_data->left_eye),
			std::make_pair("right", gaze_data->right_eye)}) {
		const auto &data = eye_data.second;
		info[eye_data.first] = QVariantMap{
			{"pupil_valid", data.pupil_data.validity == TOBII_RESEARCH_VALIDITY_VALID},
			{"gaze_valid", data.gaze_point.validity == TOBII_RESEARCH_VALIDITY_VALID},
			{"eye_valid", data.gaze_origin.validity == TOBII_RESEARCH_VALIDITY_VALID},
			{"pupil_diameter", nanify(data.pupil_data.diameter)},
			{"gaze_screen", point2_to_qpoint(data.gaze_point.position_on_display_area)},
			{"gaze_ucs", point3_to_qvec(data.gaze_point.position_in_user_coordinates)},
			{"eye_ucs", point3_to_qvec(data.gaze_origin.position_in_user_coordinates)},
			{"eye_trackbox", point3_to_qvec(data.gaze_origin.position_in_track_box_coordinates)}
		};
	}
	static_cast<EyetrackerTobii*>(self)->emit gaze(info);
}

void EyetrackerTobii::notification_cb(TobiiResearchNotification* notification, void* self)
{
	if (notification->notification_type == TOBII_RESEARCH_NOTIFICATION_CONNECTION_LOST)
		static_cast<EyetrackerTobii*>(self)->helper.emit connected(nullptr, "", 0.0f);
}

void EyetrackerTobii::handle_connected(void *trackerp, const QString &name, const float frequency)
{
	TobiiResearchEyeTracker *tracker = static_cast<TobiiResearchEyeTracker*>(trackerp);
	if (tracker) {
		connection_timer.stop();
		tobii_research_subscribe_to_notifications(tracker, &notification_cb, this);
	} else {
		tobii_research_unsubscribe_from_notifications(this->tracker, &notification_cb);
		connection_timer.start();
	}
	this->tracker = tracker;
	this->name = name;
	this->frequency = frequency;
	calibrating = false;
	tracking = false;
	qInfo() << (tracker ? "Connected to" : "Disconnected from") << "eyetracker" << this->name;
	emit statusChanged();
}

void EyetrackerTobii::track(bool enable)
{
	if (tracker && enable != tracking) {
		if (enable)
			tobii_research_subscribe_to_gaze_data(tracker, gaze_data_cb, this);
		else
			tobii_research_unsubscribe_from_gaze_data(tracker, gaze_data_cb);
		tracking = enable;
	}
}

EyetrackerTobiiHelper::EyetrackerTobiiHelper(const QString &path)
	: path{path}
{
	thread.start();
	moveToThread(&thread);
}

EyetrackerTobiiHelper::~EyetrackerTobiiHelper()
{
	thread.quit();
	thread.wait(10000);
}

void EyetrackerTobiiHelper::try_connect()
{
	TobiiResearchEyeTracker* tracker{nullptr};
	QString name;

	TobiiResearchEyeTrackers* eyetrackers{nullptr};
	auto status = tobii_research_find_all_eyetrackers(&eyetrackers);
	if (status != TOBII_RESEARCH_STATUS_OK)
		return;

	if (eyetrackers->count > 0) {
		// just take the first eye tracker
		tracker = eyetrackers->eyetrackers[0];
		tobii_research_free_eyetrackers(eyetrackers);

		// get serial number
		char *serial;
		tobii_research_get_serial_number(tracker, &serial);
		name = serial;
		tobii_research_free_string(serial);

		// load license data from file
		QFile license{path + "/share/keys/" + name + ".key"};
		if (!license.open(QIODevice::ReadOnly)) {
			qWarning() << "Could not open license" << license.fileName();
			return;
		}

		const QByteArray data{license.readAll()};
		const void* key = data.data();
		size_t size = data.size();

		qInfo() << "Applying license" << license.fileName();
		TobiiResearchLicenseValidationResult result{TOBII_RESEARCH_LICENSE_VALIDATION_RESULT_OK};
		status = tobii_research_apply_licenses(tracker, &key, &size, &result, 1);
		if (status != TOBII_RESEARCH_STATUS_OK ||
		    result != TOBII_RESEARCH_LICENSE_VALIDATION_RESULT_OK) {
			qWarning() << "Failure applying license:" << status << result;
			return;
		}

		float frequency{};
		tobii_research_get_gaze_output_frequency(tracker, &frequency);

		emit connected(tracker, name, frequency);
	}
}

void EyetrackerTobiiHelper::calibrate(void *tracker, const QPointF &point)
{
	// TODO x2-60 always succeeds here, check for other trackers
	tobii_research_screen_based_calibration_collect_data(
		static_cast<TobiiResearchEyeTracker*>(tracker), point.x(), point.y());
}
