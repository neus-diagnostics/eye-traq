#ifndef RECORDER_H
#define RECORDER_H

#include <QFile>
#include <QVector>
#include <QPair>
#include <QObject>
#include <QQmlEngine>
#include <QString>
#include <QStringList>
#include <QQmlComponent>

#include "gaze.h"

class Recorder : public QObject {
	Q_OBJECT
public:
	Recorder();
	virtual ~Recorder();

public slots:
	QVariantList loadTest(const QUrl &testfile);
	void start(const QUrl &testfile, const QString &participant);
	void stop();
	void write(const QString &text);
	void write_gaze(const Gaze& gaze);

private:
	QFile *logfile;
};

#endif
