####################--PowerShell Configure QB services to be Unicorn setup ###########

<# TTT        PoastQuickBooksConfig.ps1      TTT
  .SYNOPSIS
    Used after a normal QuickBooks install to clean up and make Unicron 
  .DESCRIPTION
    This will change login type and restart for QuickBooks Services and move junk files out of normal startup. 
  
  .NOTES
    Version:        1.0
    Author:         Mike Ryan   
    Creation Date:  08/10/21
    Purpose/Change: To run this right after a QuickBook install
#>

Function Set-ServerServices{
    ### Set server as Domain Controller
sc.exe failure Tssdis reset= 86400 actions= restart/60000/restart/60000/restart/60000 

sc.exe failure QBCFMonitorService reset= 86400 actions= restart/60000/restart/60000/restart/60000 
sc.exe config  QBCFMonitorService obj="Localsystem"
 set-Service -name QBCFMonitorService -startuptype Automatic

Set-service -name QBIDPservice -StartupType Disable 



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

 
 $runcommand = "sc.exe failure $($lastQBService.DisplayName) reset= 86400 actions= restart/60000/restart/60000/restart/60000 #60,000 is 1 minute "
 Invoke-expression $runcommand

 $runCommand = sc.exe config $($lastQBService.DisplayName) obj="Localsystem"
 Invoke-expression $runcommand
}
Function Move-QBjunk{
Move-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\QuickBooks*", 
    "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\Intuit*"  -Destination C:\NoobehIT\ServerSetup\MISCsoftware\QBjunk
}


## functions to finish

Move-Data  #get new scripts from nas to local system
Set-NTFSsecurity ## add service to folders
Set-ScheduledJob ## run the new scripts anytime someone logs in.

Set-ServerServices
Move-QBjunk