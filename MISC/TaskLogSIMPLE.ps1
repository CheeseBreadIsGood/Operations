#---------------------TaskLog Functions---------------------
# Version 1.0 MRyan
# Date: 070224
# Enable simple log files to a local text file
#---------------------TaskLog Functions---------------------

Function Set-TaskLog{
  ## Create a new log file that you name fully with full path. It will not over write an existing log.
  param(
    [Parameter (Mandatory = $false)] [String]$LogName
    )
    $global:LogPath = $LogName
    New-item $global:LogPath
}

Function Confirm-Tasklog{
 # need log file name with exten4tion
 #returns true if the named log file is there
  param(
    [Parameter (Mandatory = $true)] [String]$LogName
    )
    $IsFileThere = test-path -path $global:LogPath -PathType Leaf
    If ($IsFileThere) {
      Write-Host "------LOGFILE->$LogName.log<- is already there. END"
      }
    Return $IsFileThere
  }

  
function Add-Event {
   param(
    [Parameter (Mandatory = $false)] [String]$Event
    )
     $eventtime = (get-date).ToString("dddd MM/dd/yyyy HH:mm::ss K")
        Add-Content -Path $global:LogPath -Value $($eventtime  + "-->" + $Event)
}
 

  ##--------------------- Global variables--------------------
$global:LogPath = "C:\NoobehIT\ServerSetup\AdminScripts\TestTest.log"  #Default & global varable path and filename. You can change by calling set-logfile
# examples--
#Add-EVENT ---------------------StartHere--------------------
#add-EVENT 'who it works five five five'
#Add-EVENT "how hello hello STOP ERROR"
# STEPS
#  1. Create path & name for log file. You can run this everytime. It will not clobber the file.
#  2. Add-event test to log file auto timestamp 