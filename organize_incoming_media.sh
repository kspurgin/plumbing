#!/bin/sh -ex

WorkingDir="/media/Storage"
IncomingDir="$WorkingDir/incoming_media"
BackupDir="$WorkingDir/backup_incoming_media"
PhotosDir="$WorkingDir/Photos"
VideosDir="$WorkingDir/Videos_personal"

cd "$WorkingDir" || error_exit "Could not get into working dir"

#echo "Backing up incoming media directory before operating..."
#cp -ar "$IncomingDir" "$BackupDir" || error_exit "Unable to backup incoming media directory."

cd "$IncomingDir" || error_exit "Could not get into incoming media dir"

createdate_from_filename () {
    filelist=$1
    label=$2
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo "$label -- Setting DateTimeOriginal, CreateDate and ModifyDate from file name"
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    FileCount=$(wc -l < "$filelist") || error_exit "Could not produce count of $label"
    if [ $FileCount -eq 0 ]
    then
	echo "There are no images to process."
    else
	skipped=0
	changed=0
	while IFS= read -r filename <&3;
	do
	    ExDate=$(exiftool -createdate "$filename") || error_exit "Couldn't read $filename createdate"
	    if [ "$ExDate" = "" ]
	    then
		exiftool -q -overwrite_original_in_place "-alldates<filename" "$filename" || error_exit "Couldn't set createdate from filename: $filename"
		changed=$(($changed + 1))
	    else
		skipped=$(($skipped + 1))
	    fi
	done 3< "$filelist"
    fi
    echo "$FileCount total files. $changed files updated. $skipped files skipped."
    echo ""
    rm -f "$filelist" || error_exit "Could not delete $filelist"
}

# ^magnifier - will have to set -createdate by parsing file name
ls magnifier* > listmagnifier.txt || error_exit "Could not build list of magnifier images"
createdate_from_filename listmagnifier.txt "Magnifier images"

# ^Screenshot - will have to set -createdate by parsing file name. Blech.
ls Screensho* > listscreenshot.txt || error_exit "Could not build list of screenshots"
createdate_from_filename listscreenshot.txt Screenshots

# ^TRIM - -filemodifydate contains the date of the original video
#        -createdate is the date of the trimmed video
#        Set -createdate to have the value from -filemodifydate
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "TRIM videos -- Setting CreateDate from file name"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
ls TRIM* > listtrim.txt || error_exit "Could not build list of TRIM videos"
FileCount=$(wc -l < "listtrim.txt") || error_exit "Could not produce count of TRIM videos"
if [ $FileCount -eq 0 ]
then
    echo "There are no images to process."
else
    skipped=0
    changed=0
    while IFS= read -r filename <&3;
    do
	exiftool -q -overwrite_original_in_place "-createdate<filename" "$filename" || error_exit "Couldn't set createdate from filename: $filename"
	changed=$(($changed + 1))
    done 3< "listtrim.txt"
fi
echo "$FileCount total files. $changed files updated. $skipped files skipped."
echo ""
rm -f "listtrim.txt" || error_exit "Could not delete listtrim.txt"

# ^IMG - if no -createdate, use -modifydate as that value

# Handles error exiting and messages
# from http://linuxcommand.org/wss0150.php
error_exit () {
    echo "$1" 1>&2
    exit 1
}
