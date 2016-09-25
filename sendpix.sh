#!/usr/bin/bash
# SJP 22 Feb 2016
#
# Send (copy) webcam pix from master repository (on the LAN) to remote computer with web server.
# This script is to be called from a systemd timer.

# The name of the system that has the webcamn attached.
# While this is presently hard-coded, we can abstract this for laster iterations when there are more than one cam.
campi="neatherd"
# remote server
wanWebServer="f3rr3t.com"

# select the most recent pic
newpic=$(ls -t ~/cams/$campi/ | head -1 )

scp /home/st33v/cams/$campi/$newpic $wanWebServer:/home/st33v/farm/cam/$campi/.


#exit(0)     # force succes exit code for fussy systemd
