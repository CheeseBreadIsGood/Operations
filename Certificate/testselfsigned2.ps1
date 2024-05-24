$pass = ConvertTo-SecureString -String "CertNow##123##" -Force -AsPlainText
$expirationDate = (Get-Date).AddYears(2)

# Create a hashtable with the parameters
$certificateParams = @{
    DnsName = "*.netsuite.com", "6200013.app.netsuite.com"
    CertStoreLocation = "Cert:\LocalMachine\My"
    KeyAlgorithm = "ECDH_P256"
    KeyLength = 512
    Pin = $pass
    NotAfter = $expirationDate
}

# Use splatting to create the self-signed certificate
New-SelfSignedCertificate @certificateParams
