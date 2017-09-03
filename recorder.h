#ifndef RECORDER_H
#define RECORDER_H

#include <QDir>
#include <QFile>
#include <QObject>
#include <QString>
#include <QTextStream>
#include <QVariantList>

class Recorder : public QObject {
	Q_OBJECT
public:
	Recorder(const QString &datadir);
	virtual ~Recorder();

public slots:
	QVariantList loadTest(const QString &testfile);
	QString getNotes(const QString &participant);
	void setNotes(const QString &participant, const QString &notes);
	void start(const QString &testfile, const QString &participant);
	void stop();
	void write(const QString &text);

private:
	QDir datadir;
	QTextStream *stream;
};

#endif
