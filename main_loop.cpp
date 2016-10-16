#include "main_loop.h"

MainLoop::~MainLoop()
{
	quit();
	wait();
}

void MainLoop::run()
{
	thread.run();
}

void MainLoop::quit()
{
	thread.quit();
}
