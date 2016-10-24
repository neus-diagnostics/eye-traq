#include "player.h"

#include <QFile>
#include <QtDebug>

Player::Player(QQmlEngine &engine)
	: QQmlComponent{&engine, QUrl{"qrc:/runner.qml"}},
	  object{nullptr}
{
	if (!isReady())
		qWarning() << errors();

	ticker.setTimerType(Qt::PreciseTimer);
	ticker.setSingleShot(false);
	ticker.setInterval(1000.0/60.0);
	connect(&ticker, &QTimer::timeout, this, &Player::tick);
}

Player::~Player()
{
	if (object)
		delete object;
}

void Player::start(const QString &logfile)
{
	// open the logfile
	QFile log{QUrl{logfile}.toLocalFile()};
	if (!log.open(QIODevice::ReadOnly)) {
		qWarning() << "Cannot open file" << logfile;
		return;
	}
	QTextStream stream{&log};

	events.clear();
	while (true) {
		qint64 timestamp;
		stream >> timestamp;
		if (stream.atEnd())
			break;
		stream.skipWhiteSpace();
		QStringList data = stream.readLine().split('\t');
		events.append({timestamp, data});
	}
	if (events.isEmpty())
		return;

	index = 0;
	start_time = events[0].first;

	// create the window
	if (object)
		delete object;
	object = create();
	connect(object, SIGNAL(abort()), this, SLOT(stop()));

	timer.start();
	ticker.start();
}

void Player::stop()
{
	ticker.stop();
	QMetaObject::invokeMethod(object, "stop");
}

void Player::tick()
{
	if (index >= events.length()) {
		stop();
		return;
	}

	// process events until we catch up with timer
	if (events[index].first - start_time < timer.elapsed()) {
		const QStringList &data = events[index].second;

		if (data[0] == "test") {
			const QStringList &args = data.mid(2);
			QMetaObject::invokeMethod(object, "run",
					Q_ARG(QVariant, data[1]), Q_ARG(QVariant, args));
		} else if (data[0] == "gaze") {
			const QStringList &args = data.mid(4, 2);
			QMetaObject::invokeMethod(object, "run",
					Q_ARG(QVariant, data[0]), Q_ARG(QVariant, args));
		}
		index++;
		tick();
	}
}
