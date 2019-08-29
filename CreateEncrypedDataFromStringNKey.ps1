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