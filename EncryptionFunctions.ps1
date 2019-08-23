Function Set-EncryptKey{
  <#
  .SYNOPSIS
    Used to create an encryption \ decryption key

  .DESCRIPTION
    This function is used to create an encrytpion \ decryption key that will be used in conjunction with PowerShell cmdlets and functions to encrypt and decrypt data.
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
    
  [CmdletBinding()]
  
  Param ([Parameter(Mandatory=$true)][string]$Key)
  
  Begin{}

  Process{
    $iLength = $Key.Length
    $iPad = 32 - $iLength

    If(($iLength -lt 16) -Or ($iLength -gt 32)){
      Throw "Key must be between 16 and 32 characters in length"
    }
  
    Start-Sleep -Seconds 1
  
    $oEncoding = New-Object System.Text.ASCIIEncoding
    $oBytes = $oEncoding.GetBytes($Key + "0" * $iPad)
  
    Return $oBytes
  }
  
  End{}
}

Function Encrypt-Data{
  <#
  .SYNOPSIS
    Used to encrypt data using a specified key

  .DESCRIPTION
    This function is used to encryt data using the specified key. The data can then be stored or used accordingly in the calling script.

    Note: This script requires that the key used be converted to a 16, 24 or 32 byte key. To do this, use the Set-EncryptKey function above.
  
  .PARAMETER String
    Non-Mandatory. A plain-text string that you want to encrypt. Must pass either String or SecureString.

  .PARAMETER SecureString
    Non-Mandatory. A secure-string that you want to encrypt. Must pass either String or SecureString. Example: Password from Get-Credential cmdlet

  .PARAMETER EncryptKey
    Mandatory. A 16, 24 or 32 byte key used to encrypt the data
  
  .INPUTS
    None - other than parameters above

  .OUTPUTS
    Encrypted data using specified key

  .NOTES
    Version:        1.0
    Author:         Luca Sturlese
    Creation Date:  14/02/13
    Purpose/Change: Initial function development

    Version:        1.1
    Author:         Luca Sturlese
    Creation Date:  15/02/13
    Purpose/Change: Added functionality to encrypt from plain-text of secure-string

    Version:        1.2
    Author:         Luca Sturlese
    Creation Date:  13/03/13
    Purpose/Change: Added sleep of few seconds between major commands to improve script success
      
  .EXAMPLE
    $EncryptedData = Encrypt-Data -String "This is the string I want to encrypt" -EncryptKey $EncryptKey

  .EXAMPLE
    $EncryptedData = Encrypt-Data -SecureString $Credentials.Password -EncryptKey $EncryptKey
  #>
    
  [CmdletBinding()]
  
  Param ([Parameter(Mandatory=$false)][string]$String, [Parameter(Mandatory=$false)]$SecureString, [Parameter(Mandatory=$true)]$EncryptKey)
  
  Begin{}
  
  Process{
    #Check if plain-text string provided or secure-string provided for encryption
    If(!($String) -And !($SecureString)){
      Throw "No data to encrypt provided. Either plain-text or secure-text string must be provided."
    }
  
    #Check that both not provided
    If(($String) -And ($SecureString)){
      Throw "Only provide either plain-text or secure-text string, not both."
    }
    
    #If plain-text, then convert to secure-string
    If($String){
      $oSecureString = New-Object System.Security.SecureString
      $Chars = $String.toCharArray()

      # Convert plain text string to char
      ForEach($Char in $Chars){
        $oSecureString.AppendChar($Char)
      } 
    }Else{
      $oSecureString = New-Object System.Security.SecureString
      $oSecureString = $SecureString
    }
    
    Start-Sleep -Seconds 2
    
    #Encrypt data using EncryptKey and char string
    $oEncryptedData = ConvertFrom-SecureString -SecureString $oSecureString -Key $EncryptKey
    
    Start-Sleep -Seconds 2
  
    Return $oEncryptedData
  }
  
  End{}
}

Function Decrypt-Data{
  <#
  .SYNOPSIS
    Used to decrypt data using a specified key

  .DESCRIPTION
    This function is used to decryt data using the specified key. The data can then be used accordingly in the calling script.

    Note: This script requires that the key used be converted to a 16, 24 or 32 byte key. To do this, use the Set-EncryptKey function above.
  
  .PARAMETER Data
    Mandatory. The data you want to decrypt

  .PARAMETER DecryptKey
    Mandatory. A 16, 24 or 32 byte key used to decrypt the data

  .PARAMETER ConvertToPlainText
    Non-Mandatory. If specified will convert decrypted data to plain-text. If not specified will leave decrypted data as a secure-string (e.g. good for passwords)
  
  .INPUTS
    None - other than parameters above

  .OUTPUTS
    Decrypted data using specified key

  .NOTES
    Version:        1.0
    Author:         Luca Sturlese
    Creation Date:  14/02/13
    Purpose/Change: Initial function development

    Version:        1.1
    Author:         Luca Sturlese
    Creation Date:  18/02/13
    Purpose/Change: Added functionality to decrypt data to secure-string or to plain-text
      
  .EXAMPLE
    $sPlainText = Decrypt-Data -EncryptedData $Data -DecryptKey $DecryptKey -ConvertToPlainText $True

  .EXAMPLE
    $sPlainText = Decrypt-Data -EncryptedData $Data -DecryptKey $DecryptKey
  #>
    
  [CmdletBinding()]
    
  Param ([Parameter(Mandatory=$true)]$Data, [Parameter(Mandatory=$true)]$DecryptKey, [Parameter(Mandatory=$false)]$ConvertToPlainText)
    
  Begin{}
    
  Process{
    #If ConvertToPlainText = False or not specified then convert to Secure-String, else convert to plain-text   
    If(!($ConvertToPlainText) -or ($ConvertToPlainText -eq $False)){
      $Data | ConvertTo-SecureString -Key $DecryptKey
    }Else{
      $Data | ConvertTo-SecureString -Key $DecryptKey | ForEach-Object {
        [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($_))
      }
    }
  }
    
  End{}
}