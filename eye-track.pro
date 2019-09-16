# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright © 2016-2018 Neus Diagnostics, d.o.o.

CONFIG += c++1z

QT += qml quick widgets

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

RESOURCES += main.qrc media.qrc tasks.qrc

exists("$$PWD/3rdparty/lib/*tobii_research*") {
	DEFINES += USE_TOBII
	SOURCES += eyetracker-tobii.cpp
	HEADERS += eyetracker-tobii.h
	INCLUDEPATH += $$PWD/3rdparty/include
	LIBS += -L$$PWD/3rdparty/lib -ltobii_research
}
