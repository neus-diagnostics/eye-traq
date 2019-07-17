#include <exception>

#include <QApplication>
#include <QQmlContext>
#include <QQmlEngine>
#include <QQuickStyle>
#include <QQuickView>
#include <QTextCodec>
#include <QtDebug>

#include "fileio.h"

int main(int argc, char *argv[])
try {
	QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
	QQuickStyle::setStyle("Fusion");
	QTextCodec::setCodecForLocale(QTextCodec::codecForName("utf-8"));
	QApplication app{argc, argv};

	const QString path = app.applicationDirPath();
	const QString version{GIT_VERSION}; // export define for QML

	FileIO fileIO;

	// set up the window
	QQuickView view;
	view.rootContext()->setContextProperty("path", path);
	view.rootContext()->setContextProperty("version", version);
	view.rootContext()->setContextProperty("fileIO", &fileIO);
	view.rootContext()->setContextProperty("eyetracker", nullptr);

	view.setTitle("Eye-track player");
	view.setSource(QUrl{"qrc:/Main.qml"});
	if (view.status() != QQuickView::Ready) {
		for (const auto &e : view.errors())
			qWarning() << e;
		return 1;
	}
	view.create();
	view.show();
	return app.exec();

} catch (std::exception &e) {
	qCritical() << "Critical error:" << e.what();
	return 1;
} catch (...) {
	qCritical() << "Critical error";
	return 1;
}
