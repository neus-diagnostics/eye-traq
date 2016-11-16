#include "recorder.h"

#include <QDateTime>
#include <QDir>
#include <QFileInfo>
#include <QProcess>
#include <QQuickItem>
#include <QUrl>
#include <QtDebug>

Recorder::Recorder()
	: QObject{}, logfile{nullptr}
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
}

void Recorder::stop()
{
	if (!logfile)
		return;
	delete logfile;
	logfile = nullptr;
}

void Recorder::write(const QString &text)
{
	if (!logfile)
		return;
	QTextStream{logfile} << text << '\n';
}

void Recorder::write_gaze(const Gaze &gaze)
{
	if (!logfile)
		return;
	QTextStream{logfile}
	       << gaze.local_timestamp << "\tgaze\tleft\t"
	       << gaze.timestamp << '\t'
	       << gaze.valid_l << '\t'
	       << gaze.screen_l.x() << '\t' << gaze.screen_l.y() << '\t'
	       << gaze.pupil_l << '\t'
	       << gaze.eye_ucs_l.x() << '\t' << gaze.eye_ucs_l.y() << '\t' << gaze.eye_ucs_l.z() << '\t'
	       << gaze.eye_track_l.x() << '\t' << gaze.eye_track_l.y() << '\t' << gaze.eye_track_l.z() << '\t'
	       << gaze.ucs_l.x() << '\t' << gaze.ucs_l.y() << '\t' << gaze.ucs_l.z() << '\n'

	       << gaze.local_timestamp << "\tgaze\tright\t"
	       << gaze.timestamp << '\t'
	       << gaze.valid_r << '\t'
	       << gaze.screen_r.x() << '\t' << gaze.screen_r.y() << '\t'
	       << gaze.pupil_r << '\t'
	       << gaze.eye_ucs_r.x() << '\t' << gaze.eye_ucs_r.y() << '\t' << gaze.eye_ucs_r.z() << '\t'
	       << gaze.eye_track_r.x() << '\t' << gaze.eye_track_r.y() << '\t' << gaze.eye_track_r.z() << '\t'
	       << gaze.ucs_r.x() << '\t' << gaze.ucs_r.y() << '\t' << gaze.ucs_r.z() << '\n';
}
