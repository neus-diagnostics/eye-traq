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
	if (browser.command("start_calibration")) {
		step = 0;
		QMetaObject::invokeMethod(view, "init");
	}
}

void Calibrator::add_point()
{
	static const QVector<QString> color{"red", "blue"};

	if (step > 0)
		browser.calibrate(points[step-1]);

	if (step < points.size()) {
		QMetaObject::invokeMethod(view, "move", Q_ARG(QVariant, points[step]));
		step++;
	} else {
		QString msg{"Calibration successful."};
		if (!browser.command("compute_calibration"))
			msg = "Calibration failed.";
		const auto calibration = browser.get_calibration();
		for (int i = 0; i < calibration.size(); i++) {
			const auto& eye = calibration[i];
			for (const auto& line : eye) {
				QMetaObject::invokeMethod(view, "addLine",
					Q_ARG(QVariant, line.p1()),
					Q_ARG(QVariant, line.p2()),
					Q_ARG(QVariant, color[i]));
			}
		}
		QMetaObject::invokeMethod(view, "end", Q_ARG(QVariant, msg));
		stop();
	}
}

void Calibrator::stop()
{
	browser.command("stop_calibration");
}
