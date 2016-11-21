#include "gaze.h"

#include "tobii.h"

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
