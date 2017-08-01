#ifndef EYETRACKER_TOBII_H
#define EYETRACKER_TOBII_H

#include "eyetracker.h"

#include <QString>
#include <QThread>
#include <QTimer>

extern "C" {
#include <tobii_research.h>
#include <tobii_research_eyetracker.h>
#include <tobii_research_streams.h>
}

class EyetrackerTobiiHelper : public QObject {
	Q_OBJECT
signals:
	void connected(void *tracker, const QString &address);
public slots:
	void try_connect();
	void calibrate(void *tracker, const QPointF &point);
private:
	QString address;
};

class EyetrackerTobii : public Eyetracker {
	Q_OBJECT
public:
	EyetrackerTobii();
	virtual ~EyetrackerTobii();

public slots:
	bool calibrate(const QString &what);
	bool calibrate(const QPointF &point);
	QVariantList get_calibration();
	qint64 time();

private:
	QTimer connection_timer;
	EyetrackerTobiiHelper helper;
	QThread helper_thread;

	TobiiResearchEyeTracker *tracker;

	bool calibrating;
	QVariantList calibration;

	static void gaze_data_cb(TobiiResearchGazeData *gaze_data, void *self);

	void handle_connected(void *tracker, const QString &name);
	bool connected() const;
	void track(bool enable);
};

#endif
