
Write-output "----------------------------------------------"
Write-Output "--------- Users in OU=CloudUsers --------------"
Write-output "----------------------------------------------"
Get-ADUser -Filter {Enabled -eq $true} -SearchBase "OU=CloudUsers,DC=Cloud,DC=local" -Properties LastLogonDate | Select-Object samaccountname, Name, LastLogonDate | Sort-Object LastLogonDate

Write-output "----------------------------------------------"
Write-Output "----------- All Enabled users -------------" 
Write-output "----------------------------------------------"
Get-ADUser -Filter {Enabled -eq $true}  -Properties LastLogonDate | Select-Object samaccountname, Name | Sort-Object LastLogonDate