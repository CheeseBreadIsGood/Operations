  ##find root folder names that are already in destination then rename orginal so it does not clobber destination
$PathA = "C:\temp\FolderA"
$PathB = "C:\temp\FolderB"
$SourceA = $(Get-ChildItem $PathA -Directory).name
$SourceB = $(Get-ChildItem $PathB -Directory).Name
$SameSource = $sourceA | Where-Object -FilterScript { $_ -in $SourceB}

#Now rename orginal with date on end

$samesource | ForEach-Object {
Rename-Item -Path $($PathA + "\" + $_) -NewName $($_ + "_TimeStamp" + $(get-date -Format "yyyy_dd_MM"))

}