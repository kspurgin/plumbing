#/bin/bash -ex

# The ID for the phone might change every time you plug it in. To get the ID, do:
# $ lsub
# Look for the info for Motorola PCS
Id="22b8:2e62"

StagingDir="/media/Storage/incoming_media/"

# Handles error exiting and messages
# from http://linuxcommand.org/wss0150.php
error_exit () {
	echo "$1" 1>&2
	exit 1
}

# Does repetitive thing of going to a given directory, deleting all its contents,
#  and reporting on it
# Call with (1) label for directory; (2) path of directory
clear_directory () {
    label=$1
    path=$2
    echo ""
    echo "Will delete all contents of phone's $label directory... ($path)"
    cd "$path" || error_exit "Cannot change into $label directory."
    rm -f * || error_exit "Could not delete all items from $label directory."
    echo "All items deleted from $label directory."
}

# Find the path to MTP/PTP connected device by USB ID
# Swiped from http://askubuntu.com/questions/342319/where-are-mtp-mounted-devices-located-in-the-filesystem
find_path_by_usbid () {
        lsusboutput="$(lsusb -d $1 | head -n1)"
        usbbus="${lsusboutput% Device*}"
        usbbus="${usbbus#Bus }"
        usbdevice="${lsusboutput%%:*}"
        usbdevice="${usbdevice#*Device }"

        # Media Transfer Protocol
        if [ -d "$XDG_RUNTIME_DIR" ]
	then
            runtimedir="$XDG_RUNTIME_DIR"
        else
            runtimedir="/run/user/$USER"
        fi
        MtpPath="$runtimedir/gvfs/mtp:host=%5Busb%3A${usbbus}%2C${usbdevice}%5D"
        # Picture Transfer Protocol
        PtpPath="$runtimedir/gvfs/gphoto2:host=%5Busb%3A${usbbus}%2C${usbdevice}%5D"

        if [ -d "$MtpPath" ]
	then
                echo "$MtpPath"
        elif [ -d "$PtpPath" ]
	then
                echo "$PtpPath"
        else
                echo "Error: File or directory was not found."
        fi
}

echo "This script will:"
echo " - move all your photos and videos from phone camera reel to computer"
echo " - move all your photos and videos from phone gallery albums to computer"
echo " - move all Smart Tools photos from phone to computer"
echo " - clear out the following folders on the phone WITHOUT copying them to computer:"
echo "   - Facebook - Instagram -Tumblr - Screenshot - Downloads - Custom"
echo ""
echo -n "Do you want to continue now? (y/n) : "
read answer
if [ "$answer" = "n" ]
then
    echo "OK. Come back later..."
    exit
fi

DevicePath="$(find_path_by_usbid $Id)/Internal storage"

echo "\n\nDevice path is: $DevicePath"

# Backup pictures if device is connected
if [ "$DevicePath" = "Error: File or directory was not found." ]
then
        echo "$DevicePath"
        exit 1
else
    # Transfer photos and videos to staging directory and delete them from phone
    CameraPath="$DevicePath/DCIM/Camera/"
    echo ""
    echo "-=-=-=-=-=-=-Starting rsync-=-=-=-=-=-=-=-=-=-=-"
    rsync -av --progress "$CameraPath" "$StagingDir" || error_exit "Transfer of camera files unsuccessful."
    echo "-=-=-=-=-=-=-rsync complete-=-=-=-=-=-=-=-=-=-=-"
    echo ""
    echo "All camera files transferred successfully."
    clear_directory "Camera Roll" "$CameraPath"

    # Transfer photos from Smart Tools to staging directory and delete them from phone
    SmartToolsPath="$DevicePath/smart-tools/"
    echo "-=-=-=-=-=-=-Starting rsync-=-=-=-=-=-=-=-=-=-=-"
    rsync -av --progress --exclude '*.txt' "$SmartToolsPath" "$StagingDir" || error_exit "Transfer of Smart Tools images unsuccessful."
    echo "-=-=-=-=-=-=-rsync complete-=-=-=-=-=-=-=-=-=-=-"
    echo ""
    echo "All Smart Tools images transferred successfully."
    clear_directory "Smart Tools" "$SmartToolsPath"

    # Transfer photos and videos from album to staging directory and delete them from phone
    AlbumPath="$DevicePath/Pictures/Plants posted/"
    echo ""
    echo "-=-=-=-=-=-=-Starting rsync-=-=-=-=-=-=-=-=-=-=-"
    rsync -av --progress "$AlbumPath" "$StagingDir" || error_exit "Transfer of Plants posted files unsuccessful."
    echo "-=-=-=-=-=-=-rsync complete-=-=-=-=-=-=-=-=-=-=-"
    echo ""
    echo "All camera files transferred successfully."
    clear_directory "Plants posted album" "$AlbumPath"

    # Transfer photos and videos from album to staging directory and delete them from phone
    PgridPath="$DevicePath/Photo Grid/"
    echo ""
    echo "-=-=-=-=-=-=-Starting rsync-=-=-=-=-=-=-=-=-=-=-"
    rsync -av --progress "$PgridPath" "$StagingDir" || error_exit "Transfer of Photo Grid files unsuccessful."
    echo "-=-=-=-=-=-=-rsync complete-=-=-=-=-=-=-=-=-=-=-"
    echo ""
    echo "All camera files transferred successfully."
    clear_directory "Photo Grid" "$PgridPath"

    # Clear out other directories
    clear_directory "Facebook" "$DevicePath/DCIM/Facebook"
    clear_directory "Downloads" "$DevicePath/Download"
    clear_directory "Tumblr" "$DevicePath/Tumblr"
    clear_directory "Screenshots" "$DevicePath/Pictures/Screenshots"
    clear_directory "Instagram photos" "$DevicePath/Pictures/Instagram"
    clear_directory "Instagram videos" "$DevicePath/Movies/Instagram"
fi
