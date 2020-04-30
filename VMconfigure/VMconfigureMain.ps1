####################--PowerShell Configure New Server with external hard drive ###########

<#---------------------------------CreateEncrypedDFile.ps1
  .SYNOPSIS
    Used to create a csv file of encrypted string using a String key password (Should be complex)

  .DESCRIPTION
    Used to create a csv file of Three encrypted string using a String key password (Should be complex). It will be then saved to a CSV file.
    Items to encrypt are for authenticating to Azure as a service principal. Items are SPusername, IAM Key(Password), and the Azure Tenant ID 

  .PARAMETER Key
    Mandatory. The $SeedPasswordKey will be typed in and turned into bytes for use as a $key to encrypt your $EncryptThisNow string. 
    There is some padding or removal of this byte formated string to make it fit the size required for an AES key. 
    You can use 16, 24, or 32 bytes for AES,which is 128,192,or 256 bits respectivly
  .INPUTS
    $SeedPassword - A typed secure password. $EncryptThisNow - is the string that you want to encrypt using $SeedPassword you inputed

  .OUTPUTS
    A CSV file that have all three strings encrypted with the $SeedPasswordKey. 

  .NOTES
    Version:        1.0
    Author:         Mike Ryan   
    Creation Date:  09/29/19
    Purpose/Change: Initial function development

  .EXAMPLE
    $SeedPassword = "justApassword"; $EncryptThisNow = "This is the sting that I want to encrypt witht he $SeedPassword"
  #>
 
### Set server as Domain Controller
$PS =  ConvertTo-SecureString -string 'ThisIsVeryLong123^^' -AsPlainText -Force
Install-WindowsFeature -name AD-domain-Services -IncludeManagementTools
Install-ADDSForest -DomainName Cloud.local -InstallDNS -SafeModeAdministratorPassword $PS -force

#Set time zone et
Set-TimeZone "Eastern Standard Time"

### Add-WindowsFeature RDS-RD-Server, RDS-Connection-Broker, RDS-Web-Access
### Restart-computer -force


####################--PowerShell Configure New Server with external hard drive ###########
 
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

import-module RemoteDesktop
New-RDSessionDeployment -ConnectionBroker "Server.Cloud.local" -WebAccessServer  "Server.Cloud.local" -SessionHost  "Server.Cloud.local"
New-rdSessionDeployment -ConnectionBroker server.cloud.local -SessionHost server.cloud.local
Add-RDServer -Server "Server.Cloud.local" -Role "RDS-WEB-ACCESS" -ConnectionBroker "Server.Cloud.local"
Add-RDServer -Server "Server.Cloud.local" -Role "RDS-GATEWAY" -ConnectionBroker "Server.Cloud.local" -GatewayExternalFqdn "MISYS.Noobeh.net"
Add-RDServer -Server "Server.Cloud.local" -Role "RDS-LICENSING" -ConnectionBroker "Server.Cloud.local" 

#let users remote desktop into server
Add-ADGroupMember -identity "Remote Desktop Users" -Members "Domain Users"


## Format attached new Drive to Letter F:
#Bring data disks online and initialize them
Get-Disk | Where-Object PartitionStyle –Eq "RAW"| Initialize-Disk -PartitionStyle GPT   
Get-Disk -Number 2 | New-Partition -UseMaximumSize -DriveLetter F | Format-Volume -FileSystem NTFS -NewFileSystemLabel "DATA" -Confirm:$False      
#########################################################################################
##### Start Creating folder and security for DATA folder on the F: drive (FAST drive)  ###################
New-Item -Path 'F:\DATA\' -ItemType Directory
## Blow out and remove all File INHERITANCE########################
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    'ServerAdmin',
    'FullControl',
    'ObjectInherit, ContainerInherit',
    'None',
    'Allow'
)

$FolderPath = "F:\DATA"
##New-Item -ItemType directory -Path $FolderPath
$acl = Get-Acl $FolderPath
$acl.SetAccessRuleProtection($True, $False)
$acl.Access | % { $acl.RemoveAccessRule($_) } # I remove all security


# Not needed:
# $acl.SetOwner([System.Security.Principal.NTAccount] $env:USERNAME) # I set the current user as owner
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule('ServerAdmin', 'FullControl', 'Allow') # I set my admin account as also having access
$acl.AddAccessRule($rule)
(Get-Item $FolderPath).SetAccessControl($acl)  ## removes all users in the ACL. BLOWS them away!
### Finished removing all INHERITANCE ###############

### Now build up security for Admins and Domain users on DATA folder
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
### END adding security for USERS and Admins

###Now finished creating the sub folders
New-Item -Path 'F:\DATA\AppsData' -ItemType Directory  -ErrorAction Ignore 
New-Item -Path 'F:\DATA\AppsData\Qbooks' -ItemType Directory  -ErrorAction Ignore 
New-Item -Path 'F:\DATA\AppsInstallers' -ItemType Directory -ErrorAction Ignore 
New-Item -Path 'F:\DATA\SharedData' -ItemType Directory -ErrorAction Ignore 
### Finish adding data folder on the F: drive with users security.

