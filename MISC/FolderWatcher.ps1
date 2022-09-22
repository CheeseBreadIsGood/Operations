
################# __________________________ #######################
$PathSource = "F:\DATA\SharedData\FTPdata"
$PathDestination = "C:\NoobehIT\ServerSetup\AdminScripts\FTPdataStaging"
## DELETEDME $PathlogFile = "F:\DATA\SharedData\FTPdata"

$watcher = New-Object System.IO.FileSystemWatcher #create watcher object
# now add parameters
$watcher.IncludeSubdirectories = $true
$watcher.Path = $PathSource
$watcher.EnableRaisingEvents = $true
$action =
{

    Get-ChildItem -Path $PathSource | Where {!($_.PSIsContainer)} | Move-Item -Destination $PathDestination

}

Register-ObjectEvent $watcher 'Created' -Action $action

# to remove file watcher--> Get-EventSubscriber | Unregister-Event



