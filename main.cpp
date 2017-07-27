#include <exception>
#include <memory>

#include <QApplication>
#include <QFontDatabase>
#include <QQmlContext>
#include <QObject>
#include <QQuickItem>
#include <QQuickView>
#include <QScreen>
#include <QtDebug>

#include "eyetracker.h"
#include "player.h"
#include "recorder.h"

#ifdef USE_TOBII
#include "eyetracker-tobii.h"
#endif

int main(int argc, char *argv[])
try {
	QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
	QApplication app{argc, argv};

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
	std::unique_ptr<Eyetracker> eyetracker{new EyetrackerTobii{}};
#else
	std::unique_ptr<Eyetracker> eyetracker{new Eyetracker{}};
#endif

	Recorder recorder{"data"};

	// set up the window
	QQuickView view;
	view.rootContext()->setContextProperty("path", "file://" + app.applicationDirPath());
	view.rootContext()->setContextProperty("firstScreen", first_screen);
	view.rootContext()->setContextProperty("secondScreen", second_screen);
	view.rootContext()->setContextProperty("eyetracker", eyetracker.get());
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
