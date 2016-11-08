#include "recorder.h"

#include <QDateTime>
#include <QDir>
#include <QFileInfo>
#include <QProcess>
#include <QQuickItem>
#include <QUrl>
#include <QtDebug>

Recorder::Recorder(Eyetracker &eyetracker)
	: QObject{}, eyetracker{eyetracker}, logfile{nullptr}
{
}

Recorder::~Recorder()
{
	stop();
}

QStringList Recorder::loadTest(const QUrl &testfile)
{
	QStringList test;

	// does the testfile exist?
	const QString testpath{testfile.toLocalFile()};
	QString testdata;

	// load or execute testfile
	if (QFileInfo{testpath}.isExecutable()) {
		QProcess testgen;
		testgen.start(testpath);
		if (!testgen.waitForFinished() || testgen.exitCode() != 0) {
			qWarning() << "could not start testgen process";
			return test;
		}
		testdata = QString::fromUtf8(testgen.readAllStandardOutput());
	} else {
		QFile file(testpath);
		if (!file.open(QIODevice::ReadOnly)) {
			qWarning() << "could not open testfile";
			return test;
		}
		testdata = QTextStream{&file}.readAll();
	}

	// parse test data
	for (const auto &line : testdata.split('\n')) {
		if (line == "" || line.startsWith("#"))
			continue;
		test.append(line);
	}

	return QStringList{test};
}

void Recorder::start(const QUrl &testfile, const QString &participant)
{
	if (participant.isEmpty())
		return;

	// does the testfile exist?
	const QString testpath{testfile.toLocalFile()};

	// open logfile
	QDir path{"data"};
	path.mkpath(participant);

	// open a logfile for this test
	const auto now = QDateTime::currentDateTimeUtc();
	const auto testname = QFileInfo{testpath}.baseName();
	QString filename = "data/" + participant + "/" +
	                   now.toString("yyyyMMdd-HHmmss") + "-" + testname + ".log";
	logfile = new QFile{filename};
	if (!logfile->open(QIODevice::WriteOnly)) {
		qWarning() << "Cannot open file" << filename;
		delete logfile;
		logfile = nullptr;
		return;
	}

	eyetracker.command("start_tracking");
}

void Recorder::stop()
{
	if (logfile) {
		eyetracker.command("stop_tracking");

		const auto &timestamp = QDateTime::currentDateTimeUtc().toMSecsSinceEpoch();
		QTextStream{logfile} << timestamp << '\t'
		                 << "end" << '\n';
		delete logfile;
		logfile = nullptr;
	}
}

void Recorder::write(const QString &text)
{
	if (logfile) {
		const auto &timestamp = QDateTime::currentDateTimeUtc().toMSecsSinceEpoch();
		QTextStream{logfile} << timestamp << '\t' << text << '\n';
	}
}

void Recorder::gaze(const QString &left, const QString &right)
{
	write("gaze\t" + left);
	write("gaze\t" + right);
}
