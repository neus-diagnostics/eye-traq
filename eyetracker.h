#ifndef EYETRACKER_H
#define EYETRACKER_H

#include <QObject>
#include <QString>
#include <QPointF>
#include <QVariant>

class Eyetracker : public QObject {
	Q_OBJECT
	Q_PROPERTY(bool connected READ connected NOTIFY statusChanged STORED false)
	Q_PROPERTY(QString status READ status NOTIFY statusChanged STORED false)
	Q_PROPERTY(bool tracking MEMBER tracking WRITE track NOTIFY trackingChanged STORED false)

public:
	Eyetracker();
	virtual ~Eyetracker();

public slots:
	virtual bool calibrate(const QString &what);
	virtual bool calibrate(const QPointF &point);
	virtual QVariantList get_calibration();
	virtual qint64 time();

signals:
	void statusChanged();
	void trackingChanged();
	void gaze(const QVariantMap &data);

protected:
	bool tracking;

private:
	virtual bool connected() const;
	virtual QString status() const;
	virtual void track(bool enable);
};

#endif
