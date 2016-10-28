#ifndef CALIBRATION_H
#define CALIBRATION_H

#include <QObject>
#include <QQmlEngine>

#include "eyetracker.h"

class Calibrator : public QObject {
	Q_OBJECT
public:
	Calibrator(QQmlEngine &engine, Eyetracker &eyetracker);
	~Calibrator();

public slots:
	void start();
	void add_point();
	void stop();

private:
	QObject *view;
	QQmlEngine &engine;
	Eyetracker &eyetracker;

	int step;
};

#endif
