#include <QApplication>
#include <QQmlContext>
#include <QQmlEngine>

#include <tobii/sdk/cpp/Library.hpp>
namespace tetio = tobii::sdk::cpp;

#include "browser.h"
#include "calibrator.h"
#include "player.h"
#include "recorder.h"

int main(int argc, char *argv[])
{
	QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
	QApplication app{argc, argv};

	tetio::Library::init();
	Browser browser;

	QQmlEngine engine;
	QObject::connect(&engine, &QQmlEngine::quit, &app, &QApplication::quit);

	QQmlComponent main_window{&engine, QUrl{"qrc:/main.qml"}};
	QObject *main_window_object = main_window.create();
	QObject::connect(&browser, SIGNAL(connected()), main_window_object, SLOT(enable()));
	QObject::connect(&browser, SIGNAL(disconnected()), main_window_object, SLOT(disable()));

	Calibrator calibrator{engine, browser};
	engine.rootContext()->setContextProperty("calibrator", &calibrator);

	Recorder recorder{engine, browser};
	engine.rootContext()->setContextProperty("recorder", &recorder);

	Player player{engine};
	engine.rootContext()->setContextProperty("player", &player);

	QObject::connect(&browser, &Browser::gazed, &recorder, &Recorder::gaze);

	return app.exec();
}
