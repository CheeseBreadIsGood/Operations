$SourceA = $(Get-ChildItem C:\temp\FolderA -Directory).name
$SourceB = $(Get-ChildItem C:\temp\FolderB -Directory).Name

$SourceA | ForEach-Object {
    if ($SourceB -contains $_) {
        Write-Host "`$SourceB contains the `$SourceA string [$_]"
    }
}


$SourceA = $(Get-ChildItem C:\temp\FolderA -Directory).name
$SourceB = $(Get-ChildItem C:\temp\FolderB -Directory).Name
$sourcea | Where-Object -FilterScript { $_ -in $SourceB}