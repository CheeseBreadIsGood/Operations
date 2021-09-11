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

Function Get-NoobehData {
  #Open the NoobehNAS
net use \\noobehnas.file.core.windows.net\cloudnas /u:AZURE\noobehnas **************Thisisthekeyforittocopythefiles**********
#Copy important files over to the new server
Copy-Item \\noobehnas.file.core.windows.net\cloudnas\ServerSetup\AdminScript\* C:\NoobehIT\ServerSetup\AdminScripts\ -Recurse -Force
net use /delete \\noobehnas.file.core.windows.net\cloudnas
}
Function Set-NTFSsecurity{
    
 
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
    
sc.exe failure Tssdis reset= 86400 actions= restart/60000/restart/60000/restart/60000 ## Note related to QucikBooks but better health of server restarts

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

Get-NoobehData  #get new scripts from nas to local system
Set-NTFSsecurity ## add local system NTFS security to folders
Set-ScheduledQuickBooksCheck ## run the new scripts anytime someone logs in.

Set-ServerServices ## for QuickBooks services to automatic 
Move-QBjunk ##QuickBooks extra autostart crap. Removed.