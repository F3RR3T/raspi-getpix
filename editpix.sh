#!/usr/bin/bash
# 10Jan2017: V2 (pix are pushed to STAN for processing; replace TIMERS with PATH services)
# SJP 30 Dec 2015 V1 (Copy and process photos from a cam-equipped raspi)

########### Constants ##################
wanWebServer="f3rr3t.com"
#sourcedir="/home/st33v/pix"    # where the image is on the source computer (i.e. $campi)
thisdir="/home/st33v/cams"     # this directory (on this computer)
threshold="2000"               # minimum value of average pixel brightness. Tests if pic is too dark
########### end Consts ################

# cam names in an array:
#declare -a camz=(neatherd lucerne)

########### Functions ##################
# get the filename of the most recent photo stored on this computer.
########### end Funcs #################

cd ${thisdir}

    # record the latest photo BEFORE we look for a new one
    newpic=$(ls "$campi"/*.jpg -t | head -1);

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
    convert ${newpic} -unsharp 1.5x1+0.7+0.02 temp.jpg
    convert temp.jpg -resize 33% -quality 70 ${newpic}
    rm temp.jpg

    # upload latest pic to web server
#    echo "/home/st33v/cams/$newpic"
#    echo "$wanWebServer:/home/st33v/farm/cam/$campi/"
    scp /home/st33v/cams/$newpic $wanWebServer:/home/st33v/farm/cam/$campi/.

#exit(0)     # force success exit code for fussy systemd
