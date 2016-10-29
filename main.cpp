#include <QApplication>
#include <QQmlContext>
#include <QQmlEngine>

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

	QQmlComponent main_window{&engine, QUrl{"qrc:/main.qml"}};
	main_window.create();

	Recorder recorder{engine, eyetracker};
	engine.rootContext()->setContextProperty("recorder", &recorder);

	Player player{engine};
	engine.rootContext()->setContextProperty("player", &player);

	QObject::connect(&engine, &QQmlEngine::quit, &app, &QApplication::quit);
	QObject::connect(&eyetracker, &Eyetracker::gazed, &recorder, &Recorder::gaze);

	return app.exec();
}
