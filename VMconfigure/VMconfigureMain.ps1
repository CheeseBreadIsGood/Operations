####################--PowerShell Configure New Server with external hard drive ###########

<# TTT        VMconfigureMain.ps1      TTT
  .SYNOPSIS
    Used to create a new server setup with all the default settings that noobeh requires
  .DESCRIPTION
    This will install some software configure external hard drive and create a default domain controller 
  
  .NOTES
    Version:        1.2.220120
    Author:         Mike Ryan   
    Creation Date:  05/1/20
    Purpose/Change: Many years of converting manual work into this script. Goal is to "Set it and forget it" fuctionality
#>
function Set-RebootRunSched { #---------------------------------------------------------------------
  Function New-scheduledTaskFolder # lot of work just to create a folder for sched
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
   New-ScheduledTaskFolder Noobeh #call the function to create subfolder Noobeh in tasks
   #Set 
   $Action=new-scheduledtaskaction -execute Powershell.exe -Argument C:\NoobehIT\ServerSetup\AdminScripts\VMconfigureMain.ps1
   $Trigger=new-scheduledtasktrigger -AtStartup
   
   $TaskPrincipal=New-ScheduledTaskPrincipal -User system -RunLevel Highest -LogonType S4U

   Register-ScheduledTask -TaskName RunonceAfterReboot -Trigger $Trigger -Action $Action -Principal $TaskPrincipal -Description "Run after reboot" -TaskPath "Noobeh"


}
function Disable-InternetExplorerESC {   #---------------------------------------------------------------------
  # This needs to be turn off so you can sign into Azure
    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
    $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0 -Force
    Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0 -Force
    Rundll32 iesetup.dll, IEHardenLMSettings
    Rundll32 iesetup.dll, IEHardenUser
    Rundll32 iesetup.dll, IEHardenAdmin
    Write-Host "IE Enhanced Security Configuration (ESC) has been disabled."
 }
 
 Function Set-PowerShellUp{ #---------------------------------------------------------------------

    #Just a few prerequisite for logging into Azure.
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted # register PowerShell Gallery as a trusted repository
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    # setup PowerShell Gallery to use TLS 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    #Install-PackageProvider -Name NuGet -Force #-RequiredVersion 2.8.5.201 
    Install-PackageProvider -Name NuGet -Force
    Install-Module -Name PowerShellGet -AllowClobber -Force
    Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force   
}
Function Set-DomainController{  ######-------------- Set server as Domain Controller -------------#########
if ((gwmi win32_computersystem).partofdomain -eq $False) {  # Only run if this is not a domain controller yet
### Add-WindowsFeature RDS-RD-Server, RDS-Connection-Broker, RDS-Web-Access
$PS =  ConvertTo-SecureString -string 'ThisIsVeryLong123^^' -AsPlainText -Force
##import-module servermanager
Install-WindowsFeature -name AD-domain-Services -IncludeManagementTools
Install-ADDSForest -DomainName Cloud.local -InstallDNS -SafeModeAdministratorPassword $PS -force

#Set time zone et
Set-TimeZone "Eastern Standard Time"
##Add-WindowsFeature RDS-RD-Server, RDS-Connection-Broker, RDS-Web-Access
}
}

