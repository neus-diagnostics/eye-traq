#include "eyetracker.h"

#include <QDateTime>

Eyetracker::Eyetracker()
	: QObject{}, name{}, tracking{false}
{
}

Eyetracker::~Eyetracker()
{
}

bool Eyetracker::calibrate(const QString &)
{
	return true;
}

bool Eyetracker::calibrate(const QPointF &)
{
	return true;
}

QVariantList Eyetracker::get_calibration()
{
	return {};
}

qint64 Eyetracker::time()
{
	return QDateTime::currentMSecsSinceEpoch();
}

bool Eyetracker::connected() const
{
	return true;
}

void Eyetracker::track(bool)
{
}
