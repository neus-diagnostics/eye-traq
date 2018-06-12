#include "recorder.h"

#include <QDateTime>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QVariantList>
#include <QVariantMap>
#include <QtDebug>

Recorder::Recorder(const QString &datadir)
	: QObject{}, datadir{datadir}, stream{nullptr}
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

	QJsonParseError e;
	auto testdata = QJsonDocument::fromJson(file.readAll(), &e);
	if (e.error != QJsonParseError::NoError) {
		qWarning() << "could not load test:" << e.errorString() << e.offset;
		return {};
	}

	// test data is either a list of tasks or an object containing a list of tasks
	const auto &taskdata = testdata.isArray() ?
		testdata.array() :
		testdata.object().value("tasks").toArray();

	QVariantList tasks;
	int time = 0;
	for (int i = 0; i < taskdata.size(); i++) {
		QVariantMap task = taskdata[i].toObject().toVariantMap();
		task["start"] = time;
		time += task["duration"].toInt();
		tasks.append(task);
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

void Recorder::start(const QString &test_name, const QString &participant)
{
	if (participant.isEmpty())
		return;

	// construct filename
	const auto now = QDateTime::currentDateTimeUtc();
	const QString filename =
		datadir.filePath(participant + "/" +
		now.toString("yyyyMMdd-HHmmss") + "-" + test_name + ".log");

	// open file
	datadir.mkpath(participant);
	QFile *file = new QFile{filename};
	if (file->open(QIODevice::WriteOnly)) {
		stream = new QTextStream{file};
	} else {
		qWarning() << "could not open file:" << filename;
		delete file;
	}
}

void Recorder::stop()
{
	if (stream) {
		auto *file = stream->device();
		delete stream;
		delete file;
		stream = nullptr;
	}
}

void Recorder::write(const QString &text)
{
	if (stream)
		(*stream) << text << '\n';
}
