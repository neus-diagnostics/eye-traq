#include "eyetracker.h"

#include <QDateTime>

Eyetracker::Eyetracker(const float frequency)
	: QObject{}, name{}, frequency{frequency}, tracking{false}, point{}, window_size{5}
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
	return QDateTime::currentMSecsSinceEpoch() * 1000;
}

bool Eyetracker::connected() const
{
	return true;
}

void Eyetracker::track(bool)
{
}
