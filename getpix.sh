#!/usr/bin/bash
# SJP 30 Dec 2015
#
# Copy photos from a cam-equipped raspi

campi="neatherd"

scp $campi:/home/st33v/pix/*.jpg /home/st33v/cams/$campi/.
ssh $campi "rm /home/st33v/pix/*.jpg"
