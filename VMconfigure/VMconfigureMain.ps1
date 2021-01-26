####################--PowerShell Configure New Server with external hard drive ###########

<# TTT        VMconfigureMain.ps1      TTT
  .SYNOPSIS
    Used to create a new server setup with all the default settings that noobeh requires
  .DESCRIPTION
    This will install some software configure external hard drive and create a default domain controller 
  
  .NOTES
    Version:        1.0
    Author:         Mike Ryan   
    Creation Date:  05/1/20
    Purpose/Change: Many years of converting manual work into this script. Goal is to "Set it and forget it" fuctionality
#>

Function Set-DomainController{
### Set server as Domain Controller
if ((gwmi win32_computersystem).partofdomain -eq $False) {

$PS =  ConvertTo-SecureString -string 'ThisIsVeryLong123^^' -AsPlainText -Force
Install-WindowsFeature -name AD-domain-Services -IncludeManagementTools
Install-ADDSForest -DomainName Cloud.local -InstallDNS -SafeModeAdministratorPassword $PS -force

#Set time zone et
Set-TimeZone "Eastern Standard Time"

### Add-WindowsFeature RDS-RD-Server, RDS-Connection-Broker, RDS-Web-Access
### Restart-computer -force



 
set-executionpolicy remotesigned -force

## Set server as Domain Controller
$PS =  ConvertTo-SecureString -string 'ThisIsVeryLong123^^' -AsPlainText -Force
##import-module servermanager

Install-WindowsFeature -name AD-domain-Services -IncludeManagementTools
Install-ADDSForest -DomainName Cloud.local -InstallDNS -SafeModeAdministratorPassword $PS -force

#Set time zone et
Set-TimeZone "Eastern Standard Time"
##Add-WindowsFeature RDS-RD-Server, RDS-Connection-Broker, RDS-Web-Access
Restart-computer -force
Exit 
}
}
<#                         ! NOT USED
import-module RemoteDesktop
New-RDSessionDeployment -ConnectionBroker "Server.Cloud.local" -WebAccessServer  "Server.Cloud.local" -SessionHost  "Server.Cloud.local"
New-rdSessionDeployment -ConnectionBroker server.cloud.local -SessionHost server.cloud.local
Add-RDServer -Server "Server.Cloud.local" -Role "RDS-WEB-ACCESS" -ConnectionBroker "Server.Cloud.local"
Add-RDServer -Server "Server.Cloud.local" -Role "RDS-GATEWAY" -ConnectionBroker "Server.Cloud.local" -GatewayExternalFqdn "MISYS.Noobeh.net"
Add-RDServer -Server "Server.Cloud.local" -Role "RDS-LICENSING" -ConnectionBroker "Server.Cloud.local" 


