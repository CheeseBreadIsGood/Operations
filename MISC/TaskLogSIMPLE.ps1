#---------------------Task Functions---------------------


Function Set-TaskLog{
    ## Create a new log file that you name fully with full path. It will not over write an existing log.
    param(
      [Parameter (Mandatory = $false)] [String]$LogName
      )
      $global:LogPath = $LogName
      New-item $global:LogPath
  }
  Function Confirm-Tasklog{
   # need log file name with extnetion
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
  $global:LogPath = "C:\NoobehIT\ServerSetup\AdminScripts\KillQBScript.log"  #Default & global varable path and filename
  
  
  # examples--
  #Add-EVENT ---------------------StartHere--------------------
  #add-EVENT 'who it works five five five'
  #Add-EVENT "how hello hello STOP ERROR"