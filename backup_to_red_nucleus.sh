cd /media/Storage

# photos
rsync --itemize-changes --progress --exclude baklog.txt -avh ./Photos/ /media/amanita/Red\ nucleus/media/photos_personal/ | tee baklog.txt

# cam photos
rsync --itemize-changes --progress --exclude baklog.txt -avh ./Photos_cam/ /media/amanita/Red\ nucleus/media/photos_cam/ | tee baklog.txt

# personal videos
rsync --itemize-changes --progress --exclude baklog.txt -avh ./Videos_personal/ /media/amanita/Red\ nucleus/media/videos_personal/ | tee baklog.txt

# documents
rsync --itemize-changes --progress --exclude baklog.txt -avh ./Documents/ /media/amanita/Red\ nucleus/documents/ | tee baklog.txt

cd /home
# home
rsync --itemize-changes --progress --exclude baklog.txt -avh ./amanita/ /media/amanita/Red\ nucleus/home/ | tee baklog.txt
