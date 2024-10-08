
####################--PowerShell Configure QB services to be postqbinstall setup ###########

<# TTT        CheckQBServices.ps1      TTT
  .SYNOPSIS
    Check to see if a QuickBooks updates has changed configurations, then change them back to our configuations
  .DESCRIPTION
    This will change login type and restart for QuickBooks Services and move junk files out of normal startup. 
  
  .NOTES
    Version:        1.5 Modify Date 8/12/24 
    Author:         Mike Ryan   
    Creation Date:  08/10/21 update 080124
    Purpose/Change: To run this right after a QuickBook install. This will do many things
    1. Remove the jumk in all users forlder
    2. Remove Download folders
    3. Kill all running QuickBooksUpdates.exe
    5. Reconfigure QuickBooks database service to run as system
    #>
##----------------------move Junk items-------------------------------------------------------------
Move-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\QuickBooks*", 
                "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\Intuit*"  -Destination C:\NoobehIT\ServerSetup\MISCsoftware\QBjunk -Force

                ##Stop the update service
Set-Service -Name "QBUpdateMonitorService" -StartupType Disabled
Stop-Service -Name "QBUpdateMonitorService" -force
##---------------------------Kill Updates.exe-------------------------------------------------
Get-Process qbupdate -ErrorAction SilentlyContinue | Stop-Process -PassThru -Force #Find all update processes and kill them

                # Look for Downloadqb33 folder that causes qhoast popup for users. Remove them
$folderPath = "F:\DATA\AppsData\Qbooks" 
Get-ChildItem -Path $folderPath -Filter "*DownloadQB*" -Recurse | Remove-Item -force -recurse -ErrorAction SilentlyContinue
            #Look for Downloadqb** folders from hidden C:\ProgramData\Intuit\QuickBooks Enterprise Solutions 23.0\Components

$RootFolder = "C:\ProgramData\Intuit"   # Specify the root folder path
$Subfolders = Get-ChildItem -Path $RootFolder -Directory -Recurse | Where-Object { $_.Name -like "DownloadQB*" } # Get all subfolders recursively
# Display the subfolder paths & delete
$Subfolders | ForEach-Object {
    Write-Output $_.FullName
    Remove-Item -Path  $_.FullName -Recurse -Force
}


$RootFolder = "C:\Program Files\Intuit"   # Specify the root folder path
$Subfolders = Get-ChildItem -Path $RootFolder -Directory -Recurse | Where-Object { $_.Name -like "DownloadQB*" } # Get all subfolders recursively
# Display the subfolder paths & delete
$Subfolders | ForEach-Object {
    Write-Output $_.FullName
    Remove-Item -Path  $_.FullName -Recurse
}


##----------------------------------CheckQB services Status------------------------------------
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

 <# 
  .DESCRIPTION
   Setup QB services so they restart after failure and "Automatic" and "Localsystem" to run under
#>
# Define the service name
$serviceName = $lastQBService.DisplayName

sc.exe failure $serviceName reset= 86400 actions= restart/60000/restart/400000/restart/800000 ## Note related to QucikBooks but better health of server restarts

# Get the service object using CIM
##$service = Get-CimInstance -ClassName Win32_Service -Filter "Name='$serviceName'"

# Change the service to run as LocalSystem
Invoke-CimMethod -InputObject $service -MethodName Change -Arguments @{StartName="LocalSystem"}

# Restart the service to apply changes
#Restart-Service -Name $serviceName