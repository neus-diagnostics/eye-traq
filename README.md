Run eye-tracking experiments: display tasks and record participants’ eye movements.

# Compiling

This program is written in Qt5. An eyetracker is needed to record gaze data; currently only Tobii eyetrackers are supported. To enable support for Tobii eyetrackers, download the Tobii Pro SDK and place headers and libraries into `3rdparty/{include,lib}` before building.

Build and run with:

    qmake
    make
    ./eye-track

If you move the binary, make sure to also move (or link) the `share/` directory.

# Deploying

Two monitors are required in the *extended* configuration. The primary monitor shows the control view. The secondary monitor displays tests while the attached eyetracker records data.

The program assumes exactly one eyetracker is present. If using the Tobii 4C tracker, place the license key into `share/keys/<serial number>.key`.

## Windows

Due to missing drivers the Tobii Pro SDK only works with Windows. To set up a machine:

* install and configure the [Tobii eyetracker core software](https://tobiigaming.com/getstarted/?bundle=tobii-core&manualdownload=true) and
* install [directshow codecs](https://xiph.org/dshow) for playing sound clips.

A basic checklist of basic Windows optimizations for running experiments:

* Settings
    - Power & sleep: never turn off screen or go to sleep
    - Sound theme: No Sounds
    - Notifications & actions: off
    - Share across devices: off
    - Virus & threat protection: off
    - OneDrive: off
    - Privacy: maximum paranoia
* Software
    - Download [Ninite](ninite.com) and install firefox, libreoffice, sumatrapdf, vlc, winscp
    - Firefox: install https everywhere, ublock origin

The `scripts/` directory contains scripts (what else?) for setting up a SSH daemon and a Tor hidden service that can be used to bypass NAT. The scripts require [msys2](http://repo.msys2.org/distrib/msys2-x86_64-latest.exe).

# License

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. See `COPYING` for details.

The Lato fonts are distributed under the terms of the SIL Open Font License 1.1. See `media/OFL.txt` for details.
