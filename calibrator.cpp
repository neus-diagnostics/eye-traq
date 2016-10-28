#include "calibrator.h"

#include <QMetaObject>
#include <QPointF>
#include <QQmlComponent>
#include <QVector>
#include <QtDebug>

static QVector<QPointF> points{
	QPointF{0.1f, 0.1f},
	QPointF{0.9f, 0.1f},
	QPointF{0.5f, 0.5f},
	QPointF{0.9f, 0.9f},
	QPointF{0.1f, 0.9f},
};

Calibrator::Calibrator(QQmlEngine &engine, Browser &browser)
	: QObject{}, engine{engine}, browser{browser}
{
	QQmlComponent component(&engine, QUrl("qrc:/calibrator.qml"));
	if (component.status() == QQmlComponent::Ready) {
	        view = component.create();
	} else {
	        for (const auto &e : component.errors())
	                qWarning() << e;
	}
}

Calibrator::~Calibrator()
{
	delete view;
}

void Calibrator::start()
{
	if (!browser.eyetracker)
		return;
	step = 0;
	browser.eyetracker->startCalibration();
	QMetaObject::invokeMethod(view, "init");
}

void Calibrator::add_point()
{
	if (step > 0) {
		const auto &point = points[step-1];
		browser.eyetracker->addCalibrationPoint(
				tetio::Point2d{point.x(), point.y()});
	}
	if (step < points.size()) {
		QMetaObject::invokeMethod(view, "move", Q_ARG(QVariant, points[step]));
		step++;
	} else {
		QString msg{"Calibration successful."};
		try {
			browser.eyetracker->computeCalibration();
			auto calib = browser.eyetracker->getCalibration();
			auto data = calib->getPlotData();
			for (size_t i = 0; i < data->size(); i++) {
				tetio::CalibrationPlotItem p = data->at(i);
				if (p.leftStatus == 1) {
					QPointF from{p.truePosition.x, p.truePosition.y};
					QPointF to{p.leftMapPosition.x, p.leftMapPosition.y};
					QMetaObject::invokeMethod(view, "addLine",
						Q_ARG(QVariant, from), Q_ARG(QVariant, to),
						Q_ARG(QVariant, "red"));
				}
				if (p.rightStatus == 1) {
					QPointF from{p.truePosition.x, p.truePosition.y};
					QPointF to{p.rightMapPosition.x, p.rightMapPosition.y};
					QMetaObject::invokeMethod(view, "addLine",
						Q_ARG(QVariant, from), Q_ARG(QVariant, to),
						Q_ARG(QVariant, "blue"));
				}
			}
		} catch (tetio::EyeTrackerException) {
			msg = "Calibration failed.";
		}
		QMetaObject::invokeMethod(view, "end", Q_ARG(QVariant, msg));
		stop();
	}
}

void Calibrator::stop()
{
	try {
		browser.eyetracker->stopCalibration();
	} catch (...) {
	}
}