#Open the NoobehNAS
net use \\noobehnas.file.core.windows.net\cloudnas /u:AZURE\noobehnas **************Thisisthekeyforittocopythefiles**********

##NOTE PLEASE CREATE NEW SECRUITY FOR EVERYONE. SO MALWARE CAN GET TO CANARY

#Copy important files over to the new server
New-Item -ErrorAction Ignore -ItemType directory -Path c:\NoobehIT




Copy-Item \\noobehnas.file.core.windows.net\cloudnas\ServerSetup\ c:\noobehIT -Recurse -Force
Copy-Item C:\NoobehIT\ServerSetup\Bginfo\BginfoSetting* "C:\Users\ServerAdmin\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"

Copy-Item "C:\NoobehIT\ServerSetup\Graphics\Log Off Noobeh.lnk" "C:\Users\Public\Desktop\"

##   Create CoalMine with less security for malware to find.  #####
New-Item -ErrorAction Ignore -ItemType directory -Path c:\NoobehIT\CoalMine


New-Item -ErrorAction Ignore -ItemType directory -Path c:\NoobehIT\CoalMine
## Blow out and remove all File INHERITANCE########################

$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    'ServerAdmin',  #user
    'FullControl',     #FileSystemRights
    'ObjectInherit, ContainerInherit',   #InheritanceFlage
    'None',
    'Allow'
)

$FolderPath = "c:\NoobehIT\CoalMine"
##New-Item -ItemType directory -Path $FolderPath
$acl = Get-Acl $FolderPath
$acl.SetAccessRuleProtection($True, $False)
$acl.Access | % { $acl.RemoveAccessRule($_) } # I remove all security


# Not needed:
# $acl.SetOwner([System.Security.Principal.NTAccount] $env:USERNAME) # I set the current user as owner
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule('ServerAdmin', 'FullControl', 'Allow') # I set my admin account as also having access
$acl.AddAccessRule($rule)
(Get-Item $FolderPath).SetAccessControl($acl)  ## removes all users in the ACL. BLOWS them away!
### Finished removing all INHERITANCE ###############

### Now build up security for Admins and Domain users on DATA folder
$acl = Get-Acl $FolderPath

$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("builtin\users","Modify","Allow") # changed to Modify

$acl.RemoveAccessRule($AccessRule)

$acl | Set-Acl $FolderPath
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

$acl | Set-Acl $FolderPath

## now add security for the everyone users

$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    'Everyone',
    'Modify',
    'ContainerInherit, ObjectInherit',
    'None',
    'Allow'
)

$acl.SetAccessRule($AccessRule)
$acl | Set-Acl $FolderPath
### END adding security for USERS and Admins
###Move canary to this coalmine
Copy-item -Path C:\NoobehIT\ServerSetup\CoalMine\* -Destination C:\NoobehIT\CoalMine
## clean up & Delete orginal coalmine inside the serversetup folder
Remove-Item C:\NoobehIT\ServerSetup\CoalMine -recurse  -Force
##### END creating and moving CoalMine items ##################################
###############################################


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

#Chocolety  ###############################
Install-PackageProvider -Name NuGet -RequiredVersion 2.8.5.201 -Force


Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))  
Choco install GoogleChrome, adobereader, windirstat -y

Choco install Microsoft-edge -y

choco install git.install --params "/GitOnlyOnPath /NoGitLfs /NoShellIntegration /SChannel /NoAutoCrlf" --force -y
 & "C:\Program Files\Git\bin\git.exe" clone https://github.com/CheeseBreadIsGood/AzureVM.git
 Install-Module -Name Az -AllowClobber -Scope CurrentUser -force

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
   

###  Start ENTRY POINT Main  ###  

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

    #Set Shadow Copy Scheduled Task for F: AM
    $Action=new-scheduledtaskaction -execute "c:\windows\system32\vssadmin.exe" -Argument "create shadow /for=F:"
    $Trigger=new-scheduledtasktrigger -daily -at 10:45AM
    Register-ScheduledTask -TaskName ShadowCopyF_AM -Trigger $Trigger -Action $Action -Description "ShadowCopyD_AM" -TaskPath "Noobeh"

    #Set Shadow Copy Scheduled Task for F: PM
    $Action=new-scheduledtaskaction -execute "c:\windows\system32\vssadmin.exe" -Argument "create shadow /for=F:"
    $Trigger=new-scheduledtasktrigger -daily -at 2:45PM
    Register-ScheduledTask -TaskName ShadowCopyF_PM -Trigger $Trigger -Action $Action -Description "ShadowCopyD_PM" -TaskPath "Noobeh"

### END ShadowCopy configuration ###


net use /delete \\noobehnas.file.core.windows.net\cloudnas
#--------------------------------------------------------------end------------------------------------------------



