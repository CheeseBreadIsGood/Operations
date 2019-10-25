  <#--------------------------------------------------------------------
  .SYNOPSIS
    Used to decrypt stings in an encrypted CSV file of Three strings using a typed in SeedPassword (should be complex)
    Then use them to authenticate to Azure as a Service Principle. First it sees if there is a 

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
 Wfunction FunctionName {
   param ( [string]$SeedPasswordKey
   )
   
 }

  $File = ".\EncryptedCredentials.csv" #The file is stored at same location and will be on Github repository
  $LocalCredentialStoreName = "AzureServicePrincipal"   #just the name to use as the title in the Windows local credential store
  $LocalLoginLog = '.\Status\LoginLog.log' #The seedPasswordKet is on a local file. !!Not on github!!

  if ( [StoredCredential]::Exists( $LocalCredentialStoreName ) ){ #First see if there is a local store of Azure Service Principal in local computer
    $credentials = [StoredCredential]::New( $CredentialName ) 
    $SeedPasswordKey = $credentials.Password
  } elseif (Test-Path $LocalLoginLog){  #Second see if there is a local file that has the password in clear text at the bottom of random text file.
    $SeedPasswordKey = Get-Content -Path $LocalLoginLog -Delimiter " " #get the last line in the long file. Should be a slingle word
    $SeedPasswordKey = $SeedPasswordKey[-1].trim() #get rid of all the line arrays except for the last one and clean it up by Trimming out the leading and training white spaces.
    $SeedPasswordKey = ConvertTo-SecureString $SeedPasswordKey -AsPlainText -Force #change it into a secure string. Needed for the next step
  } else { #Lastly if the first two checks on the configurations for password fail, Just ask the user straight-up
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
Connect-AzAccount -ServicePrincipal -Credential $credentials -Tenant $CredentialItems.TenantID ## log into Azure as service principle 

#now put these credentials into the local windows credential store for later script usage

if ( -not [StoredCredential]::Exists( $LocalCredentialStoreName ) ){ # If not already there, 
  $tempCredentials = New-Object System.Management.Automation.PSCredential( $LocalCredentialStoreName,$SeedPasswordKey) #make just to store the $SeedPasswordKey in.
  [StoredCredential]::Store( $LocalCredentialstoreName, $tempCredentials) #Create stored credentials in the Windows credential store for later automated scripts to use $SeedPasswordKey
} 

<#   #Now test and get some secrets, oh cool

  #-----Just for testing-----
#[System.Net.NetworkCredential]::new("", $EncryptedPass).Password  #This decrypts a secure string
#[System.Net.NetworkCredential]::new("", $SPname).Password #This decrypts a secure string
#[System.Net.NetworkCredential]::new("", $TenantID).Password #This decrypts a secure string
#(Get-AzKeyVaultSecret -vaultName "guessTheNumber" -name "CloudKey1").SecretValueText

#>
class StoredCredential{ # simple password vault access class 
  [System.Management.Automation.PSCredential] $PSCredential 
  [string] $account; 
  [string] $password; 

  # loads credential from vault 
  StoredCredential( [string] $name ){ 
      [void][Windows.Security.Credentials.PasswordVault,Windows.Security.Credentials,ContentType=WindowsRuntime]  
      $vault = New-Object Windows.Security.Credentials.PasswordVault  
      $cred = $vault.FindAllByResource($name) | Select-Object -First 1 
      $cred.retrievePassword() 
      $this.account = $cred.userName 
      $this.password = $cred.password  
      $pwd_ss = ConvertTo-SecureString $cred.password -AsPlainText -Force 
      $this.PSCredential = New-Object System.Management.Automation.PSCredential ($this.account, $pwd_ss ) 
  } 

  static [bool] Exists( [string] $name ){ 
      [void][Windows.Security.Credentials.PasswordVault,Windows.Security.Credentials,ContentType=WindowsRuntime]  
      $vault = New-Object Windows.Security.Credentials.PasswordVault  
      try{ 
          $vault.FindAllByResource($name)  
      } 
      catch{ 
          if ( $_.Exception.message -match "element not found" ){ 
              return $false 
          } 
          throw $_.exception 
      } 
      return $true 
  } 


  static [StoredCredential] Store( [string] $name, [string] $login, [string] $pwd ){ 
      [void][Windows.Security.Credentials.PasswordVault,Windows.Security.Credentials,ContentType=WindowsRuntime] 
      $vault=New-Object Windows.Security.Credentials.PasswordVault 
      $cred=New-Object Windows.Security.Credentials.PasswordCredential($name, $login, $pwd) 
      $vault.Add($cred) 
      return [StoredCredential]::new($name) 
  } 
   
  static [StoredCredential] Store( [string] $name, [PSCredential] $pscred ){ 
      return [StoredCredential]::Store( $name, $pscred.UserName, ($pscred.GetNetworkCredential()).Password ) 
  } 

<# https://gallery.technet.microsoft.com/scriptcenter/Accessing-Windows-7210ae91
Usage example:
 
$CredentialName = "MyCredential" 
 
if ( [StoredCredential]::Exists( $CredentialName ) ){ 
  $credential = [StoredCredential]::New( $CredentialName ) 
} 
else{ 
   $credential = [StoredCredential]::Store( $CredentialName, ( Get-Credential ) ) 
} 
 
New-PSSession -ComputerName "AppServer" -Credential $credential.PSCredential

#>

}  #class StoredCredential 

