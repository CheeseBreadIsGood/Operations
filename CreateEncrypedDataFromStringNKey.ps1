 <#--------------------CreateEncrypedDataFromStringNKey.ps1
  .SYNOPSIS
    Used to create an encrypted file of an arbitrary string and a password

  .DESCRIPTION
    This function is used to create an encrytped string  \ decryption key that will be used in conjunction with PowerShell cmdlets and functions to encrypt and decrypt data.
    The key needs to be between 16 and 32 characters in length.

  .PARAMETER Key
    Mandatory. The key as a string that the user wants to use to encrypt \ decrypt data

  .INPUTS
    None - other than parameter above

  .OUTPUTS
    Valid Byte Key to be used to encrypt \ decrypt data

  .NOTES
    Version:        1.0
    Author:         Luca Sturlese
    Creation Date:  14/02/13
    Purpose/Change: Initial function development

    Version:        1.1
    Author:         Luca Sturlese
    Creation Date:  13/03/13
    Purpose/Change: Added sleep of few seconds between major commands to improve script success
    
  .EXAMPLE
    $EncryptKey = Set-EncryptKey -Key "PNBX2JIRV7VARUFVZ48O7GTW3HVZ48J5"
  #>

  $SeedPassword = read-host "Seed Key Password" -AsSecureString ##This will be a typed in secret so as to not keep it inside the code
  $EncryptThisNow = read-host "Paste Your Secret Here:" -AsSecureString ##Paste in your text secret so as to not keep it inside the code
  
  $key =  [Text.Encoding]::UTF8.GetBytes($SeedPassword) 
  $AESkeySize = 32   # You can use 16, 24, or 32 bytes for AES,which is 128,192,or 256 bits respectivly 
  
  while ($key.Length -lt $AESkeySize ) { # Keep doubleing the size of the key until it is greater then $aeskeysize
  $key = $key + $key
  }
  
  if ($key.Length -gt $AESkeySize ) { #cut the larger then needed key down to the AESkeySize
  $Key = $Key[0..($AESkeySize -1)]
  }  #$key is now the right size to use
  
  $key[0].GetType()
  $key.Length
  
  $Encrypted = ConvertFrom-SecureString $EncryptThisNow -Key $Key 
  
  Out-File -InputObject $Encrypted -FilePath "C:\temp\EncryptedPassword.txt"