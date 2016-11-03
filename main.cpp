#include <QApplication>
#include <QFontDatabase>
#include <QQmlContext>
#include <QQuickView>
#include <QQmlEngine>
#include <QtDebug>

#ifdef USE_TOBII
#include <tobii/sdk/cpp/Library.hpp>
namespace tetio = tobii::sdk::cpp;
#endif

#include "eyetracker.h"
#include "player.h"
#include "recorder.h"

int main(int argc, char *argv[])
{
	QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
	QApplication app{argc, argv};

	if (QFontDatabase::addApplicationFont(":/fonts/lato-regular.ttf") == -1 ||
	    QFontDatabase::addApplicationFont(":/fonts/lato-bold.ttf") == -1)
		qWarning() << "Could not load fonts.";

#ifdef USE_TOBII
	tetio::Library::init();
#endif
	Eyetracker eyetracker;

	QQmlEngine engine;
	engine.rootContext()->setContextProperty("eyetracker", &eyetracker);

	Recorder recorder{engine, eyetracker};
	engine.rootContext()->setContextProperty("recorder", &recorder);

	Player player{engine};
	engine.rootContext()->setContextProperty("player", &player);

	QQuickView experimenter_view{&engine, nullptr};
	experimenter_view.setSource(QUrl{"qrc:/ExperimenterView.qml"});
	if (experimenter_view.status() == QQuickView::Ready) {
		experimenter_view.create();
	} else {
		for (const auto &e : experimenter_view.errors())
			qWarning() << e;
		return 1;
	}
	experimenter_view.showFullScreen();

	QObject::connect(&engine, &QQmlEngine::quit, &app, &QApplication::quit);
	QObject::connect(&eyetracker, &Eyetracker::gazed, &recorder, &Recorder::gaze);

	return app.exec();
}