#let users remote desktop into server
Add-ADGroupMember -identity "Remote Desktop Users" -Members "Domain Users"
#>
Function Set-CopyNoobehFiles{
    #Open the NoobehNAS
net use \\noobehnas.file.core.windows.net\cloudnas /u:AZURE\noobehnas **************Thisisthekeyforittocopythefiles**********
#Copy important files over to the new server
New-Item -ErrorAction Ignore -ItemType directory -Path c:\NoobehIT
Copy-Item \\noobehnas.file.core.windows.net\cloudnas\ServerSetup\ c:\noobehIT -Recurse -Force
Copy-Item C:\NoobehIT\ServerSetup\Bginfo\BginfoSetting* "C:\Users\ServerAdmin\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
Copy-Item "C:\NoobehIT\ServerSetup\Graphics\Log Off Noobeh.lnk" "C:\Users\Public\Desktop\"
net use /delete \\noobehnas.file.core.windows.net\cloudnas
}
Function Set-DATAHarddrive{
    ## Format attached new Drive to Letter F:
#Bring data disks online and initialize them
#################### PowerShell Configure New Server with external hard drive ###########

Get-Disk | Where-Object PartitionStyle –Eq "RAW"| Initialize-Disk -PartitionStyle GPT   
Get-Disk -Number 2 | New-Partition -UseMaximumSize -DriveLetter F | Format-Volume -FileSystem NTFS -NewFileSystemLabel "DATA" -Confirm:$False      
#########################################################################################


## Not needed      New-Item -Path 'F:\DATA\' -ItemType Directory -ErrorAction Ignore 



###Now create the sub folders to this seconddary hard drive
New-Item -Path 'F:\DATA\AppsData' -ItemType Directory  -ErrorAction Ignore 
New-Item -Path 'F:\DATA\AppsData\Qbooks' -ItemType Directory  -ErrorAction Ignore 
New-Item -Path 'F:\DATA\AppsInstallers' -ItemType Directory -ErrorAction Ignore 
New-Item -Path 'F:\DATA\SharedData' -ItemType Directory -ErrorAction Ignore 


}
Function Set-NTFSsecurity{
    
 <# Not Needed anymore. This part   #Lets create Everyone rights to fine and modify CoalMine, Just add to the three folders only the rights to CoalMine
  $FolderPathArray = @('C:\NoobehIT','C:\NoobehIT\ServerSetup') #Ad Everyone to these Folders, so malware can find CoalMine
  Foreach($FolderPath in $FolderPathArray){ 
  $ACL = Get-Acl $FolderPath
  $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
      'Everyone', #Identity
      'Modify', # Rights
      'None',   #inheritance  None=This folder only Containerinherit=The ACE is inherited by child container objects.
      'None',   #propagation  NoPropagateInherit (the ACE is not propagated to any current child objects)
      'Allow')  #type set for everyone modify rights to folder
  $ACL.AddAccessRule($AccessRule)  # Now add the new rule to the temp ACL object, but it is not set back onto the system yet.
  Set-Acl $FolderPath -AclObject $ACL  #set it and forget it.
  #########################################################################################endregion
  }
  
  $FolderPathArray = @('C:\NoobehIT\ServerSetup\CoalMine') #Ad Everyone & subcontains to these Folders, so malware can find CoalMine
  Foreach($FolderPath in $FolderPathArray){ 
  $ACL = Get-Acl $FolderPath
  $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
      'Everyone', #Identity
      'Modify', # Rights
      'ObjectInherit, ContainerInherit',  #inheritance  This folder only - None
      'None',   #propagation  NoPropagateInherit (the ACE is not propagated to any current child objects)
      'Allow')  #type set for everyone modify rights to folder
  $ACL.AddAccessRule($AccessRule)  # Now add the new rule to the temp ACL object, but it is not set back onto the system yet.
  Set-Acl $FolderPath -AclObject $ACL  #set it and forget it.
  #########################################################################################endregion
  }
  #>
 
  ### Lets create security settings for the DATA folder on the F: drive
  ##### Start Creating folder and security for DATA folder on the F: drive (FAST drive)  ###################

  ## Blow out and remove all File INHERITANCE########################
$folder = 'F:\DATA'
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
  ### Finished removing all INHERITANCE ###############
  
  <### Now build up security for Admins and Domain users on DATA folder
  $acl = Get-Acl f:\data
  
  $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("builtin\users","Modify","Allow") ##Changed to Modify
  
  $acl.RemoveAccessRule($AccessRule)
  
  $acl | Set-Acl f:\data
  ###################part 2
  
  $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("builtin\administrators","FullControl","Allow")
  
  
  ###    ADD Administrators to the folder security
  $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
      'builtin\Administrators',
      'FullControl',
      'ContainerInherit, ObjectInherit',
      'None',
      'Allow'
  )
  
  $acl.SetAccessRule($AccessRule)
  
  $acl | Set-Acl f:\data
  
  ## now add security for the domain users
  
  $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
      'cloud\domain users',
      'Modify',
      'ContainerInherit, ObjectInherit',
      'None',
      'Allow'
  )
  
  $acl.SetAccessRule($AccessRule)
  $acl | Set-Acl f:\data
  
  ### END adding security for USERS and Admins #>
  
    
  }
