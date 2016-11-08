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

#include "eyetracker.h"

class Recorder : public QObject {
	Q_OBJECT
public:
	Recorder(Eyetracker &eyetracker);
	virtual ~Recorder();

public slots:
	QStringList loadTest(const QUrl &testfile);
	void start(const QUrl &testfile, const QString &participant);
	void stop();
	void write(const QString &text);
	void gaze(const QString &left, const QString& right);

private:
	Eyetracker &eyetracker;
	QFile *logfile;
};

#endif
