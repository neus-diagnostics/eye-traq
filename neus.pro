QT += qml quick widgets

CONFIG += c++11

#QMAKE_CXXFLAGS += -g -ggdb

DEFINES += GIT_VERSION="\\\"$(shell git -C \""$$_PRO_FILE_PWD_"\" rev-parse --short HEAD)\\\""

SOURCES += \
	eyetracker.cpp \
	eyetracker-mouse.cpp \
	main.cpp \
	recorder.cpp

HEADERS += \
	eyetracker.h \
	eyetracker-mouse.h \
	recorder.h

RESOURCES += neus.qrc media.qrc tasks.qrc

exists("$$PWD/3rdparty/lib/*tobii_research*") {
	DEFINES += USE_TOBII
	SOURCES += eyetracker-tobii.cpp
	HEADERS += eyetracker-tobii.h
	INCLUDEPATH += $$PWD/3rdparty/include
	LIBS += -L$$PWD/3rdparty/lib -ltobii_research
}
