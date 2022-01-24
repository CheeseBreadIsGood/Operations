Function Confirm-Tasklog{
  param(
    [Parameter (Mandatory = $true)] [String]$LogName
    )
    $IsFileThere = test-path -path "C:\NoobehIT\ServerSetup\MISCsoftware\$logName.log" -PathType Leaf
    If ($IsFileThere) {
      "------LOGFILE->$LogName.log<- is already there. END"
      }
    Return $IsFileThere
  }

 If ( -not (Confirm-Tasklog -LogName hellotest2))
 {
   Write-Host It is not there so, I can run this SCRIPT!
 }
 