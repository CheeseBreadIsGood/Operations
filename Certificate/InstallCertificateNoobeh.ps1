##Install certificate
## The location of the Cert.pfx file
$CertPath = "C:\NoobehIT\ServerSetup\Certificates\CurrentCertNoobeh\Certificate.pfx"


$CertPwd = Read-Host -Prompt 'Certificate Password =-->'  -AsSecureString #Get the Cert private key password
## Place the new certificate into the machine\Personal store
Import-PfxCertificate -FilePath $CertPath -CertStoreLocation 'Cert:\LocalMachine\My' -Password $CertPwd -Verbose 

##Lets get the Thumbprint of the new certificate. We will need it later
$certificateObject = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
$certificateObject.Import($CertPath, $CertPwd, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::DefaultKeySet)
$CertThumb =  $certificateObject.Thumbprint
#######################################################################
##Install the new certificate into RD services
$Password = Read-Host -Prompt 'Password =-->'  -AsSecureString
$LocalHostname = ([System.Net.Dns]::GetHostByName(($env:computerName))).Hostname #Display Fully Qualified Domain Name for local computer

$Splatting =@{  ## the common settings we are going to splat, oh yeah.
    ImportPath = $CertPath
    Password = $Password
    ConnectionBroker = $LocalHostname
}

Set-RDCertificate @Splatting -Role RDGateway -Force	
Set-RDCertificate @Splatting -Role RDWebAccess -Force	
Set-RDCertificate @Splatting -Role RDPublishing -Force	
Set-RDCertificate @Splatting -Role RDRedirector -Force	

# get the web binding of the site & set the ssl certificate
(Get-WebBinding -Name 'Default Web Site' -Port 443 -Protocol "https").AddSslCertificate($CertThumb, "my")
#check for expiring certificates.
 Get-ChildItem -Path Cert:\localmachine\my -Recurse -ExpiringInDays 75

 #if using rd web service
 Import-RDWebClientBrokerCert \\noobehnas.file.core.windows.net\cloudnas\CertificateInfo\CurrentCertNoobeh\certificate.crt

