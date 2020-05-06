
Write-output "----------------------------------------------"
Write-Output "--------- Users in OU=CloudUsers --------------"
Write-output "----------------------------------------------"
Get-ADUser -Filter {Enabled -eq $true} -SearchBase "OU=CloudUsers,DC=Cloud,DC=local" -Properties LastLogonDate | select samaccountname, Name, LastLogonDate | Sort-Object LastLogonDate

Write-output "----------------------------------------------"
Write-Output "----------- All Enabled users -------------" 
Write-output "----------------------------------------------"
Get-ADUser -Filter {Enabled -eq $true}  -Properties LastLogonDate | select samaccountname, Name | Sort-Object Name, LastLogonDate | Sort-Object LastLogonDate