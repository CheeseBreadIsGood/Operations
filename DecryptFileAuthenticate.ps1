  <#--------------------------------------------------------------------
  .SYNOPSIS
    Used to decrypt stings in an encrypted CSV file of Three strings using a typed in SeedPassword (should be complex)
    Then use them to authenticate to Azure as a Service Principle. 

  .DESCRIPTION
    Used to read a csv file of Three encrypted string. Then decrypted them using a String key password (Should be complex). 
    Items to decrypt are for authenticating to Azure as a service principal. Items are SPusername, IAM Key(Password), and the Azure Tenant ID 

  .PARAMETER Key
     Mandatory. The $SeedPasswordKey will be typed in and turned into bytes for use as a $key to encrypt your $EncryptThisNow string. 
    There is some padding and/or removal of this byte formated string to make it fit the size required for an AES key. 
    You can use 16, 24, or 32 bytes for AES,which is 128,192,or 256 bits respectivly
  .INPUTS
    $SeedPassword - A typed password. This is the same string that you used to encrypt the strings for the file
    Not it is used to decrypt the strings

  .OUTPUTS
    (Nothing) But this will authenicate to Azure as a secruity prinicple

  .NOTES
    Version:        1.0
    Author:         Mike Ryan   
    Creation Date:  09/29/19
    Purpose/Change: Initial function development

  .EXAMPLE
    $SeedPassword = "justApassword987&&"; 
  #>
  $File = ".\EncryptedCredentials.csv" #The file is stored at same location and will be on Github repository
  $LoginLog = '.\Status\LoginLog.log' #The seedPasswordKet is on a local file. Not on github
  if (Test-Path $LoginLog){
    $SeedPasswordKey = Get-Content -Path $LoginLog -Delimiter " "
  } else {
    $SeedPasswordKey = read-host "Seed Key Password" -AsSecureString ##Thie file is missing so get it interactively from user. This will be a typed in secret so as to not keep it inside the code. Needs to be the same password for when these strings where encrpted with.
  }

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
  
  $CredentialItems = Import-Csv $File #get all three items EncryptedPassword,SPname & TenetID into a handy object
  $EncryptedPass = ConvertTo-SecureString $CredentialItems.EncryptedPass -Key $key #decrypt the password. This is the only one that stays as a securestring
  $CredentialItems.SPname = ConvertTo-SecureString $CredentialItems.SPname -Key $key #decrypt the password into a securestring
  $CredentialItems.SPname = [System.Net.NetworkCredential]::new("", $CredentialItems.SPname).Password #back to a normal string (not securestring)
  $CredentialItems.TenantID  = ConvertTo-SecureString $CredentialItems.TenantID -Key $key #decrypt the password into a securestring
  $CredentialItems.TenantID = [System.Net.NetworkCredential]::new("", $CredentialItems.TenantID).Password #back to a normal string (not securestring)

$credentials = New-Object System.Management.Automation.PSCredential($CredentialItems.SPname,$EncryptedPass) #build cretentials for loggin into Azure
Connect-AzAccount -ServicePrincipal -Credential $credentials -Tenant $CredentialItems.TenantID ## log into Azure
#Now test and get some secrets, oh cool

  #-----Just for testing-----
#[System.Net.NetworkCredential]::new("", $EncryptedPass).Password  #This decrypts a secure string
#[System.Net.NetworkCredential]::new("", $SPname).Password #This decrypts a secure string
#[System.Net.NetworkCredential]::new("", $TenantID).Password #This decrypts a secure string
#(Get-AzKeyVaultSecret -vaultName "guessTheNumber" -name "CloudKey1").SecretValueText
