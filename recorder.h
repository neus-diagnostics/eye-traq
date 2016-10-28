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

class Recorder : public QQmlComponent {
	Q_OBJECT
public:
	Recorder(QQmlEngine &engine, Eyetracker &eyetracker);
	virtual ~Recorder();

public slots:
	void start(const QString &testfile, const QString &participant);
	void step();
	void stop();
	void gaze(const QString &left, const QString& right);

private:
	Eyetracker &eyetracker;

	QObject *object;
	QFile *log;

	QVector<QPair<QString, QStringList>> test;
	int next;
};

#endif
