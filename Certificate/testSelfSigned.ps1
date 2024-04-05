$params = @{
    Type = 'Custom'
    Subject = 'E=patti.fuller@contoso.com,CN=Patti Fuller'
    TextExtension = @(
        '2.5.29.37={text}1.3.6.1.5.5.7.3.4',
        '2.5.29.17={text}email=patti.fuller@contoso.com&upn=pattifuller@contoso.com' )
    KeyAlgorithm = 'RSA'
    KeyLength = 2048
    SmimeCapabilities = $true
    CertStoreLocation = 'Cert:\CurrentUser\My'
}
New-SelfSignedCertificate @params