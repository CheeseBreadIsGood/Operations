
Get-DiskInformation function – uses throw
Function Get-DiskInformation
{
 Param(
   [string]$drive,
   [string]$computerName = $env:computerName
) #end param
if(-not($drive)) { Throw “You must supply a value for -drive” }
 Get-WmiObject -class Win32_volume -computername $computername -filter “DriveLetter = ‘$drive'”
} #end function Get-DiskInformation