
####################--PowerShell Configure QB services to be postqbinstall setup ###########

<# TTT        CheckQBServices.ps1      TTT
  .SYNOPSIS
    Check to see if a QuickBooks updates has changed configurations, then change them back to our configuations
  .DESCRIPTION
    This will change login type and restart for QuickBooks Services and move junk files out of normal startup. 
  
  .NOTES
    Version:        1.3 Modify Date 7/30/23 Looked for groupNoScriptSTOP to stop modify NTFS rights
    Author:         Mike Ryan   
    Creation Date:  08/10/21
    Purpose/Change: To run this right after a QuickBook install. This will do many things
    1. Remove the jumk in all users forlder
    2. Setup QuickBooks damanager service to run as localsystem
    
    4. Rename the QBdownload33 folder to stop ghost popups for an update.(This should run as a scheduled tast for when users log in)
    5. Setup a schedule tast upon log in to check server's status of QuickBooks configurations
    #>
##move Junk items
Move-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\QuickBooks*", 
                "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\Intuit*"  -Destination C:\NoobehIT\ServerSetup\MISCsoftware\QBjunk -Force

                # Look for Downloadqb33 folder that causes qhoast popup for users. Remove them
$folderPath = "F:\DATA\AppsData\Qbooks" 
Get-ChildItem -Path $folderPath -Filter "*DownloadQB*" -Recurse | Remove-Item -force -recurse -ErrorAction SilentlyContinue
            #Look for Downloadqb** folders from hidden C:\ProgramData\Intuit\QuickBooks Enterprise Solutions 23.0\Components
# Specify the root folder path
$RootFolder = "C:\ProgramData\Intuit"   
# Get all subfolders recursively
$Subfolders = Get-ChildItem -Path $RootFolder -Directory -Recurse | Where-Object { $_.Name -like "DownloadQB*" }
# Display the subfolder paths
$Subfolders | ForEach-Object {
    Write-Output $_.FullName
    Remove-Item -Path  $_.FullName -Recurse
}

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
