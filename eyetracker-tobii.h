// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright © 2017, 2018 Neus Diagnostics, d.o.o.

#ifndef EYETRACKER_TOBII_H
#define EYETRACKER_TOBII_H

#include "eyetracker.h"

#include <QByteArray>
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
	void connected(void *tracker, const QString &name, const float frequency);
public:
	EyetrackerTobiiHelper(const QString &path);
	~EyetrackerTobiiHelper();
public slots:
	void try_connect();
	void calibrate(void *tracker, const QPointF &point);
private:
	QThread thread;
	QString path;
};

class EyetrackerTobii : public Eyetracker {
	Q_OBJECT
public:
	EyetrackerTobii(const QString &path = "");
	virtual ~EyetrackerTobii();

public slots:
	bool calibrate(const QString &what);
	bool calibrate(const QPointF &point);
	QVariantList get_calibration();
	qint64 time();

private:
	TobiiResearchEyeTracker *tracker;
	QTimer connection_timer;

	bool calibrating;
	QVariantList calibration;

	bool connected() const;
	void track(bool enable);
	static void gaze_data_cb(TobiiResearchGazeData *gaze_data, void *self);
	static void notification_cb(TobiiResearchNotification *notification, void *self);

	EyetrackerTobiiHelper helper;
	void handle_connected(void *tracker, const QString &name, const float frequency);
};

#endif
