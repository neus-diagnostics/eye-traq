#ifndef GAZE_H
#define GAZE_H

#include <QPointF>
#include <QVector3D>

#ifdef USE_TOBII
#include <tobii/sdk/cpp/GazeDataItem.hpp>
namespace tetio = tobii::sdk::cpp;
#endif

struct Gaze {
	Gaze();
#ifdef USE_TOBII
	Gaze(tetio::GazeDataItem::pointer_t gaze, qint64 time);
#endif

	qint64 time;
	quint64 eyetracker_time;

	unsigned int valid_l;
	float pupil_l;
	QPointF screen_l;
	QVector3D ucs_l;
	QVector3D eye_ucs_l;
	QVector3D eye_track_l;

	unsigned int valid_r;
	float pupil_r;
	QPointF screen_r;
	QVector3D ucs_r;
	QVector3D eye_ucs_r;
	QVector3D eye_track_r;
};

#endif
