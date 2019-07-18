# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright © 2018 Neus Diagnostics, d.o.o.

QT += qml quick widgets quickcontrols2

CONFIG += c++11

#QMAKE_CXXFLAGS += -g -ggdb

DEFINES += GIT_VERSION="\\\"$(shell git -C \""$$_PRO_FILE_PWD_"\" rev-parse --short HEAD)\\\""

SOURCES += \
	main.cpp \
	fileio.cpp

HEADERS += \
	fileio.h

RESOURCES += player.qrc ../media.qrc ../tasks.qrc
