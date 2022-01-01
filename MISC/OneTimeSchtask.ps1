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
    #Set 
    $Action=new-scheduledtaskaction -execute Powershell.exe -Argument C:\NoobehIT\ServerSetup\AdminScripts\CreateLogfile.ps1
    $Trigger=new-scheduledtasktrigger -AtStartup
    
    $TaskPrincipal=New-ScheduledTaskPrincipal -User system -RunLevel Highest -LogonType S4U

    Register-ScheduledTask -TaskName RunonceAfterReboot -Trigger $Trigger -Action $Action -Principal $TaskPrincipal -Description "Run after reboot" -TaskPath "Noobeh"


    ### DELETE IT
    Unregister-ScheduledTask -TaskPath "\Noobeh\" -TaskName RunonceAfterReboot -confirm:$false