Function Set-TaskLog{
    param(
      [Parameter (Mandatory = $false)] [String]$LogName
      )
      New-Item "C:\NoobehIT\ServerSetup\MISCsoftware\$logName.log"
  
  }

  Set-TaskLog -logname hellotest