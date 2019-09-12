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
    This simple PowerShell class can be used for working with Credentials Manager and Password Vault in Windows: checking if account information is present in the vault, saving credentials to the vault and reading stored login and password information from the vault.
   Usage example:
$CredentialName = "MyCredential" 
 
if ( [StoredCredential]::Exists( $CredentialName ) ){ 
  $credential = [StoredCredential]::New( $CredentialName ) 
} 
else{ 
   $credential = [StoredCredential]::Store( $CredentialName, ( Get-Credential ) ) 
} 
 
New-PSSession -ComputerName "AppServer" -Credential $credential.PSCredential
  Connect-AzAccount -ServicePrincipal -Credential $credential.PSCredential -Tenant " ## log into Azure

  #>
 
 $CredentialStoreName = "AzureServicePrincipal" 
 
  if ( ![StoredCredential]::Exists( $CredentialStoreName ) ){ 
    $credential = [StoredCredential]::New( $CredentialStoreName ) 
  } 
  else{ 
    $credential = [StoredCredential]::Store( $CredentialStoreName, ( Get-Credential ) ) 
  } 
  Connect-AzAccount -ServicePrincipal -Credential $credential.PSCredential -Tenant "67327683-1032-4f0b-81d1-8abb3ae90945" ## log into Azure
  


  This simple PowerShell class can be used for working with Credentials Manager and Password Vault in Windows: checking if account information is present in the vault, saving credentials to the vault and reading stored login and password information from the vault.
 
 
Usage example:
 
$CredentialName = "MyCredential" 
 
if ( [StoredCredential]::Exists( $CredentialName ) ){ 
  $credential = [StoredCredential]::New( $CredentialName ) 
} 
else{ 
   $credential = [StoredCredential]::Store( $CredentialName, ( Get-Credential ) ) 
} 
 
New-PSSession -ComputerName "AppServer" -Credential $credential.PSCredential
#####
$testcredential = Get-Credential
$CredentialStoreName = "AAAAAplumbing" 
if ( -not [StoredCredential]::Exists( $CredentialStoreName ) ){ 
  $credential = [StoredCredential]::Store( $CredentialstoreName, $testcredential ) 
} 
