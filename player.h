#ifndef PLAYER_H
#define PLAYER_H

#include <QVector>
#include <QPair>
#include <QElapsedTimer>
#include <QObject>
#include <QQmlEngine>
#include <QString>
#include <QStringList>
#include <QTimer>
#include <QQmlComponent>

class Player : public QQmlComponent {
	Q_OBJECT
public:
	Player(QQmlEngine &engine);
	virtual ~Player();

public slots:
	void start(const QString &logfile);
	void tick();
	void stop();

private:
	QObject *object;

	QElapsedTimer timer;
	QTimer ticker;

	QVector<QPair<qint64, QStringList>> events;
	int index;
	qint64 start_time;
};

#endif
