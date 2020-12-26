cd /media/Storage

# photos
rsync --itemize-changes --progress --exclude baklog.txt -avh ./Photos/ /media/T___Fantom_Green_1TB/backups/spore/photos_personal/ | tee baklog.txt

# cam photos
rsync --itemize-changes --progress --exclude baklog.txt -avh ./Photos_cam/ /media/T___Fantom_Green_1TB/backups/spore/photos_cam/ | tee baklog.txt

# personal videos
rsync --itemize-changes --progress --exclude baklog.txt -avh ./Videos_personal/ /media/T___Fantom_Green_1TB/backups/spore/videos_personal/ | tee baklog.txt

# documents
rsync --itemize-changes --progress --exclude baklog.txt -avh ./Documents/ /media/T___Fantom_Green_1TB/backups/spore/documents/ | tee baklog.txt

# other images
rsync --itemize-changes --progress --exclude baklog.txt -avh ./Images/ /media/T___Fantom_Green_1TB/backups/spore/images/ | tee baklog.txt

cd /home
# home
rsync --itemize-changes --progress --exclude baklog.txt -avh ./amanita/ /media/T___Fantom_Green_1TB/backups/spore/home/ | tee baklog.txt
