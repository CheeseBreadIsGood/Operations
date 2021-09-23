$Folder = 
$agedays = 45
If ($Folder -match 'C:')
{
    Write-Warning -Message "You are making a distructive action on the $Folder. Are you sure you want to do this?"

<#
    #Delete files older than 6 months
    Get-ChildItem $Folder -Recurse -Force -ea 0 |
    ? {!$_.PsIsContainer -and $_.LastWriteTime -lt (Get-Date).AddDays(-($agedays)))} |
    ForEach-Object {
       $_ | del -Force
       $_.FullName | Out-File C:\log\deletedlog.txt -Append
    }
#>
}
Else
{
    "Working on deleting the folder tree $Folder"
<#
    #Delete empty folders and subfolders
    Get-ChildItem $Folder -Recurse -Force -ea 0 |
    ? {$_.PsIsContainer -eq $True} |
    ? {$_.getfiles().count -eq 0} |
    ForEach-Object {
        $_ | del -Force
        $_.FullName | Out-File C:\log\deletedlog.txt -Append
    }
#>
}


Get-ChildItem C:\Temp\Test\ | Remove-Item -Force -Recurse -Verbose

$getallfolders = Get-ChildItem C:\temp\test

$getallfolders 
$getallfolders[0].LastWriteTime


Get-ChildItem C:\Temp\Test\ | Where-Object LastWriteTime -lt ((Get-Date).adddays(-30)) | Remove-Item -force