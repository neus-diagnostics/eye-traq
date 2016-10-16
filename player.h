#ifndef PLAYER_H
#define PLAYER_H

#include <QVector>
#include <QPair>
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
	void step();
	void stop();

private:
	QObject *object;

	QTimer timer;

	QVector<QPair<qint64, QStringList>> items;
	int index;
};

#endif
