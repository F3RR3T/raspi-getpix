#!/usr/bin/bash
# SJP 30 Dec 2015
#
# Copy photos from a cam-equipped raspi

# hard-code source hostname for the moment
campi="neatherd"
sourcedir="/home/st33v/pix/"    # where the image is on the source computer (i.e. $campi)
thisdir="/home/st33v/cams/"     # this directory (on this computer)

# get the filename of the photo, but only the most recent
newestpicfunc () { newestpic=$(ls ${thisdir}${campi}/*.jpg -t | head -1); }

# record the latest photo BEFORE we look for a new one
newestpicfunc; oldpic=${newestpic}

echo "Before: oldpic is ${oldpic}"

# Copy any photos from the camera-equipped source ($campi)
# This script is on a rapid timer so there should only ever be one photo (if any).
scp ${campi}:${sourcedir}*.jpg ${thisdir}${campi}/. 2>/dev/null
# Delete the phot from the source computer.
ssh $campi "rm ${sourcedir}*.jpg" 2>/dev/null
# cp ${oldpic} ${thisdir}${campi}/zzz.jpg   # testing 

# get the filename of the NEW photo, it there is one
newestpicfunc; newpic=${newestpic}

echo "After: newpic is ${newpic}"

if [[ "$oldpic" == "$newpic" ]] ; then 
    # echo no new photos so exit now
    exit 0
fi

# NeatHerd doesn't have enough RAM to perform image processing, so let's try it on STAN

convert ${newpic} -unsharp 1.5x1+0.7+0.02 ${thisdir}/temp.jpg
convert ${thisdir}/temp.jpg -resize 33% -quality 70 ${newpic}
rm ${thisdir}/temp.jpg
   
. ~/cams/sendpix.sh

#exit(0)     # force success exit code for fussy systemd
