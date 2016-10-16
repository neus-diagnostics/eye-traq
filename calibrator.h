#ifndef CALIBRATION_H
#define CALIBRATION_H

#include <QObject>
#include <QQmlEngine>

#include <tobii/sdk/cpp/Calibration.hpp>
namespace tetio = tobii::sdk::cpp;

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
	void draw_lines(const tetio::Calibration::plot_data_vector_t &data);

	QObject *view;
	QQmlEngine &engine;
	Browser &browser;

	int step;
};

#endif
