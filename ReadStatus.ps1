$path = ".\Status\SetupStatus.log"

$pattern1 = "###Phase1 Complete###"
$pattern2 = "###Phase2 Complete###"
$pattern3 = "###Phase3 Complete###"

$found = Select-String -Pattern $pattern1,$pattern2,$pattern3 -Path $path #look for a string in file
# Now search the log file for script phase markers. Only do one phase if it has not be done before
If ($found.Matches.Value -eq '###Phase3 Complete###'){  #start with the last phase first to check. Then it is safe to check earlier phases.
  Write-Output "^^^^^^Fourth script Start^^^^^^ $(get-date)"
} elseif ($found.Matches.Value -eq '###Phase2 Complete###') {
  Write-Output "^^^^^^Third script Start^^^^^^  $(get-date)"
}elseif ($found.Matches.Value -eq '###Phase1 Complete###') {
  Write-Output "^^^^^^Second script Start^^^^^^  $(get-date)" 
}elseif ($found.Matches.Value -ne '###Phase') {
  Write-Output "NOTHING has been done. ^^^^^^First script Start^^^^^^  $(get-date)" 
}       