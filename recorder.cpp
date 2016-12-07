#include "recorder.h"

#include <QDateTime>
#include <QDir>
#include <QFileInfo>
#include <QProcess>
#include <QQuickItem>
#include <QRegularExpression>
#include <QUrl>
#include <QVariantList>
#include <QVariantMap>
#include <QtDebug>

Recorder::Recorder()
	: QObject{}, logfile{nullptr}
{
}

Recorder::~Recorder()
{
	stop();
}

QVariantList Recorder::loadTest(const QUrl &testfile)
{
	QString testdata;

	const QString testpath{testfile.toLocalFile()};
	if (QFileInfo{testpath}.isExecutable()) {
		// run testfile and load the test from stdout
		QProcess testgen;
		testgen.start(testpath);
		if (!testgen.waitForFinished() || testgen.exitCode() != 0) {
			qWarning() << "could not start test program";
			return {};
		}
		testdata = QString::fromUtf8(testgen.readAllStandardOutput());
	} else {
		// load the testfile directly
		QFile file(testpath);
		if (!file.open(QIODevice::ReadOnly)) {
			qWarning() << "could not open testfile";
			return {};
		}
		testdata = QTextStream{&file}.readAll();
	}

	QVariantList tasks;
	// remove empty lines and comments
	int i = 0;
	for (const auto &line : testdata.split('\n').filter(QRegularExpression("^[^#]"))) {
		const auto &tokens = line.split('\t');
		const auto &name = tokens[0];
		const auto &args = QStringList{tokens.mid(1)};
		tasks.push_back(QVariantMap{
			{"name", name},
			{"args", args},
			{"index", i++}
		});
	}
	return tasks;
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
	       << gaze.time << "\tgaze\tleft\t"
	       << gaze.eyetracker_time << '\t'
	       << gaze.valid_l << '\t'
	       << gaze.screen_l.x() << '\t' << gaze.screen_l.y() << '\t'
	       << gaze.pupil_l << '\t'
	       << gaze.eye_ucs_l.x() << '\t' << gaze.eye_ucs_l.y() << '\t' << gaze.eye_ucs_l.z() << '\t'
	       << gaze.eye_track_l.x() << '\t' << gaze.eye_track_l.y() << '\t' << gaze.eye_track_l.z() << '\t'
	       << gaze.ucs_l.x() << '\t' << gaze.ucs_l.y() << '\t' << gaze.ucs_l.z() << '\n'

	       << gaze.time << "\tgaze\tright\t"
	       << gaze.eyetracker_time << '\t'
	       << gaze.valid_r << '\t'
	       << gaze.screen_r.x() << '\t' << gaze.screen_r.y() << '\t'
	       << gaze.pupil_r << '\t'
	       << gaze.eye_ucs_r.x() << '\t' << gaze.eye_ucs_r.y() << '\t' << gaze.eye_ucs_r.z() << '\t'
	       << gaze.eye_track_r.x() << '\t' << gaze.eye_track_r.y() << '\t' << gaze.eye_track_r.z() << '\t'
	       << gaze.ucs_r.x() << '\t' << gaze.ucs_r.y() << '\t' << gaze.ucs_r.z() << '\n';
}
