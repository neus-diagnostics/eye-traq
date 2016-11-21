QT += qml quick widgets

CONFIG += c++11

#QMAKE_CXXFLAGS += -g -ggdb

exists($$PWD/3rdparty/lib/libtetio.so) {
	DEFINES += USE_TOBII
	INCLUDEPATH += $$PWD/3rdparty/include
	LIBS += -Wl,-rpath,$$PWD/3rdparty/lib -L$$PWD/3rdparty/lib
	LIBS += -ltetio -lboost_system -lboost_thread
}

SOURCES += \
	eyetracker.cpp \
	gaze.cpp \
	main.cpp \
	player.cpp \
	recorder.cpp

HEADERS += \
	eyetracker.h \
	gaze.h \
	player.h \
	recorder.h \
	tobii.h

RESOURCES += neus.qrc
