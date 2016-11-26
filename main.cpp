#include <exception>

#include <QApplication>
#include <QFontDatabase>
#include <QQmlContext>
#include <QMetaType>
#include <QObject>
#include <QQuickItem>
#include <QQuickView>
#include <QScreen>
#include <QtDebug>

#ifdef USE_TOBII
#include <tobii/sdk/cpp/Library.hpp>
namespace tetio = tobii::sdk::cpp;
#endif

#include "eyetracker.h"
#include "gaze.h"
#include "player.h"
#include "recorder.h"

int main(int argc, char *argv[])
try {
	QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
	QApplication app{argc, argv};

	qRegisterMetaType<Gaze>("Gaze");

	if (QFontDatabase::addApplicationFont(":/resources/lato-regular.ttf") == -1 ||
	    QFontDatabase::addApplicationFont(":/resources/lato-bold.ttf") == -1)
		qWarning() << "Could not load fonts.";

	// find primary and secondary screen
	QScreen* first_screen = app.primaryScreen();
	QScreen* second_screen = first_screen;
	for (auto screen : app.screens()) {
		if (screen != first_screen) {
			second_screen = screen;
			break;
		}
	}

#ifdef USE_TOBII
	tetio::Library::init();
#endif

	// construct global objects
	Eyetracker eyetracker;
	Recorder recorder;
	QObject::connect(&eyetracker, &Eyetracker::gaze,
	                 &recorder, &Recorder::write_gaze);

	// set up the window
	QQuickView view;
	view.rootContext()->setContextProperty("path", "file://" + app.applicationDirPath());
	view.rootContext()->setContextProperty("firstScreen", first_screen->geometry());
	view.rootContext()->setContextProperty("secondScreen", second_screen->geometry());
	view.rootContext()->setContextProperty("eyetracker", &eyetracker);
	view.rootContext()->setContextProperty("recorder", &recorder);

	view.setSource(QUrl{"qrc:/Main.qml"});
	if (view.status() != QQuickView::Ready) {
		for (const auto &e : view.errors())
			qWarning() << e;
		return 1;
	}
	view.create();
	view.setFlags(Qt::FramelessWindowHint);
	view.setGeometry(first_screen->virtualGeometry());

	// QT BUG: ensure window gets painted when mapped
	QObject::connect(&view, &QQuickView::activeChanged,
	                 &view, &QQuickView::update);
	QObject::connect(view.engine(), &QQmlEngine::quit,
	                 &app, &QCoreApplication::quit);
	QObject::connect(view.rootObject(), SIGNAL(minimize()),
	                 &view, SLOT(showMinimized()));
	view.show();
	return app.exec();

} catch (std::exception &e) {
	qCritical() << "Critical error:" << e.what();
	return 1;
} catch (...) {
	qCritical() << "Critical error";
	return 1;
}
