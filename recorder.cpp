#include "recorder.h"

#include <QDateTime>
#include <QDir>
#include <QFileInfo>
#include <QProcess>
#include <QQuickItem>

Recorder::Recorder(QQmlEngine &engine, Eyetracker &eyetracker)
	: QQmlComponent{&engine, QUrl{"qrc:/runner.qml"}},
	  eyetracker{eyetracker},
	  object{nullptr},
	  log{nullptr}
{
}

Recorder::~Recorder()
{
	if (object)
		delete object;
	if (log)
		delete log;
}

void Recorder::start(const QString &testfile, const QString &participant)
{
	if (participant.isEmpty())
		return;

	// clear existing test descriptor
	test.clear();
	next = 0;

	// does the testfile exist?
	const QString testpath{QUrl{testfile}.toLocalFile()};
	QString testdata;

	// load or execute testfile
	if (QFileInfo{testpath}.isExecutable()) {
		QProcess testgen;
		testgen.start(testpath);
		if (!testgen.waitForFinished() || testgen.exitCode() != 0) {
			qWarning() << "could not start testgen process";
			return;
		}
		testdata = QString::fromUtf8(testgen.readAllStandardOutput());
	} else {
		QFile file(testpath);
		if (!file.open(QIODevice::ReadOnly)) {
			qWarning() << "could not open testfile";
			return;
		}
		testdata = QTextStream{&file}.readAll();
	}

	// parse test data
	for (const auto &line : testdata.split('\n')) {
		if (line == "" || line.startsWith("#"))
			continue;
		const auto &tokens = line.split('\t');
		QPair<QString, QStringList> task{tokens[0], {}};
		for (int i = 1; i < tokens.length(); i++)
			task.second.append(tokens[i]);
		test.append(task);
	}

	// open logfile
	QDir path{"data"};
	path.mkpath(participant);

	// open a logfile for this test
	const auto now = QDateTime::currentDateTimeUtc();
	const auto testname = QFileInfo{testpath}.baseName();
	QString filename = "data/" + participant + "/" +
	                   now.toString("yyyyMMdd-HHmmss") + "-" + testname + ".log";
	log = new QFile{filename};
	if (!log->open(QIODevice::WriteOnly)) {
		qWarning() << "Cannot open file" << filename;
		delete log;
		log = nullptr;
		return;
	}

	// create the window
	if (object)
		delete object;
	object = create();
	connect(object, SIGNAL(next()), this, SLOT(step()));
	connect(object, SIGNAL(abort()), this, SLOT(stop()));

	eyetracker.command("start_tracking");

	step();
}

void Recorder::stop()
{
	eyetracker.command("stop_tracking");
	QMetaObject::invokeMethod(object, "stop");
	if (log) {
		delete log;
		log = nullptr;
	}
}

void Recorder::step()
{
	if (next < test.length()) {
		const auto &name = test[next].first;
		const auto &args = test[next].second;

		const auto &timestamp = QDateTime::currentDateTimeUtc().toMSecsSinceEpoch();
		QTextStream{log} << timestamp << '\t'
		                 << "test" << '\t'
		                 << name << '\t'
		                 << args.join('\t') << '\n';

		next++;
		QMetaObject::invokeMethod(object, "run", Q_ARG(QVariant, name), Q_ARG(QVariant, args));
	} else {
		stop();
	}
}

void Recorder::gaze(const QString &left, const QString &right)
{
	if (!log)
		return;

	const auto &timestamp = QDateTime::currentDateTimeUtc().toMSecsSinceEpoch();
	QTextStream stream{log};

	// record task-specific data
	QVariant ret;
	QMetaObject::invokeMethod(object, "get_data", Q_RETURN_ARG(QVariant, ret));
	QVariantList data = ret.toList();
	if (!data.isEmpty()) {
		stream << timestamp << '\t' << "data";
		for (int i = 0; i < data.length(); i++)
			stream << '\t' << data[i].toString();
		stream << '\n';
	}

	// record gaze data
	stream <<
		timestamp << '\t' << "gaze" << '\t' << left << '\n' <<
		timestamp << '\t' << "gaze" << '\t' << right << '\n';
}
