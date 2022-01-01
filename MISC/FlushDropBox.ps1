## flush DropBox
##Put this on scheduled task to run everyone someone logs on
stop-process -name Dropbox  -force ##This kills all running Dropboxes under all users
Start-Sleep -s 4
restart-Service -name DbxSvc -force ##Jumpstart service
Start-Sleep -s 4
& 'C:\Program Files (x86)\Dropbox\Client\Dropbox.exe' \home ##start it back up clean