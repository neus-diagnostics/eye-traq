// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright © 2018 Neus Diagnostics, d.o.o.

#ifndef EYETRACKER_MOUSE_H
#define EYETRACKER_MOUSE_H

#include "eyetracker.h"

#include <QScreen>
#include <QTimer>

class EyetrackerMouse : public Eyetracker {
	Q_OBJECT
public:
	EyetrackerMouse(const QScreen *screen);
	virtual ~EyetrackerMouse();

private:
	const QScreen *screen;
	QTimer timer;

	void do_gaze();
};

#endif
