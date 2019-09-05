$path = ".\Status\SetupStatus.log"


$pattern1 = "###Phase1 Complete###"
$pattern2 = "###Phase2 Complete###"
$pattern3 = "###Phase3 Complete###"


$found = Select-String -Pattern $pattern1,$pattern2,$pattern3 -Path $path #look for a string in file

If ($found.Matches.Value -eq '###Phase3 Complete###'){
  Write-Output "3333 Do the Fourth script" 
} elseif ($found.Matches.Value -eq '###Phase2 Complete###') {
  Write-Output "2222 Do the Third script" 
}elseif ($found.Matches.Value -eq '###Phase1 Complete###') {
  Write-Output "1111 Do the Second script" 
}elseif ($found.Matches.Value -ne '###Phase') {
  Write-Output "NOTHING NOTHING Do the First script" 
}



#$found.Matches.Value -eq '###Phase2 Complete###'
#$found.Matches[1]



# $found = Select-String -Pattern $pattern0 -Path $path #look for a string in file
# if ($null -eq $found){
#   Write-Output "NONE found!!! Do the first script" 
# }
# $found = Select-String -Pattern $pattern1 -Path $path #look for a string in file
# if ($found.Matches.Success){
#   Write-Output "222222222 Do the Second script" 
# }
# $found = Select-String -Pattern $pattern2 -Path $path #look for a string in file
# if ($found.Matches.Success){
#   Write-Output "3333333333Do the Third script" 
# }
# $found = Select-String -Pattern $pattern3 -Path $path #look for a string in file
# if ($found.Matches.Success){
#   Write-Output "4444444444  Do the Fourth script" 
# } elseif (condition) {
  
# }
