Write-output "----------------------------------------------"
Write-Output "--------- Users in OU=CloudUsers --------------"
Write-output "----------------------------------------------"
$all = Get-ADUser -Filter {Enabled -eq $true} -SearchBase "OU=CloudUsers,DC=Cloud,DC=local" -Properties LastLogonDate | Select-Object samaccountname, Name, LastLogonDate | Sort-Object LastLogonDate
$all
write-output "Total Users = " + $all.count