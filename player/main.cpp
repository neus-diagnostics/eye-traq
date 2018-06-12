#include <exception>

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QTextCodec>
#include <QtDebug>

#include "fileio.h"

int main(int argc, char *argv[])
try {
	QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
	QTextCodec::setCodecForLocale(QTextCodec::codecForName("utf-8"));

	QApplication app{argc, argv};
	app.setOrganizationName("Neus player");
	app.setOrganizationDomain("neus-diagnostics.com");

	FileIO fileIO;
	const QString path = app.applicationDirPath();

	// set up the window
	QQmlApplicationEngine engine{"qrc:/Main.qml"};
	engine.rootContext()->setContextProperty("fileIO", &fileIO);
	engine.rootContext()->setContextProperty("path", path);
	engine.rootContext()->setContextProperty("eyetracker", nullptr);

	return app.exec();

} catch (std::exception &e) {
	qCritical() << "Critical error:" << e.what();
	return 1;
} catch (...) {
	qCritical() << "Critical error";
	return 1;
}
