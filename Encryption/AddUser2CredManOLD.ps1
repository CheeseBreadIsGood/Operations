#PowerShellv5
Install-Module PowerShellGet -force #-Allow Clobber
#Install elevated
Install-Module Microsoft.PowerShell.SecretManagement, Microsoft.PowerShell.SecretStore -Scope AllUsers

#Can use the SecretStore as a vault
Register-SecretVault -Name SecretStoreNoobeh -ModuleName Microsoft.PowerShell.SecretStore -DefaultVault

# Run a powershell script as administrator
Start-Process powershell "-File myscript.ps1" -Credential (Get-Credential)

# or start some other process as admin
Start-Process -FilePath C:\Windows\System32\notepad.exe -Credential (Get-Credential)