#!/bin/bash
set -e

if [ "$XVFB_ENABLED" == "true" ]
then
  # start X Window Virtual Framebuffer
  Xvfb $DISPLAY -screen 0 640x480x8 -nolisten tcp &
fi

# Start AusweisApp2
/usr/local/bin/AusweisApp2 &

# Start PersoSim
/home/ausweisapp/persosim/PersoSim -data /home/ausweisapp/.config/persosim &

# Wait for any process to exit
wait -n

# Exit with status of process that exited first
exit $?
