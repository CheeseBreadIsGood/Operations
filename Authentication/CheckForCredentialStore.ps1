 $CredentialStoreName = "AzureServicePrincipal" 
 
  if ( [StoredCredential]::Exists( $CredentialStoreName ) ){ 
    $credential = [StoredCredential]::New( $CredentialStoreName ) 
  } 
  else{ 
    Write-Information "You should create a credential store on this computer called $CredentialStoreName"
     #$credential = [StoredCredential]::Store( $CredentialStoreName, ( Get-Credential ) ) 
  } 
  Connect-AzAccount -ServicePrincipal -Credential $credential.PSCredential -Tenant "67327683-1032-4f0b-81d1-8abb3ae90945" ## log into Azure
  
