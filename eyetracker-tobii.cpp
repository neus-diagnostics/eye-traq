#include "eyetracker-tobii.h"

#include <cstddef>
#include <utility>

#include <QPointF>
#include <QVector3D>
#include <QtDebug>

extern "C" {
#include <tobii_research_calibration.h>
}

void Watcher::try_connect()
{
	if (address.isEmpty()) {
		TobiiResearchEyeTrackers* eyetrackers{nullptr};
		auto status = tobii_research_find_all_eyetrackers(&eyetrackers);
		if (status != TOBII_RESEARCH_STATUS_OK)
			return;

		if (eyetrackers->count > 0) {
			// just take the first eye tracker
			auto tracker = eyetrackers->eyetrackers[0];

			char *device_address;
			char *device_name;
			tobii_research_get_address(tracker, &device_address);
			tobii_research_get_device_name(tracker, &device_name);
			address = device_address;
			emit connected(tracker, QString{device_name});
			tobii_research_free_string(device_address);
			tobii_research_free_string(device_name);
		}
		tobii_research_free_eyetrackers(eyetrackers);
	} else {
		TobiiResearchEyeTracker* t{nullptr};
		auto status = tobii_research_get_eyetracker(address.toStdString().c_str(), &t);
		if (status == TOBII_RESEARCH_STATUS_OK)
			return;
		address.clear();
		emit connected(nullptr, "");
	}
}

EyetrackerTobii::EyetrackerTobii()
	: Eyetracker{}, tracker{nullptr}, calibrating{false}
{
	connect(&watcher, &Watcher::connected, this, &EyetrackerTobii::handle_connected);

	watcher.moveToThread(&watcher_thread);
	watcher_thread.start();

	connection_timer.setInterval(1000);
	connection_timer.setSingleShot(false);
	connect(&connection_timer, &QTimer::timeout, &watcher, &Watcher::try_connect);
	connection_timer.start();
}

EyetrackerTobii::~EyetrackerTobii()
{
	track(false);
	watcher_thread.quit();
	watcher_thread.wait(1000);
}

static inline QPointF point2_to_qpoint(const TobiiResearchNormalizedPoint2D &p)
{
	return QPointF{p.x, p.y};
}

static inline QVector3D point3_to_qvec(const TobiiResearchPoint3D &p)
{
	return QVector3D{p.x, p.y, p.z};
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
			for (std::size_t i = 0; i < result->calibration_point_count; i++) {
				const auto point = result->calibration_points[i];
				const QPointF real{point2_to_qpoint(point.position_on_display_area)};
				for (std::size_t j = 0; j < point.calibration_sample_count; j++) {
					const auto left = point.calibration_samples[j].left_eye;
					calibration.push_back(QVariantMap{
						{"eye", "left"},
						{"from", real},
						{"to", point2_to_qpoint(left.position_on_display_area)},
						{"valid", left.validity == TOBII_RESEARCH_CALIBRATION_EYE_VALIDITY_VALID_AND_USED}
					});

					const auto right = point.calibration_samples[j].right_eye;
					calibration.push_back(QVariantMap{
						{"eye", "right"},
						{"from", real},
						{"to", point2_to_qpoint(right.position_on_display_area)},
						{"valid", left.validity == TOBII_RESEARCH_CALIBRATION_EYE_VALIDITY_VALID_AND_USED}
					});
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
	// TODO x2-60 always succeeds here, check for other trackers
	// TODO this blocks, try moving to other thread
	tobii_research_screen_based_calibration_collect_data(tracker, point.x(), point.y());
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

QString EyetrackerTobii::status() const
{
	return connected() ?
		"Connected to eyetracker." :
		"Eyetracker not found.";
}

void EyetrackerTobii::gaze_data_cb(TobiiResearchGazeData *gaze_data, void *self)
{
	for (const auto &eye_data : {
			std::make_pair("left", gaze_data->left_eye),
			std::make_pair("right", gaze_data->right_eye)}) {
		const auto &data = eye_data.second;
		static_cast<EyetrackerTobii*>(self)->emit gaze(QVariantMap{
			{"time", QVariant::fromValue(gaze_data->system_time_stamp)},
			{"eyetracker_time", QVariant::fromValue(gaze_data->device_time_stamp)},
			{"eye", eye_data.first},
			{"pupil_valid", data.pupil_data.validity == TOBII_RESEARCH_VALIDITY_VALID},
			{"gaze_valid", data.gaze_point.validity == TOBII_RESEARCH_VALIDITY_VALID},
			{"eye_valid", data.gaze_origin.validity == TOBII_RESEARCH_VALIDITY_VALID},
			{"pupil_diameter", data.pupil_data.diameter},
			{"gaze_screen", point2_to_qpoint(data.gaze_point.position_on_display_area)},
			{"gaze_ucs", point3_to_qvec(data.gaze_point.position_in_user_coordinates)},
			{"eye_ucs", point3_to_qvec(data.gaze_origin.position_in_user_coordinates)},
			{"eye_trackbox", point3_to_qvec(data.gaze_origin.position_in_track_box_coordinates)}
		});
	}
}

void EyetrackerTobii::handle_connected(void *tracker, const QString &name)
{
	if (tracker != this->tracker) {
		this->tracker = static_cast<TobiiResearchEyeTracker*>(tracker);
		this->name = name;
		calibrating = false;
		if (tracking) {
			tracking = false;
			emit trackingChanged();
		}
		emit statusChanged();
	}
}

void EyetrackerTobii::track(bool enable)
{
	if (tracker && enable != tracking) {
		if (enable)
			tobii_research_subscribe_to_gaze_data(tracker, gaze_data_cb, this);
		else
			tobii_research_unsubscribe_from_gaze_data(tracker, gaze_data_cb);
		tracking = enable;
		emit trackingChanged();
	}
}
