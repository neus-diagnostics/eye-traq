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

#include "browser.h"

class Recorder : public QQmlComponent {
	Q_OBJECT
public:
	Recorder(QQmlEngine &engine, Browser &browser);
	virtual ~Recorder();

public slots:
	void start(const QString &testfile, const QString &participant);
	void step();
	void stop();
	void gaze(const QString &left, const QString& right);

private:
	Browser &browser;

	QObject *object;
	QFile *log;

	QVector<QPair<QString, QStringList>> test;
	int next;
};

#endif
