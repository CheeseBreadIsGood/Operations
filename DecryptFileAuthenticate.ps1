  <#--------------------------------------------------------------------
  .SYNOPSIS
    Used to create an encrypted file of an arbitrary string Encrypted from a sting password

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
  $File = ".\EncryptedCredentials.txt"
  
  $SeedPasswordKey = read-host "Seed Key Password" -AsSecureString ##This will be a typed in secret so as to not keep it inside the code

  $key =  [Text.Encoding]::UTF8.GetBytes($SeedPasswordKey) #Set the $SeedPassword into array of bytes
  $AESkeySize = 32 # How many bytes do you want? You can use 16, 24, or 32 bytes for AES,which is 128,192,or 256 bits respectivly 
  #region # Make the bytes the perfect size of 16, 24 or 32 depending on what $AESkeySize is
  while ($key.Length -lt $AESkeySize ) { # Keep doubleing the size of the key until it is greater then $aeskeysize
  $key = $key + $key
  }
  if ($key.Length -gt $AESkeySize ) { #cut the needed key down to the AESkeySize
  $Key = $Key[0..($AESkeySize -1)] #$key is now the right size to use
  }  
  #endregion
  
  $CredentialItems = Import-Csv $File #get all three items EncryptedPassword,SPname & TenetID
  $EncryptedPass = ConvertTo-SecureString $CredentialItems.EncryptedPass -Key $key #decrypt the password
  $CredentialItems.SPname = ConvertTo-SecureString $CredentialItems.SPname -Key $key #decrypt the password
  $CredentialItems.SPname = [System.Net.NetworkCredential]::new("", $CredentialItems.SPname).Password #back to a normal string (not secure)
  $CredentialItems.TenantID  = ConvertTo-SecureString $CredentialItems.TenantID -Key $key #decrypt the password
  $CredentialItems.TenantID = [System.Net.NetworkCredential]::new("", $CredentialItems.TenantID).Password #back to a normal string (not secure)

$credentials = New-Object System.Management.Automation.PSCredential($CredentialItems.SPname,$EncryptedPass) #build cretentials for loggin into Azure
Connect-AzAccount -ServicePrincipal -Credential $credentials -Tenant $CredentialItems.TenantID ## log into Azure
#Now test and get some secrets, oh cool

  #-----Just for testing-----
#[System.Net.NetworkCredential]::new("", $EncryptedPass).Password  #This decrypts a secure string
#[System.Net.NetworkCredential]::new("", $SPname).Password #This decrypts a secure string
#[System.Net.NetworkCredential]::new("", $TenantID).Password #This decrypts a secure string
#(Get-AzKeyVaultSecret -vaultName "guessTheNumber" -name "CloudKey1").SecretValueText