Function Set-CopyNoobehFiles{ #---------------------------------------------------------------------
    Connect-AzAccount  #log into azure so you can get access to secret keys
    $NASkey = Get-AzKeyVaultSecret -VaultName "guessthenumber" -Name "Cloudnaskey1" -AsPlainText ## get nas key
    
 $runCommand =    "net use \\noobehnas.file.core.windows.net\cloudnas /u:AZURE\noobehnas $($NASkey)"  #build command

    #Open the NoobehNAS
  Invoke-Expression $runCommand   #run command
### net use \\noobehnas.file.core.windows.net\cloudnas /u:AZURE\noobehnas **************Thisisthekeyforittocopythefiles**********
#Copy important files over to the new server
New-Item -ErrorAction Ignore -ItemType directory -Path c:\NoobehIT
Copy-Item \\noobehnas.file.core.windows.net\cloudnas\ServerSetup\ c:\noobehIT -Recurse -Force
Copy-Item C:\NoobehIT\ServerSetup\Bginfo\BginfoSetting* "C:\Users\ServerAdmin\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
Copy-Item "C:\NoobehIT\ServerSetup\Graphics\Log Off Noobeh.lnk" "C:\Users\Public\Desktop\"
net use /delete \\noobehnas.file.core.windows.net\cloudnas
}
Function Set-DATAHarddrive{ #---------------------------------------------------------------------
    ## Format attached new Drive to Letter F:
#Bring data disks online and initialize them
#################### PowerShell Configure New Server with external hard drive ###########

Get-Disk | Where-Object PartitionStyle –Eq "RAW"| Initialize-Disk -PartitionStyle GPT   
Get-Disk -Number 2 | New-Partition -UseMaximumSize -DriveLetter F | Format-Volume -FileSystem NTFS -NewFileSystemLabel "DATA" -Confirm:$False      
#########################################################################################
###Now create the sub folders to this seconddary hard drive
New-Item -Path 'F:\DATA\AppsData' -ItemType Directory  -ErrorAction Ignore 
New-Item -Path 'F:\DATA\AppsData\Qbooks' -ItemType Directory  -ErrorAction Ignore 
New-Item -Path 'F:\DATA\AppsInstallers' -ItemType Directory -ErrorAction Ignore 
New-Item -Path 'F:\DATA\SharedData' -ItemType Directory -ErrorAction Ignore 
}
Function Set-NTFSsecurity{ #---------------------------------------------------------------------
 
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
Function Set-GPOsettings{ #---------------------------------------------------------------------
 ############     GPO     ############

New-ADOrganizationalUnit -Name "CloudUsers" -Description "Client Users"

New-GPO -Name StandardUserSettings -comment "For standard users mainly for background.png and idle disconnection"
New-GPO -Name RemoteDesktop -comment "For Remote Desktop users"


New-GPLink -Name "StandardUserSettings"        -Target "OU=CloudUsers,dc=cloud,dc=local" -LinkEnabled Yes
New-GPLink -Name "RemoteDesktop"  -Target "DC=cloud,DC=local" -LinkEnabled Yes


 ##NOW SET--StandardUserSettings
Set-GPRegistryValue -Name "StandardUserSettings" -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName Wallpaper,WallPaperStyle -Type String -Value "C:\NoobehIT\ServerSetup\Graphics\Backgroundlogo.png",0
Set-GPRegistryValue -Name "StandardUserSettings" -Key "HKCU\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"  -ValueName  MaxIdleTime -Type Dword  -Value 10800000
Set-GPRegistryValue -Name "StandardUserSettings" -Key "HKCU\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"  -ValueName MaxDisconnectionTime -Type Dword  -Value 300000


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
## DELETE_ME Install-PackageProvider -Name NuGet -Force #-RequiredVersion 2.8.5.201 
#PowerShellv5
#Install-Module PowerShellGet -Allow Clobber

Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))  
choco feature enable -n allowGlobalConfirmation
Choco install GoogleChrome, adobereader, windirstat -y

## DELETE_ME Choco install Microsoft-edge -y

choco install git.install --params "/GitOnlyOnPath /NoGitLfs /NoShellIntegration /SChannel /NoAutoCrlf" --force -y
 & "C:\Program Files\Git\bin\git.exe" clone https://github.com/CheeseBreadIsGood/AzureVM.git ##THIS LINE DOES NOT WORK
 ##Install-Module -Name Az -AllowClobber -Scope CurrentUser -force
}

