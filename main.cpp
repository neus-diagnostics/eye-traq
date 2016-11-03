#include <QApplication>
#include <QQmlContext>
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

	QQmlComponent main_window{&engine, QUrl{"qrc:/ExperimenterView.qml"}};
	if (main_window.status() == QQmlComponent::Ready) {
		main_window.create();
	} else {
		for (const auto &e : main_window.errors())
			qWarning() << e;
	}

	QObject::connect(&engine, &QQmlEngine::quit, &app, &QApplication::quit);
	QObject::connect(&eyetracker, &Eyetracker::gazed, &recorder, &Recorder::gaze);

	return app.exec();
}