Function Set-GPOsettings{
 ############     GPO     ############

New-ADOrganizationalUnit -Name "CloudUsers" -Description "Client Users"

New-GPO -Name StandardUserSettings -comment "For standard users mainly for background.png and idle disconnection"
New-GPO -Name RemoteDesktop -comment "For Remote Desktop users"


New-GPLink -Name "StandardUserSettings"        -Target "OU=CloudUsers,dc=cloud,dc=local" -LinkEnabled Yes
New-GPLink -Name "RemoteDesktop"  -Target "DC=cloud,DC=local" -LinkEnabled Yes


 ##NOW SET--StandardUserSettings
Set-GPRegistryValue -Name "StandardUserSettings" -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName Wallpaper,WallPaperStyle -Type String -Value "C:\NoobehIT\ServerSetup\Graphics\Backgroundlogo.png",0
Set-GPRegistryValue -Name "StandardUserSettings" -Key "HKCU\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"  -ValueName  MaxIdleTime -Type Dword  -Value 10800000
Set-GPRegistryValue -Name "StandardUserSettings" -Key "HKCU\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"  -ValueName MaxDisconnectionTime -Type Dword  -Value 60000


##NOW SET --RemoteDesktop
Set-GPRegistryValue -Name "RemoteDesktop" -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -ValueName fEnableTimeZoneRedirection  -Type DWord -Value 1
Set-GPRegistryValue -Name "RemoteDesktop" -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -ValueName LicenseServers  -Type String -Value "localhost"
Set-GPRegistryValue -Name "RemoteDesktop" -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -ValueName LicensingMode  -Type DWord -Value 4
Set-GPRegistryValue -Name "RemoteDesktop" -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -ValueName fNoRemoteDesktopWallpaper  -Type DWord -Value 0
##Now set password policy from DEFAULT DOMAIN POLICY
Set-ADDefaultDomainPasswordPolicy -Identity Cloud.local -MinPasswordLength 12 -MinPasswordAge 0 -MaxPasswordAge 0  -PasswordHistoryCount 0
##Now make sure Local Group Policy shows it by a refresh
Invoke-Command {gpupdate /force}

#=====================END GPO=============================================================
}
Function Set-Office365Install{
###############################
#DNS forwarders
$ipss = ("156.154.70.4", "156.154.71.4")
Set-DnsServerForwarder -IPAddress $ipss -PassThru

###############
Write-Output "Installing office365 DOWNLOAD"
Set-Location -Path C:\NoobehIT\ServerSetup\OfficeInstall
$cmd = @"
"Setup.exe /download configuration.xml"
"@
& cmd.exe /c $cmd

Write-Host "Installing office365 CONFIGURATION"
$cmd = @"
"Setup.exe /configure configuration.xml"
"@
& cmd.exe /c $cmd
}
Function Set-SoftwareInstall{
C:\NoobehIT\ServerSetup\MISCsoftware\OneDriveServer\onedrivesetup.exe /allusers /force /silent
#Chocolety  ###############################
Install-PackageProvider -Name NuGet -RequiredVersion 2.8.5.201 -Force


Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))  
choco feature enable -n allowGlobalConfirmation
Choco install GoogleChrome, adobereader, windirstat -y

Choco install Microsoft-edge -y

