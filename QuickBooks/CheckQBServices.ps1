
##move Junk items
Move-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\QuickBooks*",     "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\Intuit*"  -Destination C:\NoobehIT\ServerSetup\MISCsoftware\QBjunk -Force

##CheckQB services Status
$list = get-service QuickBooks* #Get all QBDB services into an array

$lastQBService = $list[$list.count -1]  #We only want the latest version of QBDB. ignore others
If ($lastQBService.StartType -ne "Automatic" ) #if it is not set to Automatic start up, set it
    {
    set-Service -name $lastQBService.DisplayName -startuptype Automatic
    }
If ($lastQBService.status -ne "Running" ) #if it is not running, Run it.
    {
    Start-Service -name $lastQBService.DisplayName 
    }
