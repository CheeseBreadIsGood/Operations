####################--PowerShell Configure QB services to be Unicorn setup ###########

<# TTT        PoastQuickBooksConfig.ps1      TTT
  .SYNOPSIS
    Used after a normal QuickBooks install to clean up and make Unicron 
  .DESCRIPTION
    This will change login type and restart for QuickBooks Services and move junk files out of normal startup. 
  
  .NOTES
    Version:        1.4 Modify Date 7/30/23 Looked for groupNoScriptSTOP to stop modify NTFS rights
    Author:         Mike Ryan   
    Creation Date:  08/10/21
    Purpose/Change: To run this right after a QuickBook install. This will do many things
    1. Remove the jumk in all users forlder
    2. Setup QuickBooks damanager service to run as localsystem
    3. Change the NTFS security rights to proper settings (unless the groupNoScriptSTOP is there)
    4. Rename the QBdownload33 folder to stop ghost popups for an update.(This should run as a scheduled tast for when users log in)
    5. Setup a schedule tast upon log in to check server's status of QuickBooks configurations
    #>

Function Search-UserGroups{

  Get-ChildItem -Path "F:\DATA\AppsData\Qbooks" | ForEach-Object {
    $path = $_.FullName
    $acl = Get-Acl $path
    $accessRules = $acl.Access
    foreach ($accessRule in $accessRules) {
        Write-Host "$path $($accessRule.IdentityReference) $($accessRule.FileSystemRights)"
        If (($accessRule.IdentityReference -like "NT SERVICE\MSSQL$*") -or ($accessRule.IdentityReference -like "cloud\groupNoScriptSTOP"))
        {  write-host "Found It" -ForegroundColor Cyan
           return $true
        }
    }
  }
}   #end function

Function Set-NTFSsecurity{
  <#   DESCRIPTION
   Make sure the Qbooks folder has SYSTEM with modify rights for the QBdatabase.
  #>
   ## Blow out and remove all File INHERITANCE########################

$folder = 'F:\DATA\appsData\Qbooks'
$acl = Get-ACL -Path $folder
$acl.SetAccessRuleProtection($True, $False) #remote inheritance & remove users
Set-Acl -Path $folder -AclObject $acl #set it
  
  ## Now add in administrators ########################
$FolderPath = "F:\DATA"
$ACL = Get-Acl $FolderPath
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    'builtin\Administrators', #Identity
    'FullControl', # Rights
    'ContainerInherit,ObjectInherit',   #'ContainerInherit,ObjectInherit'  This folder and everything below
    <#
    Inheritance is what types child objects the ACE applies to. With a filesystem, containers = folder, objects = files.
    Propagation controls which generation of child objects the ACE is restricted to. None= ACE appliies to all.
    InheritOnly = ACe applies only to children and grandchildren, not to target folder. 
    NoPropagateinherit = Target folder and target folder children, not grandchildren.
    Https://msdn.microsoft.com/en-us/library/ms229747(v=vs.110).aspx
    #>
    'None',   #propagation  NoPropagateInherit (the ACE is not propagated to any current child objects)
    'Allow')  #type set for this rule "Allow' Or 'Deny'
$ACL.AddAccessRule($AccessRule)  # Now add the new rule to the temp ACL object, but it is not set back onto the system yet.
Set-Acl $FolderPath -AclObject $ACL  #set it and forget it.


$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    'cloud\Domain Users', #Identity
    'Modify', # Rights
    'ContainerInherit,ObjectInherit',   #'ContainerInherit,ObjectInherit'  This folder and everything below
    'None',   #propagation  NoPropagateInherit (the ACE is not propagated to any current child objects)
    'Allow')  #type set for this rule "Allow' Or 'Deny'
$ACL.AddAccessRule($AccessRule)  # Now add the new rule to the temp ACL object, but it is not set back onto the system yet.
Set-Acl $FolderPath -AclObject $ACL  #set it and forget it.
  
## Setup SYSTEM in qbooks folder
$folder = 'F:\DATA'
$acl = Get-ACL -Path $folder
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    'cloud\Domain Users', #Identity
    'Modify', # Rights
    'ContainerInherit,ObjectInherit',   #'ContainerInherit,ObjectInherit'  This folder and everything below
    'None',   #propagation  NoPropagateInherit (the ACE is not propagated to any current child objects)
    'Allow')  #type set for this rule "Allow' Or 'Deny'
