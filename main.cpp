#include <QApplication>
#include <QFontDatabase>
#include <QQmlContext>
#include <QQuickItem>
#include <QQuickView>
#include <QQmlEngine>
#include <QScreen>
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

	// get primary and secondary screen
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
	QQuickView view;
	view.rootContext()->setContextProperty("firstScreen", first_screen->geometry());
	view.rootContext()->setContextProperty("secondScreen", second_screen->geometry());

	Eyetracker eyetracker;
	view.rootContext()->setContextProperty("eyetracker", &eyetracker);

	Recorder recorder{eyetracker};
	view.rootContext()->setContextProperty("recorder", &recorder);

	// set up the window
	view.setSource(QUrl{"qrc:/Main.qml"});
	if (view.status() == QQuickView::Ready) {
		view.create();
	} else {
		for (const auto &e : view.errors())
			qWarning() << e;
		return 1;
	}

	// QT BUG: ensure window gets painted when mapped
	QObject::connect(&view, &QQuickView::activeChanged, &view, &QQuickView::update);
	view.setFlags(Qt::FramelessWindowHint);
	view.setGeometry(first_screen->virtualGeometry());
	view.show();

	QObject *runner = view.rootObject()->findChild<QObject*>("runner");

	//QObject::connect(&engine, &QQmlEngine::quit, &app, &QApplication::quit);
	QObject::connect(&eyetracker, &Eyetracker::gazed, &recorder, &Recorder::gaze);
	QObject::connect(&eyetracker, SIGNAL(gazed(QString, QString)), runner, SLOT(write_data()));

	return app.exec();
}
