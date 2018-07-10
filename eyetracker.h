#ifndef EYETRACKER_H
#define EYETRACKER_H

#include <QObject>
#include <QString>
#include <QPointF>
#include <QQueue>
#include <QVariant>

class Eyetracker : public QObject {
	Q_OBJECT
	Q_PROPERTY(bool connected READ connected NOTIFY statusChanged STORED false)
	Q_PROPERTY(QString name MEMBER name NOTIFY statusChanged)
	Q_PROPERTY(float frequency MEMBER frequency NOTIFY statusChanged)
	Q_PROPERTY(bool tracking MEMBER tracking WRITE track STORED false)
	Q_PROPERTY(QPointF point MEMBER point NOTIFY pointChanged)
	Q_PROPERTY(QPointF velocity MEMBER velocity NOTIFY pointChanged)

public:
	Eyetracker(const float frequency = 60.0f);
	virtual ~Eyetracker();

public slots:
	virtual bool calibrate(const QString &what);
	virtual bool calibrate(const QPointF &point);
	virtual QVariantList get_calibration();
	virtual qint64 time();

signals:
	void statusChanged();
	void pointChanged(const QPointF &point);
	void gaze(const QVariantMap &data);

protected:
	QString name;
	float frequency;
	bool tracking;
	QPointF point;
	QPointF velocity;

	QQueue<QPointF> points;
	int window_size;

	virtual bool connected() const;
	virtual void track(bool enable);

private:
	virtual void process_gaze(const QVariantMap &data);
};

#endif
