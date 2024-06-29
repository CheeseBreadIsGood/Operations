#---------------------Task Functions---------------------
Function Set-TaskLog{
    ## Create a new log file that you name. It will not over write an existing log. Nice
    param(
      [Parameter (Mandatory = $false)] [String]$LogName
      )
      New-item $global:LogPath
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
  
    
  function Add-taskLog {
     param(
      [Parameter (Mandatory = $false)] [String]$Event
      )
       $eventtime = (get-date).ToString("dddd MM/dd/yyyy HH:mm::ss K")
          Add-Content -Path $global:LogPath -Value $($eventtime  + "-->" + $Event)
  }
   
    ##--------------------- Global variables--------------------
  $global:LogPath = "C:\NoobehIT\ServerSetup\MISCsoftware\GeneralYes.log"  #global varable path and filename
  
  # examples--
  #Add-tasklog ---------------------StartHere--------------------
  #add-tasklog 'who it works'
  #Add-taskLog "how cis ERROR"