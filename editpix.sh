#!/usr/bin/bash
# 10Jan2017: V2 (pix are pushed to STAN for processing; replace TIMERS with PATH services)
# SJP 30 Dec 2015 V1 (Copy and process photos from a cam-equipped raspi)

########### Constants ##################
web="example.com:/path/to/remote/camrootdir"      # web server. configured in paths.config
thisdir="/path/to/cams"     # this directory (on this computer) Configured in paths.config
if [ -e /usr/local/share/editpix/paths.config ]; then
    . /usr/local/share/editpix/paths.config
else echo "paths.config does not exist, see readme"; exit 1
fi
threshold="2000"     # minimum value of average pixel brightness. Tests if pic is too dark
########### end Consts ################

# cam names in an array:
declare -a camz=(neatherd lucerne)

cd ${thisdir}               # root directory for uploaded pix

for campi in "${camz[@]}"
do
    # filename of the latest photo 
    newpic=$(ls "$campi"/*.jpg -t 2>/dev/null | head -1)
    # echo newpic=$newpic

    # Is the newest pic older than the marker we placed previously?
    if [ -e "$campi" ]; then
        if [ "$newpic" -ot mark-"$campi" ]; then continue; fi
    else
        touch mark-$campi  # should only happen on the first ever execution
    fi
    # Check to see if the pic is too dark (i.e. taken at night)
    mean=$(identify -format %[mean] ${newpic} | sed s/[.].*//)
    # echo "mean is $mean"
    # too dark (nighttime)
    if [[ "${mean}" -lt "${threshold}" ]] ; then
        rm $newpic
     #   echo mean of $mean is too low. It is nighttime.
        continue
    fi

    # Improve sharpness and resize photo, ready for upload to webserver
    # Break into two steps to avoid out-of-memory errors (OS kills process)
    convert ${newpic} -unsharp 1.5x1+0.7+0.02 transfer.jpg
    convert transfer.jpg -resize 33% -quality 70 transfer.jpg

    # Create a marker file with the name of the webcam, so next time we can
    # check to see if a new photo is present for that camera; the PATH
    # may have been triggered by a phot from another camera.
    touch mark-$campi
    # upload latest pic to web server
#    echo "/home/st33v/cams/$newpic"
#    echo "$web:/home/st33v/farm/cam/$campi/"
    scp  transfer.jpg $web/$campi/.
    touch bump-$(hostname)
    scp bump-$(hostname) $web/.
    rm transfer.jpg
done
#exit(0)     # force success exit code for fussy systemd
