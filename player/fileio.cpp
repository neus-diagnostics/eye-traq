// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright © 2018 Neus Diagnostics, d.o.o.

#include "fileio.h"

#include <QFile>
#include <QString>
#include <QTextStream>
#include <QtDebug>

QString FileIO::read(const QUrl &path) {
	QFile file{path.toLocalFile()};
	if (!file.open(QIODevice::ReadOnly)) {
		qWarning() << "could not open test:" << path;
		return "";
	}
	return QTextStream{&file}.readAll();
}
