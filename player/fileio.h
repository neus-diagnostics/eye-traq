// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright © 2018 Neus Diagnostics, d.o.o.

#ifndef FILEIO_H
#define FILEIO_H

#include <QObject>
#include <QUrl>

// TODO make this a per-file object instantiatable from QML
class FileIO : public QObject {
	Q_OBJECT
public slots:
	QString read(const QUrl &path);
};

#endif
