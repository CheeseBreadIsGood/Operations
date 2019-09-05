  <#---------------------------------CreateEncrypedDFile.ps1
  .SYNOPSIS
    Used to create a csv file of encrypted string using a String key password (Should be complex)

  .DESCRIPTION
    Used to create a csv file of Three encrypted string using a String key password (Should be complex). It will be then saved to a CSV file.
    Items to encrypt are for authenticating to Azure as a service principal. Items are SPusername, IAM Key(Password), and the Azure Tenant ID 

  .PARAMETER Key
    Mandatory. The $SeedPasswordKey will be typed in and turned into bytes for use as a $key to encrypt your $EncryptThisNow string. 
    There is some padding or removal of this byte formated string to make it fit the size required for an AES key. 
    You can use 16, 24, or 32 bytes for AES,which is 128,192,or 256 bits respectivly
  .INPUTS
    $SeedPassword - A typed secure password. $EncryptThisNow - is the string that you want to encrypt using $SeedPassword you inputed

  .OUTPUTS
    A CSV file that have all three strings encrypted with the $SeedPasswordKey. 

  .NOTES
    Version:        1.0
    Author:         Mike Ryan   
    Creation Date:  09/29/19
    Purpose/Change: Initial function development

  .EXAMPLE
    $SeedPassword = "justApassword"; $EncryptThisNow = "This is the sting that I want to encrypt witht he $SeedPassword"
  #>
  $File = ".\EncryptedCredentials.csv"
  
  $SeedPasswordKey = read-host "Seed Key Password" -AsSecureString ##This will be a typed in secret so as to not keep it inside the code
  $SecurePass = ConvertTo-SecureString -String (read-host "Paste Your IAMpassword Here:") -AsPlainText -Force ##Paste in your text secret so as to not keep it inside the code
  $SecureSPname = ConvertTo-SecureString -String (read-host "Paste Your SPname Here:") -AsPlainText -Force ##Paste in your text secret so as to not keep it inside the code
  $SecureTenantID = ConvertTo-SecureString -String (read-host "Paste Your TenantID Here:") -AsPlainText -Force ##Paste in your text secret so as to not keep it inside the code

  $key =  [Text.Encoding]::UTF8.GetBytes($SeedPasswordKey) #Set the $SeedPassword into array of bytes
  $AESkeySize = 32 # How many bytes do you want? You can use 16, 24, or 32 bytes for AES,which is 128,192,or 256 bits respectivly 
  #region # Make the bytes the perfect size (by padding or cutting) to 16, 24 or 32 depending on what $AESkeySize is
  while ($key.Length -lt $AESkeySize ) { # Keep doubleing the size of the key until it is greater then $aeskeysize
  $key = $key + $key
  }
  if ($key.Length -gt $AESkeySize ) { #cut the needed key down to the AESkeySize
  $Key = $Key[0..($AESkeySize -1)] #$key is now the right size to use
  }  
  #endregion

  $creObject = [PSCustomObject]@{     #Make a simple object so we can save all the ecrypted items as a csv file
    EncryptedPass = ConvertFrom-SecureString $SecurePass -Key $Key #This is where the magic happens. AES encryptiton using the $Key from the user
    SPname = ConvertFrom-SecureString $SecureSPname -Key $Key #This is where the magic happens. AES encryptiton using the $Key from the user
    TenantID = ConvertFrom-SecureString $SecureTenantID -Key $Key #This is where the magic happens. AES encryptiton using the $Key from the user
  }
Export-Csv -path $File -InputObject $creObject -NoTypeInformation #ave all the ecrypted items as a csv file
  #-----Just for testing-----
# [System.Net.NetworkCredential]::new("", $GetPassword).Password  #This decrypts a secure string
# [System.Net.NetworkCredential]::new("", $Securepassword).Password #This decrypts a secure string
# [System.Net.NetworkCredential]::new("", $Encrypted).Password #This decrypts a secure string
