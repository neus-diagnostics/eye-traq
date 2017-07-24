QT += qml quick widgets

CONFIG += c++11

#QMAKE_CXXFLAGS += -g -ggdb

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
	recorder.h

RESOURCES += neus.qrc

exists($$PWD/3rdparty/lib/libtobii_research.so) {
	DEFINES += USE_TOBII
	SOURCES += eyetracker-tobii.cpp
	HEADERS += eyetracker-tobii.h
	INCLUDEPATH += $$PWD/3rdparty/include
	LIBS += -Wl,-rpath,$$PWD/3rdparty/lib -L$$PWD/3rdparty/lib
	LIBS += -ltobii_research -ltobii_pro -ltobii_stream_engine
}
