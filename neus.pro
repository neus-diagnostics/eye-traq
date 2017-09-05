QT += qml quick widgets

CONFIG += c++11

#QMAKE_CXXFLAGS += -g -ggdb

DEFINES += GIT_VERSION="\\\"$(shell git -C \""$$_PRO_FILE_PWD_"\" rev-parse --short HEAD)\\\""

SOURCES += \
	eyetracker.cpp \
	main.cpp \
	player.cpp \
	recorder.cpp

HEADERS += \
	eyetracker.h \
	player.h \
	recorder.h

RESOURCES += neus.qrc

exists("$$PWD/3rdparty/lib/*tobii_research*") {
	DEFINES += USE_TOBII
	SOURCES += eyetracker-tobii.cpp
	HEADERS += eyetracker-tobii.h
	INCLUDEPATH += $$PWD/3rdparty/include
	LIBS += -Wl,-rpath,$$PWD/3rdparty/lib -L$$PWD/3rdparty/lib
	LIBS += -ltobii_research -ltobii_pro -ltobii_stream_engine
}
