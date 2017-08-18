#include "recorder.h"

#include <QDateTime>
#include <QFileInfo>
#include <QRegularExpression>
#include <QVariantMap>
#include <QtDebug>

Recorder::Recorder(const QString &datadir)
	: QObject{}, datadir{datadir}, logfile{nullptr}
{
}

Recorder::~Recorder()
{
	stop();
}

QVariantList Recorder::loadTest(const QString &testpath)
{
	QFile file{testpath};
	if (!file.open(QIODevice::ReadOnly)) {
		qWarning() << "could not open test:" << testpath;
		return {};
	}
	QString testdata = QTextStream{&file}.readAll();

	QVariantList tasks;
	int i = 0;
	int total_time = 0;
	// remove empty lines and comments
	for (const auto &line : testdata.split('\n').filter(QRegularExpression("^[^#]"))) {
		const auto &tokens = line.split('\t');
		const auto &name = tokens[0];
		const auto &args = QStringList{tokens.mid(1)};
		const int time = args.isEmpty() ? 0.0f : args[0].toFloat();

		tasks.push_back(QVariantMap{
			{"name", name},
			{"args", QStringList{args.mid(1)}},
			{"index", i++},
			{"start", total_time},
			{"duration", time}
		});
		total_time += time;
	}
	return tasks;
}

QString Recorder::getNotes(const QString &participant)
{
	QFile file{datadir.filePath(participant + "/notes.txt")};
	if (file.open(QFile::ReadOnly | QFile::Text))
		return QTextStream{&file}.readAll();
	return "";
}

void Recorder::setNotes(const QString &participant, const QString &notes)
{
	QFile file{datadir.filePath(participant + "/notes.txt")};
	datadir.mkpath(participant);
	if (file.open(QFile::WriteOnly | QFile::Text))
		QTextStream{&file} << notes;
}

void Recorder::start(const QString &testpath, const QString &participant)
{
	if (participant.isEmpty())
		return;

	// construct filename
	const auto now = QDateTime::currentDateTimeUtc();
	const auto testname = QFileInfo{testpath}.baseName();
	const QString filename =
		datadir.filePath(participant + "/" +
		now.toString("yyyyMMdd-HHmmss") + "-" + testname + ".log");

	// open file
	datadir.mkpath(participant);
	logfile = new QFile{filename};
	if (!logfile->open(QIODevice::WriteOnly)) {
		qWarning() << "could not open file:" << filename;
		delete logfile;
		logfile = nullptr;
		return;
	}
}

void Recorder::stop()
{
	if (logfile) {
		delete logfile;
		logfile = nullptr;
	}
}

void Recorder::write(const QString &text)
{
	if (logfile)
		QTextStream{logfile} << text << '\n';
}
