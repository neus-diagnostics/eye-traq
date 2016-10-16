#ifndef MAIN_LOOP_H
#define MAIN_LOOP_H

#include <QThread>

#include <tobii/sdk/cpp/MainLoop.hpp>
namespace tetio = tobii::sdk::cpp;

class MainLoop : public QThread
{
	Q_OBJECT
public:
	virtual ~MainLoop();

	virtual void run();
	void quit();

        tetio::MainLoop thread;
};

#endif
