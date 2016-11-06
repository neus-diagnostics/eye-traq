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
	Recorder(Eyetracker &eyetracker, QObject *runner);
	virtual ~Recorder();

public slots:
	void start(const QUrl &testfile, const QString &participant);
	void step();
	void stop();
	void gaze(const QString &left, const QString& right);

signals:
	void run(QVariant name, QVariant args);
	void reset();

private:
	Eyetracker &eyetracker;
	QObject *runner;

	QFile *logfile;

	QVector<QPair<QString, QStringList>> test;
	int next;
};

#endif