$ACL.AddAccessRule($AccessRule)  # Now add the new rule to the temp ACL object, but it is not set back onto the system yet.
Set-Acl $FolderPath -AclObject $ACL  #set it and forget it.


## Setup SYSTEM in qbooks folder
$folderPath = 'F:\DATA\AppsData\Qbooks'
$acl = Get-ACL -Path $folder
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    'NT authority\system', #Identity
    'Modify', # Rights
    'ContainerInherit,ObjectInherit',   #'ContainerInherit,ObjectInherit'  This folder and everything below
    'None',   #propagation  NoPropagateInherit (the ACE is not propagated to any current child objects)
    'Allow')  #type set for this rule "Allow' Or 'Deny'
$ACL.AddAccessRule($AccessRule)  # Now add the new rule to the temp ACL object, but it is not set back onto the system yet.
Set-Acl $FolderPath -AclObject $ACL  #set it and forget it.

  ### END adding security for USERS and Admins #>
}
Function Set-ScheduledQuickBooksCheck{ 
<# 
  .DESCRIPTION
  Setup a schedule for all users logoning in to start the QBdatabase if it is not running.
#>
  Function New-ScheduledTaskFolder

  {

   Param ($taskpath)
   $ErrorActionPreference = "stop"
   $scheduleObject = New-Object -ComObject schedule.service
   $scheduleObject.connect()
   $rootFolder = $scheduleObject.GetFolder("\")
      Try {$null = $scheduleObject.GetFolder($taskpath)}
      Catch { $null = $rootFolder.CreateFolder($taskpath) }
      Finally { $ErrorActionPreference = "continue" }
  }
 
## Create folder
New-ScheduledTaskFolder Noobeh

$action = New-ScheduledTaskAction -Execute "C:\NoobehIT\ServerSetup\AdminScripts\RunPowershellScripts.cmd"
$trigger = New-ScheduledTaskTrigger -AtLogon
$principal = New-ScheduledTaskPrincipal -UserID 'Cloud\ServerAdmin' -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet 
$task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings

Register-ScheduledTask CheckQBStatus -InputObject $task -TaskPath "Noobeh"
Enable-ScheduledTask -TaskName CheckQBStatus  -TaskPath "Noobeh"

}
Function Set-ServerServices{
<# 
  .DESCRIPTION
   Setup QB services so they restart after failure and "Automatic" and "Localsystem" to run under
#>
sc.exe failure Tssdis reset= 86400 actions= restart/60000/restart/400000/restart/800000 ## Note related to QucikBooks but better health of server restarts

sc.exe failure QBCFMonitorService reset= 86400 actions= restart/60000/restart/60000/restart/60000 
sc.exe config  QBCFMonitorService obj="Localsystem"
set-Service -name QBCFMonitorService -startuptype Automatic

Set-service -name QBIDPservice -StartupType Disable 
Set-service -name QBUpdateMonitorService -StartupType Disable 


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

 $runCommand = "sc.exe config $($lastQBService.DisplayName) obj=LocalSystem"
 Invoke-expression $runcommand
}
Function Move-QBjunk{
  <# 
  .DESCRIPTION
   Clear out the QB junk folder that puts several junk startups.
#>
Move-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\QuickBooks*",     "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\Intuit*"  -Destination C:\NoobehIT\ServerSetup\MISCsoftware\QBjunk -force
Remove-Item "C:\Users\Public\Desktop\QuickBooks File Manager 2023.lnk"  #not needed.
}
Function Rename-QBDownloadFolder{  #This function is also used in scheduled task
  $folderPath = "F:\DATA\AppsData\Qbooks" 
  Get-ChildItem -Path $folderPath -Filter "*DownloadQB*" -Recurse | Remove-Item -force -recurse -ErrorAction SilentlyContinue

}

## functions to finish
   Set-ScheduledQuickBooksCheck ## run the new scripts anytime someone logs in.
   Set-ServerServices ## for QuickBooks services to automatic 
   Move-QBjunk ##QuickBooks extra autostart crap. Removed.
 