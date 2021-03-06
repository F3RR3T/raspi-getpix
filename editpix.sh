#!/usr/bin/bash
# 10Jan2017: V2 (pix are pushed to STAN for processing; replace TIMERS with PATH services)
# SJP 30 Dec 2015 V1 (Copy and process photos from a cam-equipped raspi)

########### Constants ##################
# These variables are defined in a local file "paths.config". The follwoing assignments
# show the format for the variables.
web="example.com:/path/to/remote/camrootdir"      # web server. configured in paths.config
thisdir="/path/to/cams"     # this directory (on this computer) Configured in paths.config

# cam names in an array:
declare -a camz=(cam1 cam2 cam3...)

if [ -e /usr/local/share/paths.config ]; then
    . /usr/local/share/paths.config
else echo "paths.config does not exist, see readme"; exit 1
fi
########### end Consts ################


cd ${thisdir}               # root directory for uploaded pix

for campi in "${camz[@]}"
do
    threshold=2000     # minimum value of average pixel brightness. Tests if pic is too dark
    if [ "${campi}" = "lucerne" ] ; then
        threshold=6000      # shocking hack to compensate for new cam type
    fi
    
    # filename of the latest photo 
    newpic=$(ls "$campi"/*.jpg -t 2>/dev/null | head -1)
    # echo newpic=$newpic

    # Is there a 'mark' file for this camera?
    if [ -e mark-${campi} ]; then
        # Is the newest pic older than (-ot) the marker we placed previously?
        if [ "$newpic" -ot mark-"$campi" ]; then 
            continue    # exit this iteration of the FOR loop.
        fi
    else
        touch mark-$campi  # should only happen on the first ever execution
    fi

    # Check to see if the pic is too dark (i.e. taken at night)
    mean=$(identify -format %[mean] ${newpic} | sed s/[.].*//)
    # echo "mean is $mean"
    # Test to see if it is too dark (nighttime)
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
    # may have been triggered by a photo from another camera.
    touch mark-$campi
    # upload latest pic to web server
    scp  transfer.jpg ${web}/${campi}/.
    touch bump-$(hostname)
    scp bump-$(hostname) ${web}/.
    rm transfer.jpg

    # cleanup any empty directories (such as when files are swept by another process)
    find ${campi}/. -type d -empty -delete
        # but DON'T delete the cam directories themselves. The cams expect them to exist.
done
#exit(0)     # force success exit code for fussy systemd