Function Set-ShadowCopy{ #---------------------------------------------------------------------
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
New-ScheduledTaskFolder Noobeh  #create folder if not already there
   
   #Enable Shadows
    vssadmin add shadowstorage /for=C: /on=C:  /maxsize=8128MB
    vssadmin add shadowstorage /for=F: /on=F:  /maxsize=8128MB

    #Create Shadows
    vssadmin create shadow /for=C:
    vssadmin create shadow /for=F:
    #make sure they all run as SYSTEM and not ServerAdmin
    $TaskPrincipal=New-ScheduledTaskPrincipal -User system -RunLevel Highest -LogonType S4U

    #Set Shadow Copy Scheduled Task for C: AM
    $Action=new-scheduledtaskaction -execute "c:\windows\system32\vssadmin.exe" -Argument "create shadow /for=C:"
    $Trigger=new-scheduledtasktrigger -daily -at 10:30AM

    Register-ScheduledTask -TaskName ShadowCopyC_AM -Trigger $Trigger -Action $Action -Principal $TaskPrincipal -Description "ShadowCopyC_AM" -TaskPath "Noobeh"

    #Set Shadow Copy Scheduled Task for C: PM
    $Action=new-scheduledtaskaction -execute "c:\windows\system32\vssadmin.exe" -Argument "create shadow /for=C:"
    $Trigger=new-scheduledtasktrigger -daily -at 2:30PM
    Register-ScheduledTask -TaskName ShadowCopyC_PM -Trigger $Trigger -Action $Action -Principal $TaskPrincipal -Description "ShadowCopyC_PM" -TaskPath "Noobeh"
    
        #Set Shadow Copy Scheduled Task for C: PM
    $Action=new-scheduledtaskaction -execute "c:\windows\system32\vssadmin.exe" -Argument "create shadow /for=C:"
    $Trigger=new-scheduledtasktrigger -daily -at 5:30PM
    Register-ScheduledTask -TaskName ShadowCopyC_Late_PM -Trigger $Trigger -Action $Action -Principal $TaskPrincipal -Description "ShadowCopyC_Late_PM" -TaskPath "Noobeh"

###
    #Set Shadow Copy Scheduled Task for F: AM
    $Action=new-scheduledtaskaction -execute "c:\windows\system32\vssadmin.exe" -Argument "create shadow /for=F:"
    $Trigger=new-scheduledtasktrigger -daily -at 10:45AM
    Register-ScheduledTask -TaskName ShadowCopyF_AM -Trigger $Trigger -Action $Action -Principal $TaskPrincipal -Description "ShadowCopyF_AM" -TaskPath "Noobeh"

    #Set Shadow Copy Scheduled Task for F: PM
    $Action=new-scheduledtaskaction -execute "c:\windows\system32\vssadmin.exe" -Argument "create shadow /for=F:"
    $Trigger=new-scheduledtasktrigger -daily -at 2:45PM
    Register-ScheduledTask -TaskName ShadowCopyF_PM -Trigger $Trigger -Action $Action -Principal $TaskPrincipal -Description "ShadowCopyF_PM" -TaskPath "Noobeh"
    
    #Set Shadow Copy Scheduled Task for F: PM
    $Action=new-scheduledtaskaction -execute "c:\windows\system32\vssadmin.exe" -Argument "create shadow /for=F:"
    $Trigger=new-scheduledtasktrigger -daily -at 5:45PM
    Register-ScheduledTask -TaskName ShadowCopyF_Late_PM -Trigger $Trigger -Action $Action -Principal $TaskPrincipal -Description "ShadowCopyF_Late_PM" -TaskPath "Noobeh"

### END ShadowCopy configuration ###
}
Function Set-Misc{ #---------------------------------------------------------------------

  #DNS forwarders
$ipss = ("8.8.8.8", "8.8.4.4")
Set-DnsServerForwarder -IPAddress $ipss -PassThru
$ipss = ("2001:4860:4860::8888", "2001:4860:4860::8844")
Set-DnsServerForwarder -IPAddress $ipss -PassThru
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
Set-service -name Audiosrv -StartupType Automatic
start-service -name Audiosrv
# Remote Chrome shortcut on default desktop
##remove chrome shortcut from default desktop
Remove-Item "C:\Users\Public\Desktop\Google Chrome.lnk" 


## create a shortcut onto default desktop for Edge
$SourceFilePath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
$ShortcutPath = "C:\Users\Public\Desktop\BrowserEdge.lnk"
$WScriptObj = New-Object -ComObject ("WScript.Shell")
$shortcut = $WscriptObj.CreateShortcut($ShortcutPath)
$shortcut.TargetPath = $SourceFilePath
$shortcut.Save()

}
Function Set-TaskLog{
  param(
    [Parameter (Mandatory = $false)] [String]$LogName
    )
    New-Item "C:\NoobehIT\ServerSetup\MISCsoftware\$logName.log"

}
Function Confirm-Tasklog{
 #returns true if the named log file is there
  param(
    [Parameter (Mandatory = $true)] [String]$LogName
    )
    $IsFileThere = test-path -path "C:\NoobehIT\ServerSetup\MISCsoftware\$logName.log" -PathType Leaf
    If ($IsFileThere) {
      Write-Host "------LOGFILE->$LogName.log<- is already there. END"
      }
    Return $IsFileThere
  }
Function Set-PreDomainWork{  #---------------------------------------------------------------------
 # Discription:
  #do this prework that is needed before the full script, Also make it a Doamin Controller then reboot for the second part of the script
  #If this is the first run (check log) & it is not a domain/Create log & Create startup task for run again once Then Setup Domain, Then exit out of program
  If ( -not (Confirm-Tasklog -LogName Prelog))
                        {  #Now run the many parts
                         Disable-InternetExplorerESC
                         Set-PowerShellUp
                         Set-CopyNoobehFiles  #Have admin log in and start copying IT files to C: drive
                         Set-DATAHarddrive #setup attached F: drive                      
                         #Set-RebootRunSched  #after first run set it to run once after reboot
                         Set-TaskLog -LogName PreLog #make sure these functions don't run again
                         Set-DomainController  ##now make domain controller  and reboot
                        }
} #End Function Set-PreWork
Function Set-PostDomainWork{  #---------------------------------------------------------------------
  #do this after the domain controller is created and rebooted.
If ( -not (Confirm-Tasklog -LogName PostLog))
   {
   
   Set-GPOsettings
   Set-Misc
   Set-NTFSsecurity
   Set-SoftwareInstall
   Set-ShadowCopy 
   Unregister-ScheduledTask -TaskName "RunonceAfterReboot" -Confirm:$false #don't let it run again
   Set-TaskLog -LogName PostLog
   Set-Office365Install ## 64-bit Office
   }
  }  #end function Set-PostWork
##################################
###  Start ENTRY POINT Main  ### 
##################################
    Set-PreDomainWork 
    Set-PostDomainWork
##### end #####

##Import-Module RemoteDesktop
##Set-RDSessionCollectionConfiguration -CollectionName QuickSessionCollection -CustomRdpProperty "gatewayhostname:s:remote.domainname.com:4441"

