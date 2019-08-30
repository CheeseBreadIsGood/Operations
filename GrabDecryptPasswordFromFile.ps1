#now get from file.
  <#--------------------GrabDecryptPasswordFromFile.ps1
  .SYNOPSIS
    Grab encrypted password, SPname and TenetID from a CSV file

  .DESCRIPTION
    There will be a txt file "C:\Temp\EncryptedCredentials.txt" that has three items
    encrypted password, SPname and TenetID from a CSV file. 
    1. decrypt the password with a user entered $SeedPassword
    2. $credentialItems.SPName -Service Principle name
    3. $credentialItems.TenetID -You Azure TenetID 

    Then you will log into Azure by Service Principle so you can have access to the Azure KeyVault Secrets

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
$SeedPassword = read-host "Seed Key Password" -AsSecureString ##This will be a typed in secret so as to not keep it inside the code
$key =  [Text.Encoding]::UTF8.GetBytes($SeedPassword) #Set the $SeedPassword into array of bytes
  $AESkeySize = 32 # How many bytes do you want? You can use 16, 24, or 32 bytes for AES,which is 128,192,or 256 bits respectivly . Needs to match the same as it was encrypted
  #region # Make the bytes the perfect size of 16, 24 or 32 depending on what $AESkeySize is
  while ($key.Length -lt $AESkeySize ) { # Keep doubleing the size of the key until it is greater then $aeskeysize
  $key = $key + $key
  }
  if ($key.Length -gt $AESkeySize ) { #cut the needed key down to the AESkeySize
  $Key = $Key[0..($AESkeySize -1)] #$key is now the right size to use
  }  
  #endregion

$CredentialItems = Import-Csv $File #get all three items EncryptedPassword,SPname & TenetID
$Securepassword = ConvertTo-SecureString $CredentialItems.EncryptedPass -Key $key #decrypt the password

$credentials = New-Object System.Management.Automation.PSCredential($CredentialItems.SPName,$SecurePassword) #build cretentials for loggin into Azure
Connect-AzAccount -ServicePrincipal -Credential $credentials -Tenant $CredentialItems.TenetID ## log into Azure
#Now test and get some secrets, oh cool
(Get-AzKeyVaultSecret -vaultName "guessTheNumber" -name "AdministratorName").SecretValueText
(Get-AzKeyVaultSecret -vaultName "guessTheNumber" -name "CloudNASKey1").SecretValueText