choco install git.install --params "/GitOnlyOnPath /NoGitLfs /NoShellIntegration /SChannel /NoAutoCrlf" --force -y
 & "C:\Program Files\Git\bin\git.exe" clone https://github.com/CheeseBreadIsGood/AzureVM.git
 Install-Module -Name Az -AllowClobber -Scope CurrentUser -force
}
Function Set-Misc{
#### memory compression
##### Server 2019 Memory Compression/PageCombining

Enable-MMAgent -MemoryCompression
Enable-MMAgent -PageCombining
Enable-MMAgent -ApplicationLaunchPrefetching
## Enabel-MMAgent -ApplicationPreLaunch
get-mmagent

##setup windows search to auto start up
Set-service -name WSearch -StartupType Automatic
start-service -name Wsearch
}
Function Set-ShadowCopy{
####################Start Shadow Copy####

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
   
   #Enable Shadows
    vssadmin add shadowstorage /for=C: /on=C:  /maxsize=8128MB
    vssadmin add shadowstorage /for=F: /on=F:  /maxsize=8128MB

    #Create Shadows
    vssadmin create shadow /for=C:
    vssadmin create shadow /for=F:

    #Set Shadow Copy Scheduled Task for C: AM
    $Action=new-scheduledtaskaction -execute "c:\windows\system32\vssadmin.exe" -Argument "create shadow /for=C:"
    $Trigger=new-scheduledtasktrigger -daily -at 10:30AM
    Register-ScheduledTask -TaskName ShadowCopyC_AM -Trigger $Trigger -Action $Action -Description "ShadowCopyC_AM" -TaskPath "Noobeh"

    #Set Shadow Copy Scheduled Task for C: PM
    $Action=new-scheduledtaskaction -execute "c:\windows\system32\vssadmin.exe" -Argument "create shadow /for=C:"
    $Trigger=new-scheduledtasktrigger -daily -at 2:30PM
    Register-ScheduledTask -TaskName ShadowCopyC_PM -Trigger $Trigger -Action $Action -Description "ShadowCopyC_PM" -TaskPath "Noobeh"
    
        #Set Shadow Copy Scheduled Task for C: PM
    $Action=new-scheduledtaskaction -execute "c:\windows\system32\vssadmin.exe" -Argument "create shadow /for=C:"
    $Trigger=new-scheduledtasktrigger -daily -at 11:30PM
    Register-ScheduledTask -TaskName ShadowCopyC_Late_PM -Trigger $Trigger -Action $Action -Description "ShadowCopyC_Late_PM" -TaskPath "Noobeh"

###
    #Set Shadow Copy Scheduled Task for F: AM
    $Action=new-scheduledtaskaction -execute "c:\windows\system32\vssadmin.exe" -Argument "create shadow /for=F:"
    $Trigger=new-scheduledtasktrigger -daily -at 10:45AM
    Register-ScheduledTask -TaskName ShadowCopyF_AM -Trigger $Trigger -Action $Action -Description "ShadowCopyF_AM" -TaskPath "Noobeh"

    #Set Shadow Copy Scheduled Task for F: PM
    $Action=new-scheduledtaskaction -execute "c:\windows\system32\vssadmin.exe" -Argument "create shadow /for=F:"
    $Trigger=new-scheduledtasktrigger -daily -at 2:45PM
    Register-ScheduledTask -TaskName ShadowCopyF_PM -Trigger $Trigger -Action $Action -Description "ShadowCopyF_PM" -TaskPath "Noobeh"
    
    #Set Shadow Copy Scheduled Task for F: PM
    $Action=new-scheduledtaskaction -execute "c:\windows\system32\vssadmin.exe" -Argument "create shadow /for=F:"
    $Trigger=new-scheduledtasktrigger -daily -at 11:45PM
    Register-ScheduledTask -TaskName ShadowCopyF_Late_PM -Trigger $Trigger -Action $Action -Description "ShadowCopyF_Late_PM" -TaskPath "Noobeh"

### END ShadowCopy configuration ###
}



###  Start ENTRY POINT Main  ### 
#If this is the first run (check log) & it is not a domain/Create log & Create startup task for run again once Then Setup Domain, Then exit out of program
Set-DomainController
Set-CopyNoobehFiles
Set-DATAHarddrive
Set-GPOsettings
Set-NTFSsecurity
Set-Office365Install
Set-SoftwareInstall
Set-Misc
Set-ShadowCopy

#--------------------------------------------------------------end------------------------------------------------



