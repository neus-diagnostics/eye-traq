#include "eyetracker-mouse.h"

#include <QCursor>
#include <QPointF>

EyetrackerMouse::EyetrackerMouse(const QScreen *screen)
	: Eyetracker{}, screen{screen}
{
	connect(&timer, &QTimer::timeout, this, &EyetrackerMouse::do_gaze);
	timer.setTimerType(Qt::PreciseTimer);
	timer.setInterval(1000.0f / frequency);
	timer.setSingleShot(false);
	timer.start();
}

EyetrackerMouse::~EyetrackerMouse()
{
}

void EyetrackerMouse::do_gaze()
{
	const QPointF &cursor = QCursor::pos(screen);
	point.setX((cursor.x() - screen->geometry().x()) / screen->geometry().width());
	point.setY((cursor.y() - screen->geometry().y()) / screen->geometry().height());

	emit gaze(QVariantMap{
		{"time", QVariant::fromValue(time())},
		{"eyetracker_time", QVariant::fromValue(time())},
		{"left", QVariantMap{{"gaze_screen", point}, {"gaze_valid", true}}},
		{"right", QVariantMap{{"gaze_screen", point}, {"gaze_valid", true}}},
	});
}
