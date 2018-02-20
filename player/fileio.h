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
