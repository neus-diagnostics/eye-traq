#include "player.h"

#include <QFile>
#include <QtDebug>

Player::Player(QQmlEngine &engine)
	: QQmlComponent{&engine, QUrl{"qrc:/runner.qml"}},
	  object{nullptr}
{
	timer.setTimerType(Qt::PreciseTimer);
	timer.setSingleShot(true);
	connect(&timer, &QTimer::timeout, this, &Player::step);
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

	items.clear();
	while (true) {
		qint64 timestamp;
		stream >> timestamp;
		if (stream.atEnd())
			break;
		stream.skipWhiteSpace();
		QStringList data = stream.readLine().split('\t');
		items.append({timestamp, data});
	}

	// create the window
	if (object)
		delete object;
	object = create();
	connect(object, SIGNAL(abort()), this, SLOT(stop()));

	index = 0;
	step();
}

void Player::stop()
{
	timer.stop();
	QMetaObject::invokeMethod(object, "stop");
}

void Player::step()
{
	const auto &item = items[index];
	const QStringList &data = item.second;

	if (item.second[0] == "test") {
		const QStringList &args = data.mid(2);
		QMetaObject::invokeMethod(object, "run",
				Q_ARG(QVariant, data[1]), Q_ARG(QVariant, args));
	} else if (item.second[0] == "gaze") {
		const QStringList &args = data.mid(4, 2);
		QMetaObject::invokeMethod(object, "run",
				Q_ARG(QVariant, data[0]), Q_ARG(QVariant, args));
	}
	index++;

	if (index < items.length()) {
		timer.setInterval(items[index].first - item.first);
		timer.start();
	} else {
		stop();
	}
}
