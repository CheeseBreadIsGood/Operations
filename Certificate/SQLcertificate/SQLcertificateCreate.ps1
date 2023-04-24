##
##  Create a self-signed certificate for 99 years and can be used for SQL encryption in transport
##  Create sqlcertificate 
##  Type password 
##  Type name of company 
##  2. Install the certificate is the script has not 
##  Properties of the certificate keys, make sure sql engine/named instanse can at least read it. Add user NT Service\SQLAgent$ACCTIVATE2022 Note: NT(SPace)Service 
##  Certificate properties, make sure it's only checked for SERVER and don't include client checkmark(Maybe not because someone might need a client to know this a root cert 
##  REMEMBER to give sql engine the rights to the certificate key in the properties of the cert. "Manage private key" 
##  Give SQL engine rights to READ. User: NT Service\mssql$acctivate2022 
##  5. SQL Server Configuration manager. Properties for engine\named instance. Properties 
##  Force encryption 
##  Pick crtificate 
##  Restart sql instanse service. 

$CompanyName = Read-Host "Enter Company Name" 
$DNSCompany = $CompanyName + ".Noobeh.Net" 
$CompanyName = "SQLServerCert" + $CompanyName 
$KeyPassword = Read-Host "Enter Key Password to create"
$FilePathHere =   "C:\NoobehIT\ServerSetup\Certificates\SQLCertificate.pfx"

$SplatParams = @{  
   DnsName = $DNSCompany  
   KeyLength = 2048  
   KeyFriendlyName = $CompanyName 
   KeyAlgorithm = 'RSA' 
   HashAlgorithm = 'SHA256'  
   KeyExportPolicy = 'Exportable'  
   KeySpec = 'KeyExchange'  
   NotAfter = (Get-date).AddYears(99)  
   #TextExtension = "2.5.29.37={text}1.3.6.1.5.5.7.3.1" ## Not needed
   Provider = 'Microsoft RSA SChannel Cryptographic Provider'  
   CertStoreLocation = 'Cert:\LocalMachine\My' 
   }  

$Cert = New-SelfSignedCertificate @SplatParams 

$thumbprint = $(Get-ChildItem Cert:\LocalMachine\My) | where {$_.Subject -eq ("CN=" + $DNSCompany)}
$thumbprint = $thumbprint.Thumbprint
$Pwd = ConvertTo-SecureString -String $KeyPassword -Force -AsPlainText
Export-PfxCertificate -Cert "Cert:\LocalMachine\My\$thumbprint" -FilePath $FilePathHere -Password $Pwd -Force