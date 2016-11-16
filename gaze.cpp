#include "gaze.h"

#include <QDateTime>

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

// make qRegisterMetaType happy
Gaze::Gaze()
{
}

Gaze::Gaze(tetio::GazeDataItem::pointer_t gaze, qint64 time)
	: time{time},
	  eyetracker_time{gaze->timestamp},

	  valid_l{gaze->leftValidity},
	  pupil_l{gaze->leftPupilDiameter},
	  screen_l{point2_to_qpoint(gaze->leftGazePoint2d)},
	  ucs_l{point3_to_qvec(gaze->leftEyePosition3dRelative)},
	  eye_ucs_l{point3_to_qvec(gaze->leftEyePosition3d)},
	  eye_track_l{point3_to_qvec(gaze->leftEyePosition3dRelative)},

	  valid_r{gaze->rightValidity},
	  pupil_r{gaze->rightPupilDiameter},
	  screen_r{point2_to_qpoint(gaze->rightGazePoint2d)},
	  ucs_r{point3_to_qvec(gaze->rightEyePosition3dRelative)},
	  eye_ucs_r{point3_to_qvec(gaze->rightEyePosition3d)},
	  eye_track_r{point3_to_qvec(gaze->rightEyePosition3dRelative)}
{
}
