QT += qml quick widgets

CONFIG += c++11

INCLUDEPATH += $$PWD/3rdparty/include
LIBS += -Wl,-rpath,$$PWD/3rdparty/lib -L$$PWD/3rdparty/lib
LIBS += -ltetio -lboost_system -lboost_thread

#QMAKE_CXXFLAGS += -g -ggdb

SOURCES += \
	eyetracker.cpp \
	calibrator.cpp \
	main.cpp \
	player.cpp \
	recorder.cpp

HEADERS += \
	eyetracker.h \
	calibrator.h \
	player.h \
	recorder.h

RESOURCES += qml.qrc
