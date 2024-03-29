// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright © 2016-2018 Neus Diagnostics, d.o.o.

#include "eyetracker.h"

#include <cmath>

#include <QDateTime>

Eyetracker::Eyetracker(const QString name, const float frequency)
	: QObject{}, name{name}, frequency{frequency}, tracking{false}, point{}, window_size{3}
{
	connect(this, &Eyetracker::gaze, this, &Eyetracker::process_gaze);
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

// update calculated gaze point and velocity, in relative screen coordinates
// assumes the gaze signal is emitted with fixed frequency
void Eyetracker::process_gaze(const QVariantMap &data)
{
	// focus is average of valid points (one for each eye) in current gaze data
	QPointF focus{};
	unsigned int eyes = 0;
	for (const auto &eye : {"left", "right"}) {
	    if (data[eye].toMap()["gaze_valid"].toBool()) {
		    focus += data[eye].toMap()["gaze_screen"].toPointF();
		    eyes++;
	    }
	}
	if (eyes > 0)
		focus /= eyes;

	// add focus point to recent list and dequeue stale points
	if (!focus.isNull()) {
		points.enqueue(focus);
		if (points.size() >= window_size)
			points.dequeue();
	} else {
		if (!points.empty())
			points.dequeue();
	}

	// point is average of recent points
	// d is average pairwise difference between recent points
	point = {};
	QPointF d{};
	if (!points.empty()) {
		point = points.first();
		for (int i = 1; i < points.size(); i++) {
			point += points[i];
			d += points[i] - points[i-1];
		}
		point /= points.size();
		d /= points.size();
	}

	// velocity is  distance per second
	velocity = std::hypot(d.x(), d.y()) * frequency;

	emit pointChanged(point);
}
