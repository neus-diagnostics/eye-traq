#ifndef CALIBRATION_H
#define CALIBRATION_H

#include <QObject>
#include <QQmlEngine>

#include "browser.h"

class Calibrator : public QObject {
	Q_OBJECT
public:
	Calibrator(QQmlEngine &engine, Browser &browser);
	~Calibrator();

public slots:
	void start();
	void add_point();
	void stop();

private:
	QObject *view;
	QQmlEngine &engine;
	Browser &browser;

	int step;
};

#endif
