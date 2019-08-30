#now get from file.
  <#--------------------CreateEncrypedDataFromStringNKey.ps1
  .SYNOPSIS
    Used to create an encrypted file of an arbitrary string and a password

  .DESCRIPTION
    This function is used to create an encrytped string $EncryptThisNow using a secret password $SeedPassword. It will be then saved to a file

  .PARAMETER Key
    Mandatory. The $SeedPassword will be taken and turned into bytes for use as a $key to encrypt your $EncryptThisNow string. 
  .INPUTS
    $SeedPassword - A typed password. $EncryptThisNow - is the string that you want to encrypt using $SeedPassword you inputed

  .OUTPUTS
    $Encrypted - Your fully encrypted string that was encrypted with your $SeedPassword key.

  .NOTES
    Version:        1.0
    Author:         Mike Ryan   
    Creation Date:  09/29/19
    Purpose/Change: Initial function development

  .EXAMPLE
    $SeedPassword = "justApassword"; $EncryptThisNow = "This is the sting that I want to encrypt witht he $SeedPassword"
  #>
$File = "C:\Temp\EncryptedCredentials.txt"

$CredentialItems = Import-Csv $File
$Securepassword = ConvertTo-SecureString $CredentialItems.EncryptedPass -Key $key

$credentials = New-Object System.Management.Automation.PSCredential($CredentialItems.SPName,$SecurePassword)
Connect-AzAccount -ServicePrincipal -Credential $credentials -Tenant $CredentialItems.TenetID ## log into Azure

(Get-AzKeyVaultSecret -vaultName "guessTheNumber" -name "AdministratorName").SecretValueText
(Get-AzKeyVaultSecret -vaultName "guessTheNumber" -name "CloudNASKey1").SecretValueText
